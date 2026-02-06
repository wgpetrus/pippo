// Dart SDK
import 'dart:async';

// Flutter
import 'package:flutter/foundation.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Imports locais
import '../../gamification/controllers/gems_controller.dart';
import '../../gamification/controllers/xp_level_controller.dart';

/// Controller de desafios (Treasure Challenges)
/// 
/// Gerencia o sistema de desafios diários, semanais e especiais do Pippo.
/// 
/// ## Integração com Outros Módulos
/// 
/// Este controller é projetado para trabalhar de forma independente, mas se integra
/// com outros módulos quando disponíveis:
/// 
/// ### Módulos Integrados (Atualmente)
/// - **LessonController**: Recebe eventos de conclusão de lição e exercícios
/// - **GemsController**: Recebe eventos de ganho de gems
/// - **XpLevelController**: Recebe eventos de ganho de XP
/// 
/// ### Pontos de Integração Futuros
/// - **ProfileController**: Pode exibir estatísticas de desafios no perfil
/// - **NotificationController**: Pode enviar notificações de desafios próximos da expiração
/// - **AnalyticsController**: Pode rastrear engajamento com desafios
/// - **CloudFunctions**: Geração automática de desafios personalizados
/// 
/// ## Como Adicionar Novas Integrações
/// 
/// Para integrar um novo módulo com o sistema de desafios:
/// 
/// 1. No módulo que gera eventos, adicione chamada condicional:
/// ```dart
/// try {
///   if (Get.isRegistered<dynamic>()) {
///     final treasureController = Get.find<dynamic>();
///     if (treasureController.toString().contains('TreasureController')) {
///       await treasureController.updateChallengeProgress('event_type', amount);
///     }
///   }
/// } catch (e) {
///   // TreasureController não registrado - não é crítico
///   print('⚠️ TreasureController não encontrado: $e');
/// }
/// ```
/// 
/// 2. Tipos de eventos suportados:
///    - 'lessons': Lições completadas
///    - 'correct_exercises': Exercícios corretos
///    - 'xp': XP ganho
///    - 'streak': Dias de streak mantidos
///    - (Adicione novos tipos conforme necessário)
/// 
/// 3. Crie desafios correspondentes no Firestore ou via generateDailyChallenges()
/// 
/// ## Backward Compatibility
/// 
/// Todas as integrações usam verificações condicionais (Get.isRegistered) para garantir
/// que o sistema funcione mesmo se o TreasureController não estiver disponível.
/// Isso permite desenvolvimento incremental e evita quebras em features existentes.
class TreasureController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados específicos
  final challenges = <Map<String, dynamic>>[].obs;
  final isClaimingReward = false.obs;

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    loadChallenges();
  }

  // Métodos públicos

  /// Carrega desafios ativos do Firestore e remove expirados
  Future<void> loadChallenges() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Verificar autenticação
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      // Buscar desafios do Firestore com retry
      await _fetchChallengesFromFirestore(user.uid);

      // Remover desafios expirados
      await removeExpiredChallenges();
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value =
          'Erro ao carregar desafios. Verifique sua conexão e tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Coleta recompensa de um desafio completado
  /// 
  /// Validações:
  /// - Desafio deve estar completado
  /// - Recompensa não deve ter sido coletada
  /// - Desafio não deve estar expirado
  /// - Usuário deve estar autenticado
  /// - Desafio deve pertencer ao usuário autenticado
  Future<void> claimReward(String challengeId) async {
    isClaimingReward.value = true;
    errorMessage.value = '';

    try {
      // Validação: usuário autenticado
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Você precisa estar autenticado para coletar recompensas.';
        return;
      }

      // Buscar desafio na lista local
      final challengeData = challenges.firstWhereOrNull(
        (c) => c['id'] == challengeId,
      );

      if (challengeData == null) {
        errorMessage.value = 'Desafio não encontrado.';
        return;
      }

      // Validação: desafio pertence ao usuário autenticado
      // (implícito - desafio está na lista do usuário)
      
      // Validação: desafio está completado
      if (!_isCompleted(challengeData)) {
        errorMessage.value = 'Este desafio ainda não foi completado.';
        return;
      }

      // Validação: recompensa não foi coletada
      final isClaimed = challengeData['isClaimed'] as bool? ?? false;
      if (isClaimed) {
        errorMessage.value = 'Você já coletou esta recompensa.';
        return;
      }

      // Validação: desafio não está expirado
      if (_isExpired(challengeData)) {
        errorMessage.value = 'Este desafio expirou.';
        return;
      }

      // Distribuir recompensa usando transação para atomicidade
      await _distributeReward(user.uid, challengeData);

      // Finalizar coleta: marcar como coletado e remover da lista
      await _finalizeClaim(user.uid, challengeId, challengeData);
      
      // Forçar atualização da UI em todas as telas
      debugPrint('🔄 Forçando atualização da UI...');
      Get.forceAppUpdate();
      debugPrint('✅ UI atualizada!');
      
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao coletar recompensa. Tente novamente.';
    } finally {
      isClaimingReward.value = false;
    }
  }

  /// Atualiza progresso de desafios baseado em eventos do sistema
  /// 
  /// Busca desafios ativos que correspondem ao [challengeType] e incrementa
  /// seu progresso em [amount]. Marca como completado quando progresso >= objetivo.
  /// 
  /// Validações:
  /// - amount deve ser não-negativo
  /// - desafio deve existir e estar ativo
  /// - desafio não deve estar expirado
  /// 
  /// ## Tipos de Eventos Suportados
  /// 
  /// Atualmente implementados:
  /// - 'lessons': Lições completadas (integrado com LessonController)
  /// - 'correct_exercises': Exercícios corretos (integrado com LessonController)
  /// - 'xp': XP ganho (integrado com XpLevelController)
  /// - 'streak': Dias de streak mantidos (integrado com StreakController)
  /// 
  /// TODO: [future] Adicionar suporte para novos tipos de eventos:
  /// - 'perfect_lessons': Lições completadas com 100% de acurácia
  /// - 'time_spent': Tempo de estudo em minutos
  /// - 'friends_added': Amigos adicionados
  /// - 'profile_completed': Perfil 100% preenchido
  /// - 'courses_started': Novos cursos iniciados
  /// - 'achievements_unlocked': Conquistas desbloqueadas
  /// 
  /// Para adicionar um novo tipo de evento:
  /// 1. Adicione o tipo à lista acima
  /// 2. No módulo que gera o evento, adicione chamada a updateChallengeProgress
  /// 3. Crie templates de desafios correspondentes em generateDailyChallenges/generateWeeklyChallenges
  Future<void> updateChallengeProgress(String challengeType, int amount) async {
    try {
      // Validação: amount não-negativo
      if (amount < 0) {
        errorMessage.value = 'O progresso não pode ser negativo.';
        return;
      }

      // Verificar autenticação
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      // Buscar desafios ativos que correspondem ao tipo
      final matchingChallenges = challenges.where((challenge) {
        final cType = challenge['challengeType'] as String?;
        final isClaimed = challenge['isClaimed'] as bool? ?? false;
        
        // Desafio deve corresponder ao tipo, não estar coletado e não estar expirado
        return cType == challengeType && 
               !isClaimed && 
               !_isExpired(challenge);
      }).toList();

      // Atualizar cada desafio correspondente
      for (final challenge in matchingChallenges) {
        final challengeId = challenge['id'] as String?;
        if (challengeId == null) continue;

        final currentProgress = challenge['progress'] as int? ?? 0;
        final goal = challenge['goal'] as int? ?? 0;
        final newProgress = currentProgress + amount;

        // Atualizar no Firestore usando FieldValue.increment (atômico)
        final docRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('challenges')
            .doc(challengeId);

        await docRef.update({
          'progress': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Verificar se atingiu o objetivo
        if (newProgress >= goal && !_isCompleted(challenge)) {
          // Marcar como completado
          await docRef.update({
            'isCompleted': true,
            'completedAt': FieldValue.serverTimestamp(),
          });

          // Atualizar estado local
          challenge['progress'] = newProgress;
          challenge['isCompleted'] = true;
          challenge['completedAt'] = Timestamp.now();
        } else {
          // Apenas atualizar progresso local
          challenge['progress'] = newProgress;
        }
      }

      // Atualizar lista observável para refletir mudanças
      challenges.refresh();
    } on FirebaseException catch (e) {
      // Silenciosamente falhar para não interromper fluxo principal
      // Erros de progresso não devem bloquear ações do usuário
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      // Silenciosamente falhar para não interromper fluxo principal
      errorMessage.value = 'Erro ao atualizar progresso do desafio.';
    }
  }

  /// Remove desafios expirados da lista local e do Firestore
  Future<void> removeExpiredChallenges() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Identificar desafios expirados
      final expiredChallenges =
          challenges.where((challenge) => _isExpired(challenge)).toList();

      // Remover do Firestore
      for (final challenge in expiredChallenges) {
        final challengeId = challenge['id'] as String?;
        if (challengeId != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('challenges')
              .doc(challengeId)
              .delete();
        }
      }

      // Remover da lista local
      challenges.removeWhere((challenge) => _isExpired(challenge));
    } catch (e) {
      // Silenciosamente falhar para não interromper o fluxo
      // A remoção será tentada novamente na próxima carga
    }
  }

  // Métodos privados

  /// Distribui recompensa ao usuário usando transação Firestore
  /// 
  /// Atualiza gems ou XP do usuário de forma atômica e notifica
  /// GemsController e XpLevelController se estiverem registrados
  Future<void> _distributeReward(
      String userId, Map<String, dynamic> challengeData) async {
    final rewardType = challengeData['rewardType'] as String?;
    final rewardAmount = challengeData['rewardAmount'] as int?;

    if (rewardType == null || rewardAmount == null) {
      errorMessage.value = 'Dados de recompensa inválidos.';
      return;
    }

    try {
      // Usar transação para garantir atomicidade
      await _firestore.runTransaction((transaction) async {
        // Referência para o documento de gamificação (local correto)
        final gamificationDocRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification');
        
        final gamificationDoc = await transaction.get(gamificationDocRef);

        if (!gamificationDoc.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
            message: 'Estatísticas de gamificação não encontradas.',
          );
        }

        // Atualizar gems ou XP baseado no tipo de recompensa
        switch (rewardType) {
          case 'gems':
            // Atualizar gems e totalGemsEarned atomicamente usando FieldValue.increment
            transaction.update(gamificationDocRef, {
              'gems.gems': FieldValue.increment(rewardAmount),
              'gems.totalGemsEarned': FieldValue.increment(rewardAmount),
              'lastUpdated': FieldValue.serverTimestamp(),
            });
            break;

          case 'xp':
            // Atualizar totalXp, weeklyXP e todayXp atomicamente usando FieldValue.increment
            transaction.update(gamificationDocRef, {
              'xp.totalXp': FieldValue.increment(rewardAmount),
              'xp.weeklyXP': FieldValue.increment(rewardAmount),
              'xp.todayXp': FieldValue.increment(rewardAmount),
              'lastUpdated': FieldValue.serverTimestamp(),
            });
            break;

          case 'item':
            // TODO: Implementar lógica de itens quando necessário
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unimplemented',
              message: 'Recompensas de itens ainda não implementadas.',
            );

          default:
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'invalid-argument',
              message: 'Tipo de recompensa desconhecido: $rewardType',
            );
        }
      });

      // Atualizar valores localmente IMEDIATAMENTE (para UI instantânea)
      try {
        switch (rewardType) {
          case 'gems':
            if (Get.isRegistered<GemsController>()) {
              final gemsController = Get.find<GemsController>();
              
              debugPrint('💎 Atualizando valores localmente no GemsController...');
              debugPrint('  Tipo de recompensa: $rewardType');
              debugPrint('  Quantidade: $rewardAmount');
              
              final oldGems = gemsController.gems.value;
              final oldTotal = gemsController.totalGemsEarned.value;
              
              // Atualizar valores reativos EXPLICITAMENTE
              gemsController.gems.value = oldGems + rewardAmount;
              gemsController.totalGemsEarned.value = oldTotal + rewardAmount;
              
              debugPrint('  Gems: $oldGems → ${gemsController.gems.value}');
              debugPrint('  Total Gems: $oldTotal → ${gemsController.totalGemsEarned.value}');
              debugPrint('  ✅ Valores de GEMS atualizados localmente!');
              
              // Forçar refresh dos observadores
              gemsController.gems.refresh();
              gemsController.totalGemsEarned.refresh();
            } else {
              debugPrint('⚠️ GemsController não está registrado!');
            }
            break;
            
          case 'xp':
            if (Get.isRegistered<XpLevelController>()) {
              final xpController = Get.find<XpLevelController>();
              
              debugPrint('💎 Atualizando valores localmente no XpLevelController...');
              debugPrint('  Tipo de recompensa: $rewardType');
              debugPrint('  Quantidade: $rewardAmount');
              
              final oldTotalXp = xpController.totalXp.value;
              final oldWeeklyXp = xpController.weeklyXP.value;
              final oldTodayXp = xpController.todayXp.value;
              
              // Atualizar valores reativos EXPLICITAMENTE
              xpController.totalXp.value = oldTotalXp + rewardAmount;
              xpController.weeklyXP.value = oldWeeklyXp + rewardAmount;
              xpController.todayXp.value = oldTodayXp + rewardAmount;
              
              debugPrint('  Total XP: $oldTotalXp → ${xpController.totalXp.value}');
              debugPrint('  Weekly XP: $oldWeeklyXp → ${xpController.weeklyXP.value}');
              debugPrint('  Today XP: $oldTodayXp → ${xpController.todayXp.value}');
              debugPrint('  ✅ Valores de XP atualizados localmente!');
              
              // Forçar refresh dos observadores
              xpController.totalXp.refresh();
              xpController.weeklyXP.refresh();
              xpController.todayXp.refresh();
            } else {
              debugPrint('⚠️ XpLevelController não está registrado!');
            }
            break;
        }
        
        debugPrint('✅ Valores atualizados localmente com sucesso!');
        debugPrint('🔔 UI deve atualizar INSTANTANEAMENTE via Obx()');
        debugPrint('🔄 Refresh forçado nos observadores!');
      } catch (e) {
        // Controllers não registrados - não é crítico
        debugPrint('⚠️ Erro ao atualizar controllers: $e');
      }
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      rethrow;
    }
  }

  /// Finaliza coleta de recompensa
  /// 
  /// Marca desafio como coletado no Firestore, remove da lista local
  /// e mostra animação de recompensa
  Future<void> _finalizeClaim(
      String userId, String challengeId, Map<String, dynamic> challengeData) async {
    // Marcar como coletado no Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('challenges')
        .doc(challengeId)
        .update({
      'isClaimed': true,
      'claimedAt': FieldValue.serverTimestamp(),
    });

    // Remover da lista local
    challenges.removeWhere((c) => c['id'] == challengeId);

    // TODO: [Task 13.1] Mostrar animação de recompensa
    // _showRewardAnimation(challengeData);
  }

  /// Busca desafios do Firestore com retry logic
  Future<void> _fetchChallengesFromFirestore(String userId,
      {int retryCount = 0}) async {
    debugPrint('🔍 _fetchChallengesFromFirestore() iniciado (retry: $retryCount)...');
    
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    try {
      debugPrint('📡 Buscando desafios no Firestore: users/$userId/challenges');
      
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .get()
          .timeout(const Duration(seconds: 30));

      debugPrint('✅ Snapshot recebido: ${snapshot.docs.length} documentos');

      // Converter documentos para Map<String, dynamic>
      final challengesList = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Adicionar ID do documento
        debugPrint('  📄 Documento ${doc.id}: ${data['title']}');
        return data;
      }).toList();

      debugPrint('📋 Total de desafios convertidos: ${challengesList.length}');

      // Ordenar por tipo e data de expiração
      challengesList.sort((a, b) {
        // Ordem de prioridade: daily, weekly, special
        final typeOrder = {'daily': 0, 'weekly': 1, 'special': 2};
        final typeComparison = (typeOrder[a['type']] ?? 3)
            .compareTo(typeOrder[b['type']] ?? 3);

        if (typeComparison != 0) return typeComparison;

        // Se mesmo tipo, ordenar por data de expiração
        final aExpiration = (a['expirationDate'] as Timestamp?)?.toDate();
        final bExpiration = (b['expirationDate'] as Timestamp?)?.toDate();

        if (aExpiration == null && bExpiration == null) return 0;
        if (aExpiration == null) return 1;
        if (bExpiration == null) return -1;

        return aExpiration.compareTo(bExpiration);
      });

      debugPrint('✅ Desafios ordenados');

      challenges.value = challengesList;
      
      debugPrint('✅ challenges.value atualizado: ${challenges.length} desafios');
    } on TimeoutException {
      debugPrint('❌ Timeout ao buscar desafios');
      // Retry em caso de timeout
      if (retryCount < maxRetries) {
        debugPrint('🔄 Tentando novamente em 2 segundos...');
        await Future.delayed(retryDelay);
        return _fetchChallengesFromFirestore(userId,
            retryCount: retryCount + 1);
      }
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} - ${e.message}');
      // Retry em caso de erro de rede ou indisponibilidade
      if ((e.code == 'unavailable' || e.code == 'deadline-exceeded') &&
          retryCount < maxRetries) {
        debugPrint('🔄 Tentando novamente em 2 segundos...');
        await Future.delayed(retryDelay);
        return _fetchChallengesFromFirestore(userId,
            retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  // Métodos de determinação de estado (para UI)

  /// Verifica se um desafio está no estado "In Progress"
  /// 
  /// Um desafio está em progresso quando:
  /// - Progresso < objetivo
  /// - Não foi coletado
  /// - Não está expirado
  bool isInProgress(Map<String, dynamic> challenge) {
    final isClaimed = challenge['isClaimed'] as bool? ?? false;
    return !_isCompleted(challenge) && !isClaimed && !_isExpired(challenge);
  }

  /// Verifica se um desafio está no estado "Completed"
  /// 
  /// Um desafio está completado quando:
  /// - Progresso >= objetivo
  /// - Não foi coletado
  /// - Não está expirado
  bool isCompletedState(Map<String, dynamic> challenge) {
    final isClaimed = challenge['isClaimed'] as bool? ?? false;
    return _isCompleted(challenge) && !isClaimed && !_isExpired(challenge);
  }

  /// Verifica se o botão de coletar recompensa deve estar habilitado
  /// 
  /// Botão habilitado quando:
  /// - Desafio está completado
  /// - Não foi coletado
  /// - Não está expirado
  /// - Não está em processo de coleta
  bool isClaimButtonEnabled(Map<String, dynamic> challenge) {
    return _canClaim(challenge) && !isClaimingReward.value;
  }

  /// Verifica se deve mostrar animação de brilho (glow)
  /// 
  /// Animação mostrada quando:
  /// - Desafio está completado
  /// - Não foi coletado
  /// - Não está expirado
  bool shouldShowGlowAnimation(Map<String, dynamic> challenge) {
    return isCompletedState(challenge);
  }

  /// Obtém porcentagem de progresso para exibição (0.0 a 1.0)
  double getProgressPercentage(Map<String, dynamic> challenge) {
    return _getProgressPercentage(challenge);
  }

  // Validação de estrutura de desafios

  /// Valida estrutura completa de um desafio
  /// 
  /// Verifica:
  /// - Todos os campos obrigatórios estão presentes
  /// - Goal é um inteiro positivo
  /// - Reward amount é positivo
  /// - Reward type é válido (gems, xp, item)
  /// - Progress é inicializado em zero
  /// 
  /// Retorna mensagem de erro ou null se válido
  String? validateChallengeStructure(Map<String, dynamic> challenge) {
    // Validar campos obrigatórios
    final requiredFields = [
      'title',
      'description',
      'goal',
      'progress',
      'rewardType',
      'rewardAmount',
      'expirationDate',
      'iconPath',
      'type',
    ];

    for (final field in requiredFields) {
      if (!challenge.containsKey(field) || challenge[field] == null) {
        return 'Todos os campos obrigatórios devem ser preenchidos.';
      }
    }

    // Validar goal é inteiro positivo
    final goal = challenge['goal'];
    if (goal is! int || goal <= 0) {
      return 'O objetivo deve ser um número positivo.';
    }

    // Validar reward amount é positivo
    final rewardAmount = challenge['rewardAmount'];
    if (rewardAmount is! int || rewardAmount <= 0) {
      return 'A recompensa deve ser um valor positivo.';
    }

    // Validar reward type
    final rewardType = challenge['rewardType'];
    if (rewardType is! String ||
        !['gems', 'xp', 'item'].contains(rewardType)) {
      return 'Tipo de recompensa inválido.';
    }

    // Validar progress é zero para novos desafios
    final progress = challenge['progress'];
    if (progress is! int || progress != 0) {
      return 'O progresso inicial deve ser zero.';
    }

    return null; // Válido
  }

  /// Valida campos obrigatórios de um desafio
  bool hasRequiredFields(Map<String, dynamic> challenge) {
    final requiredFields = [
      'title',
      'description',
      'goal',
      'progress',
      'rewardType',
      'rewardAmount',
      'expirationDate',
      'iconPath',
      'type',
    ];

    for (final field in requiredFields) {
      if (!challenge.containsKey(field) || challenge[field] == null) {
        return false;
      }
    }

    return true;
  }

  /// Valida se goal é um inteiro positivo
  bool isValidGoal(Map<String, dynamic> challenge) {
    final goal = challenge['goal'];
    return goal is int && goal > 0;
  }

  /// Valida se reward amount é positivo
  bool isValidRewardAmount(Map<String, dynamic> challenge) {
    final rewardAmount = challenge['rewardAmount'];
    return rewardAmount is int && rewardAmount > 0;
  }

  /// Valida se reward type é válido
  bool isValidRewardType(Map<String, dynamic> challenge) {
    final rewardType = challenge['rewardType'];
    return rewardType is String && ['gems', 'xp', 'item'].contains(rewardType);
  }

  /// Valida se progress inicial é zero
  bool hasZeroInitialProgress(Map<String, dynamic> challenge) {
    final progress = challenge['progress'];
    return progress is int && progress == 0;
  }

  // Geração de desafios (opcional)

  /// Deleta TODOS os desafios do usuário (usar apenas para limpar dados incorretos)
  Future<void> deleteAllChallenges() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      debugPrint('🗑️ Deletando todos os desafios...');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('challenges')
          .get();

      debugPrint('📋 Encontrados ${snapshot.docs.length} desafios para deletar');

      // Deletar cada documento
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
        debugPrint('  ✅ Deletado: ${doc.id}');
      }

      // Limpar lista local
      challenges.clear();

      debugPrint('✅ Todos os desafios foram deletados!');
    } catch (e) {
      debugPrint('❌ Erro ao deletar desafios: $e');
    }
  }

  /// Gera desafios diários para o usuário
  /// 
  /// Cria templates de desafios diários com expiração à meia-noite
  /// e salva no Firestore
  Future<void> generateDailyChallenges() async {
    try {
      // Validar autenticação
      final user = _auth.currentUser;
      if (user == null) return;

      // Templates de desafios diários
      final dailyTemplates = [
        {
          'title': 'Complete 3 lições',
          'description': 'Termine 3 lições hoje para ganhar gems',
          'goal': 3,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'iconPath': 'assets/images/icons/icons-treasure-page/livro.png',
          'type': 'daily',
          'challengeType': 'lessons',
        },
        {
          'title': 'Ganhe 100 XP',
          'description': 'Acumule 100 XP hoje',
          'goal': 100,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 30,
          'iconPath': 'assets/images/icons/icons-treasure-page/xp-coin.png',
          'type': 'daily',
          'challengeType': 'xp',
        },
        {
          'title': 'Acerte 10 exercícios',
          'description': 'Complete 10 exercícios corretamente',
          'goal': 10,
          'progress': 0,
          'rewardType': 'xp',
          'rewardAmount': 50,
          'iconPath': 'assets/images/icons/icons-treasure-page/alvo.png',
          'type': 'daily',
          'challengeType': 'correct_exercises',
        },
      ];

      // Calcular expiração para desafios diários
      final expiration = calculateExpiration('daily');

      // Salvar cada template no Firestore
      for (final template in dailyTemplates) {
        final challengeData = {
          ...template,
          'expirationDate': Timestamp.fromDate(expiration),
          'isClaimed': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('challenges')
            .add(challengeData);
      }

      // Recarregar desafios
      await loadChallenges();
    } catch (e) {
      // Silenciosamente falhar - geração de desafios não deve bloquear o app
    }
  }

  /// Gera desafios semanais para o usuário
  /// 
  /// Cria templates de desafios semanais com expiração no domingo
  /// e salva no Firestore
  Future<void> generateWeeklyChallenges() async {
    try {
      // Validar autenticação
      final user = _auth.currentUser;
      if (user == null) return;

      // Templates de desafios semanais
      final weeklyTemplates = [
        {
          'title': 'Complete 15 lições esta semana',
          'description': 'Termine 15 lições até domingo para ganhar gems',
          'goal': 15,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 200,
          'iconPath': 'assets/images/icons/icons-treasure-page/bau-gemado.png',
          'type': 'weekly',
          'challengeType': 'lessons',
        },
        {
          'title': 'Mantenha streak de 7 dias',
          'description': 'Estude todos os dias da semana',
          'goal': 7,
          'progress': 0,
          'rewardType': 'xp',
          'rewardAmount': 300,
          'iconPath': 'assets/images/icons/icons-appbar-home/fire_appbar.png',
          'type': 'weekly',
          'challengeType': 'streak',
        },
        {
          'title': 'Ganhe 500 XP esta semana',
          'description': 'Acumule 500 XP até domingo',
          'goal': 500,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 150,
          'iconPath': 'assets/images/icons/icons-treasure-page/xp-coin.png',
          'type': 'weekly',
          'challengeType': 'xp',
        },
      ];

      // Calcular expiração para desafios semanais
      final expiration = calculateExpiration('weekly');

      // Salvar cada template no Firestore
      for (final template in weeklyTemplates) {
        final challengeData = {
          ...template,
          'expirationDate': Timestamp.fromDate(expiration),
          'isClaimed': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('challenges')
            .add(challengeData);
      }

      // Recarregar desafios
      await loadChallenges();
    } catch (e) {
      // Silenciosamente falhar - geração de desafios não deve bloquear o app
    }
  }

  // Métodos auxiliares (helpers)

  /// Calcula data de expiração baseado no tipo de desafio
  /// 
  /// - Daily: meia-noite (23:59:59) do dia atual
  /// - Weekly: domingo 23:59:59 da semana atual
  /// - Special: data customizada fornecida
  DateTime calculateExpiration(String type, {DateTime? customDate}) {
    final now = DateTime.now();

    switch (type) {
      case 'daily':
        // Expira à meia-noite do dia atual
        return DateTime(now.year, now.month, now.day, 23, 59, 59);

      case 'weekly':
        // Expira no domingo às 23:59:59 da semana atual
        final daysUntilSunday = DateTime.sunday - now.weekday;
        final nextSunday = daysUntilSunday == 0
            ? now
            : now.add(Duration(days: daysUntilSunday));
        return DateTime(
            nextSunday.year, nextSunday.month, nextSunday.day, 23, 59, 59);

      case 'special':
        // Usa data customizada ou padrão de 7 dias
        return customDate ?? now.add(const Duration(days: 7));

      default:
        // Fallback: 1 dia
        return now.add(const Duration(days: 1));
    }
  }

  /// Verifica se um desafio está expirado
  bool _isExpired(Map<String, dynamic> challenge) {
    final expirationDate =
        (challenge['expirationDate'] as Timestamp?)?.toDate();
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate);
  }

  /// Verifica se um desafio está completo (progresso >= objetivo)
  bool _isCompleted(Map<String, dynamic> challenge) {
    final progress = challenge['progress'] as int? ?? 0;
    final goal = challenge['goal'] as int? ?? 0;
    return progress >= goal;
  }

  /// Verifica se um desafio pode ter recompensa coletada
  bool _canClaim(Map<String, dynamic> challenge) {
    final isClaimed = challenge['isClaimed'] as bool? ?? false;
    return _isCompleted(challenge) && !isClaimed && !_isExpired(challenge);
  }

  /// Calcula porcentagem de progresso de um desafio (0.0 a 1.0)
  double _getProgressPercentage(Map<String, dynamic> challenge) {
    final progress = challenge['progress'] as int? ?? 0;
    final goal = challenge['goal'] as int? ?? 1;
    return (progress / goal).clamp(0.0, 1.0);
  }

  // Handlers

  /// Handler de erros do Firestore
  String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
      case 'unavailable':
        return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
      case 'deadline-exceeded':
        return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
      case 'resource-exhausted':
        return 'Muitas requisições. Aguarde alguns minutos e tente novamente.';
      case 'failed-precondition':
        return 'Operação não permitida no estado atual. Tente novamente.';
      case 'aborted':
        return 'Operação cancelada. Tente novamente.';
      case 'out-of-range':
        return 'Valor fora do intervalo permitido.';
      case 'unimplemented':
        return 'Operação não implementada.';
      case 'internal':
        return 'Erro interno do servidor. Tente novamente em alguns instantes.';
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'not-found':
        return 'Recurso não encontrado.';
      case 'already-exists':
        return 'Recurso já existe.';
      case 'cancelled':
        return 'Operação cancelada.';
      case 'data-loss':
        return 'Erro de integridade de dados.';
      case 'invalid-argument':
        return 'Argumento inválido.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }
}
