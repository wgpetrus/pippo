import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../widgets/leaderboard_header.dart';
import '../widgets/league_info.dart';
import '../widgets/rank_item.dart';
import '../widgets/status_modal.dart';

/// Página do ranking
class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  // Dados mockados
  static const _players = [
    {'avatar': AppAssets.charMara, 'name': 'Sami', 'xp': 49, 'status': null},
    {'avatar': AppAssets.charFrancilene, 'name': 'Eu', 'xp': 49, 'status': '🎭', 'isMe': true},
    {'avatar': AppAssets.charGlauciane, 'name': 'Haruto', 'xp': 49, 'status': '😊'},
    {'avatar': AppAssets.charLindoedson, 'name': 'Hakan', 'xp': 49, 'status': null},
    {'avatar': AppAssets.charRenner, 'name': 'Mayumi', 'xp': 49, 'status': '😊'},
    {'avatar': AppAssets.charDafny, 'name': 'Yuki', 'xp': 45, 'status': null},
    {'avatar': AppAssets.charDiogo, 'name': 'Carlos', 'xp': 42, 'status': '🔥'},
    {'avatar': AppAssets.charMara, 'name': 'Luna', 'xp': 40, 'status': null},
    {'avatar': AppAssets.charGlauciane, 'name': 'Akira', 'xp': 38, 'status': '😎'},
    {'avatar': AppAssets.charLindoedson, 'name': 'Sofia', 'xp': 35, 'status': null},
    {'avatar': AppAssets.charRenner, 'name': 'Kenji', 'xp': 32, 'status': '🎯'},
    {'avatar': AppAssets.charFrancilene, 'name': 'Maria', 'xp': 30, 'status': null},
    {'avatar': AppAssets.charDafny, 'name': 'Takeshi', 'xp': 28, 'status': null},
    {'avatar': AppAssets.charDiogo, 'name': 'Ana', 'xp': 25, 'status': '💪'},
    {'avatar': AppAssets.charMara, 'name': 'Ryu', 'xp': 22, 'status': null},
  ];

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header colapsável com escudos
          LeaderboardHeader(
            title: 'Ranking',
            shieldAssets: [
              AppAssets.shield1,
              AppAssets.shield2,
              AppAssets.shield3,
              AppAssets.shield4,
              AppAssets.shield5,
              AppAssets.shield6,
            ],
            currentLevel: 2,
          ),

          // Info da liga
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 8),
                LeagueInfo(
                  leagueName: 'Liga Chama',
                  daysLeft: 6,
                  description: 'A próxima liga aguarda os 15 melhores competidores.',
                ),
                SizedBox(height: 16),
              ],
            ),
          ),

          // Lista de ranking
          _buildRankingList(),

          // Espaço para bottom bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildRankingList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final player = _players[index];
          final isMe = player['isMe'] == true;

          return RankItem(
            rank: index + 1,
            avatarAsset: player['avatar'] as String,
            name: player['name'] as String,
            xp: player['xp'] as int,
            isCurrentUser: isMe,
            statusEmoji: player['status'] as String?,
            onTap: isMe
                ? () => StatusModal.show(
                      context,
                      currentAvatar: player['avatar'] as String,
                      currentStatus: player['status'] as String?,
                      onStatusSelected: (status) {
                        // TODO: Salvar status selecionado
                      },
                    )
                : null,
          );
        },
        childCount: _players.length,
      ),
    );
  }
}
