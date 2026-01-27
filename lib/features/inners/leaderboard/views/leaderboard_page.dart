import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/leaderboard_controller.dart';
import '../widgets/leaderboard_header.dart';
import '../widgets/league_info.dart';
import '../widgets/rank_item.dart';
import '../widgets/status_modal.dart';

/// Página do ranking
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late final LeaderboardController _controller;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<LeaderboardController>();
    _controller.loadLeaderboardData();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Obx(() {
        // Loading state
        if (_controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: r.value(
                mobile: 3.0,
                tablet: 4.0,
                desktop: 4.0,
              ),
            ),
          );
        }

        // Error state
        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(r.spacing24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.triangleExclamation,
                    size: r.value(
                      mobile: 48,
                      tablet: 56,
                      desktop: 64,
                    ),
                    color: AppTheme.orange,
                  ),
                  SizedBox(height: r.spacing16),
                  Text(
                    _controller.errorMessage.value,
                    style: AppTheme.textMdMedium.copyWith(
                      color: AppTheme.gray700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: r.spacing24),
                  AppButton(
                    text: 'Tentar novamente',
                    onPressed: () => _controller.loadLeaderboardData(),
                  ),
                ],
              ),
            ),
          );
        }

        // Success state
        return CustomScrollView(
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
              currentLevel: _getLeagueIndex(_controller.currentLeague.value),
              onLeagueSelected: (index) {
                final league = _getLeagueFromIndex(index);
                _controller.switchLeague(league);
              },
            ),

            // Info da liga
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: r.spacing8),
                  LeagueInfo(
                    leagueName: _getLeagueName(_controller.currentLeague.value),
                    daysLeft: _controller.daysRemaining.value,
                    description: _getLeagueDescription(_controller.currentLeague.value),
                  ),
                  SizedBox(height: r.spacing16),
                ],
              ),
            ),

            // Lista de ranking
            _buildRankingList(),

            // Espaço para bottom bar
            SliverToBoxAdapter(
              child: SizedBox(height: r.spacing16),
            ),
          ],
        );
      }),
    );
  }

  // Widgets
  Widget _buildRankingList() {
    return Obx(() {
      final players = _controller.leaderboardData;

      if (players.isEmpty) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.userGroup,
                    size: 64,
                    color: AppTheme.gray300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aguardando formação de grupo',
                    style: AppTheme.textLgBold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Você será adicionado a um grupo de competição em breve. Continue completando lições para ganhar XP!',
                    style: AppTheme.textMdMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final player = players[index];
            final isMe = player['isCurrentUser'] == true;

            return RankItem(
              rank: player['rank'] as int,
              avatarAsset: player['avatar'] as String,
              name: player['name'] as String,
              xp: player['weeklyXP'] as int,
              isCurrentUser: isMe,
              statusEmoji: player['userStatus'] as String?,
              onTap: isMe
                  ? () => StatusModal.show(
                        context,
                        currentAvatar: player['avatar'] as String,
                        currentStatus: player['userStatus'] as String?,
                        controller: _controller,
                      )
                  : null,
            );
          },
          childCount: players.length,
        ),
      );
    });
  }

  // Helper methods
  String _getLeagueName(String league) {
    switch (league) {
      case 'bronze':
        return 'Liga Bronze';
      case 'silver':
        return 'Liga Prata';
      case 'gold':
        return 'Liga Ouro';
      case 'platinum':
        return 'Liga Platina';
      case 'diamond':
        return 'Liga Diamante';
      default:
        return 'Liga';
    }
  }

  String _getLeagueDescription(String league) {
    switch (league) {
      case 'bronze':
        return 'Os 3 melhores avançam para a Liga Prata!';
      case 'silver':
        return 'Os 3 melhores avançam para a Liga Ouro!';
      case 'gold':
        return 'Os 3 melhores avançam para a Liga Platina!';
      case 'platinum':
        return 'Os 3 melhores avançam para a Liga Diamante!';
      case 'diamond':
        return 'Você está na liga mais alta! Continue competindo!';
      default:
        return 'Compete e avance para a próxima liga!';
    }
  }

  int _getLeagueIndex(String league) {
    switch (league) {
      case 'bronze':
        return 0;
      case 'silver':
        return 1;
      case 'gold':
        return 2;
      case 'platinum':
        return 3;
      case 'diamond':
        return 4;
      default:
        return 0;
    }
  }

  String _getLeagueFromIndex(int index) {
    switch (index) {
      case 0:
        return 'bronze';
      case 1:
        return 'silver';
      case 2:
        return 'gold';
      case 3:
        return 'platinum';
      case 4:
        return 'diamond';
      default:
        return 'bronze';
    }
  }
}
