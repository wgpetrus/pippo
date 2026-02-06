// Dart SDK

// Flutter
import 'package:flutter/foundation.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Imports locais
import '../../gamification/controllers/gems_controller.dart';
import '../../gamification/controllers/xp_level_controller.dart';
import 'treasure_challenges_controller.dart';

/// Controller de recompensas de desafios (Treasure Rewards)
/// 
/// Gerencia a coleta e distribuição de recompensas dos desafios completados.
class TreasureRewardsController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados específicos
  final isClaimingReward = false.obs;

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Dependencies
  late final TreasureChallengesController _challengesController;

  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    // Initialize dependencies
    try {
      _challengesController = Get.find<TreasureChallengesController>();
    } catch (e) {
      debugPrint('⚠️ TreasureChallengesController não encontrado: $e');
    }
  }

  // Métodos públicos

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
      final challengeData = _challengesController.challenges.firstWhereOrNull(
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

  /// Carrega histórico de recompensas coletadas
  Future<void> loadRewardHistory() async {
    // TODO: Implementar quando necessário
    // Pode buscar desafios com isClaimed = true do Firestore
  }

  /// Calcula valor da recompensa de um desafio
  int calculateReward(Map<String, dynamic> challenge) {
    final rewardAmount = challenge['rewardAmount'] as int? ?? 0;
    return rewardAmount;
  }

  // Métodos de determinação de estado (para UI)

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
    final isClaimed = challenge['isClaimed'] as bool? ?? false;
    return _isCompleted(challenge) && !isClaimed && !_isExpired(challenge);
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
    _challengesController.challenges.removeWhere((c) => c['id'] == challengeId);

    // TODO: [Task 13.1] Mostrar animação de recompensa
    // _showRewardAnimation(challengeData);
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
