import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../shared/mocks/leaderboard_mocks.dart';

/// Controller para gerenciar o sistema de ranking/leaderboard
///
/// Responsável por:
/// - Carregar dados do leaderboard do Firestore
/// - Calcular rankings e zonas (promoção/seguro/rebaixamento)
/// - Gerenciar status do usuário (emoji)
/// - Calcular recompensas baseadas no rank
/// - Gerenciar mudanças de liga
class LeaderboardController extends GetxController {
  // Estados obrigatórios (padrão da empresa)
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados específicos do leaderboard
  final leaderboardData = <Map<String, dynamic>>[].obs; // 30 users
  final currentUserRank = 0.obs;
  final currentLeague = 'bronze'.obs;
  final selectedLeague = 'bronze'.obs;
  final daysRemaining = 0.obs;
  final isUpdatingStatus = false.obs;
  final weekStartDate = Rx<DateTime?>(null);
  final weekEndDate = Rx<DateTime?>(null);

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Listener para atualizações em tempo real (opcional)
  StreamSubscription<QuerySnapshot>? _leaderboardListener;

  // Lifecycle
  @override
  void onClose() {
    _leaderboardListener?.cancel();
    super.onClose();
  }

  // Métodos públicos

  /// Carrega dados do leaderboard do Firestore
  /// 
  /// Busca o grupo do leaderboard do usuário atual e carrega os dados de todos
  /// os membros. Ordena usuários por weeklyXP (descendente), calcula ranks (1-30),
  /// determina zonas (promoção/seguro/rebaixamento) e calcula dias restantes.
  Future<void> loadLeaderboardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Verificar autenticação (capturar erros de inicialização do Firebase)
      User? user;
      try {
        user = _auth.currentUser;
      } catch (e) {
        // Firebase não inicializado (ambiente de teste) - usar mocks
        _loadMockData();
        isLoading.value = false;
        return;
      }
      
