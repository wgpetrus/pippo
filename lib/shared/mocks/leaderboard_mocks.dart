import '../../shared/utils/app_assets.dart';

/// Mocks de leaderboard para desenvolvimento e testes
class LeaderboardMocks {
  /// Dados mockados do leaderboard com 10 usuários realistas
  /// Inclui variação de weeklyXP, alguns com status emoji, e um usuário atual
  static final List<Map<String, dynamic>> mockLeaderboardData = [
    {
      'rank': 1,
      'userId': 'user1',
      'name': 'Sami',
      'avatar': AppAssets.charMara,
      'weeklyXP': 520,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 2,
      'userId': 'currentUser',
      'name': 'Me',
      'avatar': AppAssets.charFrancilene,
      'weeklyXP': 495,
      'userStatus': '🎭',
      'isCurrentUser': true,
      'zone': 'promotion',
    },
    {
      'rank': 3,
      'userId': 'user3',
      'name': 'Haruto',
      'avatar': AppAssets.charGlauciane,
      'weeklyXP': 480,
      'userStatus': '😊',
      'isCurrentUser': false,
      'zone': 'promotion',
    },
    {
      'rank': 4,
      'userId': 'user4',
      'name': 'Hakan',
      'avatar': AppAssets.charLindoedson,
      'weeklyXP': 465,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'safe',
    },
    {
      'rank': 5,
      'userId': 'user5',
      'name': 'Mayumi',
      'avatar': AppAssets.charRenner,
      'weeklyXP': 450,
      'userStatus': '🔥',
      'isCurrentUser': false,
      'zone': 'safe',
    },
    {
      'rank': 6,
      'userId': 'user6',
      'name': 'Yuki',
      'avatar': AppAssets.charDafny,
      'weeklyXP': 420,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'safe',
    },
    {
      'rank': 7,
      'userId': 'user7',
      'name': 'Carlos',
      'avatar': AppAssets.charDiogo,
      'weeklyXP': 400,
      'userStatus': '😎',
      'isCurrentUser': false,
      'zone': 'safe',
    },
    {
      'rank': 8,
      'userId': 'user8',
      'name': 'Luna',
      'avatar': AppAssets.charMara,
      'weeklyXP': 380,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'demotion',
    },
    {
      'rank': 9,
      'userId': 'user9',
      'name': 'Akira',
      'avatar': AppAssets.charGlauciane,
      'weeklyXP': 360,
      'userStatus': '💪',
      'isCurrentUser': false,
      'zone': 'demotion',
    },
    {
      'rank': 10,
      'userId': 'user10',
      'name': 'Sofia',
      'avatar': AppAssets.charLindoedson,
      'weeklyXP': 340,
      'userStatus': null,
      'isCurrentUser': false,
      'zone': 'demotion',
    },
  ];

  /// Liga atual mockada
  static const String mockCurrentLeague = 'silver';

  /// Dias restantes na semana mockados
  static const int mockDaysRemaining = 6;

  /// Rank do usuário atual mockado
  static const int mockCurrentUserRank = 2;

  /// Retorna dados do leaderboard ordenados por weeklyXP
  static List<Map<String, dynamic>> getLeaderboardData() {
    // Retorna cópia para evitar modificações acidentais
    return List<Map<String, dynamic>>.from(mockLeaderboardData);
  }

  /// Retorna dados de um usuário específico por userId
  static Map<String, dynamic>? getUserData(String userId) {
    try {
      return mockLeaderboardData.firstWhere(
        (user) => user['userId'] == userId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Retorna dados do usuário atual
  static Map<String, dynamic>? getCurrentUserData() {
    try {
      return mockLeaderboardData.firstWhere(
        (user) => user['isCurrentUser'] == true,
      );
    } catch (e) {
      return null;
    }
  }

  /// Retorna usuários na zona de promoção (ranks 1-3)
  static List<Map<String, dynamic>> getPromotionZoneUsers() {
    return mockLeaderboardData
        .where((user) => user['zone'] == 'promotion')
        .toList();
  }

  /// Retorna usuários na zona segura (ranks 4-7)
  static List<Map<String, dynamic>> getSafeZoneUsers() {
    return mockLeaderboardData
        .where((user) => user['zone'] == 'safe')
        .toList();
  }

  /// Retorna usuários na zona de rebaixamento (ranks 8-10)
  static List<Map<String, dynamic>> getDemotionZoneUsers() {
    return mockLeaderboardData
        .where((user) => user['zone'] == 'demotion')
        .toList();
  }
}