      if (user == null) {
        throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'Usuário não autenticado',
        );
      }

      // 2. Buscar dados do usuário para obter o groupId
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Dados do usuário não encontrados',
        );
      }

      final userData = userDoc.data();
      final groupId = userData?['stats']?['gamification']?['leaderboardGroupId'] as String?;
      
      // Se usuário não tem grupo, mostrar lista vazia (aguardando formação de grupo)
      if (groupId == null || groupId.isEmpty) {
        leaderboardData.value = [];
        daysRemaining.value = _calculateDaysRemaining();
        weekStartDate.value = _getWeekStartDate();
        weekEndDate.value = _getWeekEndDate();
        currentLeague.value = userData?['stats']?['gamification']?['currentLeague'] ?? 'bronze';
        isLoading.value = false; // ✅ Marcar como não loading
        return;
      }

      // 3. Buscar dados do grupo
      final groupDoc = await _firestore
          .collection('leaderboardGroups')
          .doc(groupId)
          .get();

      if (!groupDoc.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Grupo do leaderboard não encontrado',
        );
      }

      final groupData = groupDoc.data();
      final memberIds = List<String>.from(groupData?['memberIds'] ?? []);

      // 4. Buscar dados de cada membro do grupo
      final memberDataList = <Map<String, dynamic>>[];
      
      for (final memberId in memberIds) {
        final memberDoc = await _firestore
            .collection('users')
            .doc(memberId)
            .get();

        if (memberDoc.exists) {
          final memberData = memberDoc.data();
          final gamificationData = memberData?['stats']?['gamification'];
          
          memberDataList.add({
            'userId': memberId,
            'name': memberData?['name'] ?? 'Usuário',
            'avatar': memberData?['avatar'] ?? 'assets/images/characters/diogo.png',
            'weeklyXP': gamificationData?['weeklyXP'] ?? 0,
            'userStatus': gamificationData?['userStatus'],
            'isCurrentUser': memberId == user.uid,
          });
        }
      }

      // 5. Ordenar por weeklyXP (descendente)
      memberDataList.sort((a, b) =>
          (b['weeklyXP'] as int).compareTo(a['weeklyXP'] as int));

      // 6. Atribuir ranks (1-30)
      for (int i = 0; i < memberDataList.length; i++) {
        memberDataList[i]['rank'] = i + 1;
      }

      // 7. Determinar zonas
      for (int i = 0; i < memberDataList.length; i++) {
        final rank = i + 1;
        if (rank >= 1 && rank <= 3) {
          memberDataList[i]['zone'] = 'promotion';
        } else if (rank >= 4 && rank <= 7) {
          memberDataList[i]['zone'] = 'safe';
        } else if (rank >= 8 && rank <= 10) {
          memberDataList[i]['zone'] = 'demotion';
        }
      }

      // 8. Calcular dias restantes na semana
      daysRemaining.value = _calculateDaysRemaining();

      // 9. Calcular datas da semana
      weekStartDate.value = _getWeekStartDate();
      weekEndDate.value = _getWeekEndDate();

      // 10. Encontrar rank do usuário atual
      final currentUserData = memberDataList.firstWhere(
        (member) => member['isCurrentUser'] == true,
        orElse: () => {'rank': 0},
      );
      currentUserRank.value = currentUserData['rank'] as int;

      // 11. Atualizar liga atual
      currentLeague.value = userData?['stats']?['gamification']?['currentLeague'] ?? 'bronze';

      // 12. Atualizar dados do leaderboard
      leaderboardData.value = memberDataList;

    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleAuthError(e);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } catch (e) {
      errorMessage.value = 'Erro ao carregar ranking. Verifique sua conexão e tente novamente.';
    } finally {
      isLoading.value = false;
      
      // Fallback para dados mockados APENAS se houver erro E lista vazia
      // NÃO carregar mocks se usuário simplesmente não tem grupo ainda
      if (leaderboardData.isEmpty && errorMessage.value.isNotEmpty) {
        _loadMockData();
      }
    }
  }

  // Métodos públicos

  /// Calcula dias restantes até segunda-feira 00:00 (reset semanal)
  /// 
  /// Retorna um inteiro de 0 a 6 representando os dias restantes até
  /// a próxima segunda-feira às 00:00 (quando ocorre o reset semanal).
  /// 
  /// Retorna: Número de dias restantes (0-6)
  int getDaysRemainingInWeek() {
    return _calculateDaysRemaining();
  }

  /// Retorna a data de início da semana (segunda-feira 00:00 mais recente)
  /// 
  /// Calcula e retorna a data da segunda-feira 00:00 mais recente.
  /// Se hoje é segunda-feira, retorna a segunda-feira atual às 00:00.
  /// 
  /// Retorna: DateTime representando a segunda-feira 00:00 mais recente
  DateTime getWeekStartDate() {
    return _getWeekStartDate();
  }

  /// Retorna a data de fim da semana (próxima segunda-feira 00:00)
  /// 
  /// Calcula e retorna a data da próxima segunda-feira às 00:00.
  /// Esta é a data em que ocorrerá o próximo reset semanal.
  /// 
  /// Retorna: DateTime representando a próxima segunda-feira 00:00
  DateTime getWeekEndDate() {
    return _getWeekEndDate();
  }

  // Métodos privados - Helpers de data

  /// Calcula dias restantes até segunda-feira 00:00 (reset semanal)
  int _calculateDaysRemaining() {
    final now = DateTime.now();
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    
    // Se já é segunda-feira, calcular até a próxima segunda
    final nextMonday = daysUntilMonday == 0 
        ? now.add(const Duration(days: 7))
        : now.add(Duration(days: daysUntilMonday));
    
    final nextMondayMidnight = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
    
    // Calcular diferença em dias
    final difference = nextMondayMidnight.difference(now);
    
    // Se a diferença é exatamente 7 dias (estamos em segunda 00:00), retornar 6
    // porque não contamos o dia atual
    if (difference.inDays == 7 && now.hour == 0 && now.minute == 0 && now.second == 0) {
      return 6;
    }
    
    return difference.inDays;
  }

  /// Retorna a data de início da semana (segunda-feira 00:00 mais recente)
  DateTime _getWeekStartDate() {
    final now = DateTime.now();
    final daysFromMonday = (now.weekday - DateTime.monday) % 7;
    final monday = now.subtract(Duration(days: daysFromMonday));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Retorna a data de fim da semana (próxima segunda-feira 00:00)
  DateTime _getWeekEndDate() {
    final now = DateTime.now();
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    final nextMonday = daysUntilMonday == 0 
        ? now.add(const Duration(days: 7))
        : now.add(Duration(days: daysUntilMonday));
    return DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
  }

  /// Determina a zona de um usuário baseado no rank
  /// 
  /// Retorna:
  /// - 'promotion' para ranks 1-3 (avançam para próxima liga)
  /// - 'safe' para ranks 4-7 (permanecem na liga atual)
  /// - 'demotion' para ranks 8-10 (caem para liga anterior)
  String getUserZone(int rank) {
    if (rank >= 1 && rank <= 3) return 'promotion';
    if (rank >= 4 && rank <= 7) return 'safe';
    if (rank >= 8 && rank <= 10) return 'demotion';
    return 'safe'; // fallback
  }

  /// Calcula o rank de um usuário específico baseado em weeklyXP
  /// 
  /// Ordena usuários por weeklyXP (descendente) e retorna o rank do usuário.
  /// Usuários com mesmo XP recebem ranks sequenciais (sem gaps).
  /// 
  /// Retorna 0 se o usuário não for encontrado.
  int getRankForUser(List<Map<String, dynamic>> users, String userId) {
    if (users.isEmpty) return 0;

    // Criar cópia para não modificar original
    final sortedUsers = List<Map<String, dynamic>>.from(users);

    // Ordenar por weeklyXP (descendente)
    sortedUsers.sort((a, b) =>
        (b['weeklyXP'] as int).compareTo(a['weeklyXP'] as int));

    // Encontrar índice do usuário
    final index = sortedUsers.indexWhere((user) => user['userId'] == userId);

    // Retornar rank (índice + 1) ou 0 se não encontrado
    return index == -1 ? 0 : index + 1;
  }

  /// Troca a liga selecionada e recarrega os dados do leaderboard
  /// 
  /// Atualiza o observable selectedLeague e recarrega os dados do leaderboard
  /// para a nova liga selecionada.
  /// 
  /// Parâmetros:
  /// - league: String com a liga ('bronze', 'silver', 'gold', 'platinum', 'diamond')
  Future<void> switchLeague(String league) async {
    // Validar liga
    const validLeagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    if (!validLeagues.contains(league)) {
      errorMessage.value = 'Liga inválida.';
      return;
    }

    // Atualizar liga selecionada
    selectedLeague.value = league;

    // Recarregar dados do leaderboard para a nova liga
    await loadLeaderboardData();
  }

  /// Determina a liga atual do usuário a partir do Firestore
  /// 
  /// Busca a liga do usuário no Firestore. Se não estiver definida,
  /// retorna 'bronze' como padrão.
  /// 
  /// Retorna: String com a liga ('bronze', 'silver', 'gold', 'platinum', 'diamond')
  Future<String> getCurrentUserLeague() async {
    try {
      // Verificar autenticação
      final user = _auth.currentUser;
      if (user == null) {
        return 'bronze'; // Padrão se não autenticado
      }

      // Buscar do Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        return 'bronze'; // Padrão se documento não existe
      }

      final league = userDoc.data()?['stats']?['gamification']?['currentLeague'] as String?;
      return league ?? 'bronze';

    } catch (e) {
      // Em caso de erro, retornar bronze como padrão
      return 'bronze';
    }
  }

  /// Calcula a recompensa em gems baseada no rank final
  /// 
  /// Retorna:
  /// - 100 gems para rank 1
  /// - 50 gems para rank 2
  /// - 25 gems para rank 3
  /// - 0 gems para outros ranks
  /// 
  /// Parâmetros:
  /// - rank: Posição final do usuário (1-30)
  int getRewardForRank(int rank) {
    if (rank == 1) return 100;
    if (rank == 2) return 50;
    if (rank == 3) return 25;
    return 0;
  }

  /// Calcula a recompensa de promoção baseada na mudança de liga
  /// 
  /// Retorna:
  /// - 200 gems para Bronze → Silver
  /// - 500 gems para Silver → Gold
  /// - 0 gems para outras transições ou se não houver promoção
  /// 
  /// Parâmetros:
  /// - fromLeague: Liga de origem ('bronze', 'silver', 'gold', 'platinum', 'diamond')
  /// - toLeague: Liga de destino ('bronze', 'silver', 'gold', 'platinum', 'diamond')
  int calculatePromotionReward(String fromLeague, String toLeague) {
    // Bronze → Silver
    if (fromLeague == 'bronze' && toLeague == 'silver') {
      return 200;
    }
    
    // Silver → Gold
    if (fromLeague == 'silver' && toLeague == 'gold') {
      return 500;
    }
    
    // Outras transições não têm recompensa adicional
    return 0;
  }

  /// Atualiza o status emoji do usuário no Firestore
  /// 
  /// Permite que o usuário defina um emoji opcional para exibir no leaderboard.
  /// O status é persistido no Firestore e atualizado localmente.
  /// 
  /// Parâmetros:
  /// - emoji: String com o emoji ou null para remover o status
  /// 
  /// Lança exceção se o usuário não estiver autenticado ou se houver erro no Firestore.
  Future<void> updateUserStatus(String? emoji) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    try {
      // Verificar autenticação
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'Usuário não autenticado',
        );
      }

      // Atualizar no Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'stats.gamification.userStatus': emoji,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Atualizar localmente nos dados do leaderboard
      final userIndex = leaderboardData.indexWhere(
          (m) => m['isCurrentUser'] == true);
      
      if (userIndex != -1) {
        leaderboardData[userIndex]['userStatus'] = emoji;
        leaderboardData.refresh();
      }

    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleAuthError(e);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao atualizar status. Tente novamente.';
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  // ============================================================================
  // CLOUD FUNCTION - Reset Semanal (OPCIONAL - NÃO IMPLEMENTADO)
  // ============================================================================
  //
  // NOTA: O reset semanal do leaderboard seria implementado como uma Cloud Function
  // do Firebase, mas não é necessário para o MVP funcionar.
  //
  // Localização futura: functions/src/weeklyLeaderboardReset.ts
  // Trigger: Scheduled (cron: '0 0 * * 1' - toda segunda-feira às 00:00 UTC)
  //
  // O que a função faria:
  // 1. Calcular rankings finais de todos os grupos ativos
  // 2. Processar promoções (top 3) e rebaixamentos (bottom 3)
  // 3. Distribuir recompensas em gems baseadas no rank final
  // 4. Formar novos grupos aleatórios de 10 usuários por liga
  // 5. Resetar weeklyXP de todos os usuários para 0
  // 6. Enviar notificações sobre mudanças de liga e recompensas
  //
  // Por enquanto, o sistema funciona completamente sem esta função.
  // O reset pode ser implementado manualmente ou de outras formas.
  //
  // Para implementar no futuro:
  // 1. Executar: firebase init functions
  // 2. Escolher TypeScript
  // 3. Configurar Blaze plan no Firebase Console
  // 4. Implementar conforme especificação em .kiro/specs/ranking-system/design.md
  // ============================================================================

  // Métodos privados - Error Handlers

  /// Converte erros de autenticação Firebase em mensagens amigáveis
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      default:
        return 'Erro de autenticação. Faça login novamente.';
    }
  }

  /// Converte erros do Firestore em mensagens amigáveis
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

  /// Carrega dados mockados como fallback
  /// 
  /// Usado quando o Firebase não está disponível ou há erro no carregamento.
  /// Limpa o errorMessage e carrega dados de exemplo para permitir testes
  /// e desenvolvimento sem Firebase configurado.
  void _loadMockData() {
    leaderboardData.value = LeaderboardMocks.mockLeaderboardData;
    currentUserRank.value = LeaderboardMocks.mockCurrentUserRank;
    currentLeague.value = LeaderboardMocks.mockCurrentLeague;
    daysRemaining.value = LeaderboardMocks.mockDaysRemaining;
    weekStartDate.value = _getWeekStartDate();
    weekEndDate.value = _getWeekEndDate();
    errorMessage.value = ''; // Limpar erro ao carregar mocks com sucesso
  }
}
