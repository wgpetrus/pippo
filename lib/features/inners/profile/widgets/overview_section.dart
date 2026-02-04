import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../../home/controllers/home_controller.dart';
import 'overview_card.dart';

/// Seção de overview do perfil (Total XP, Day streak, etc)
///
/// Suporta dois modos:
/// - useOwnStats = true: dados reativos do GamificationController
/// - useOwnStats = false: dados estáticos passados por parâmetro
class OverviewSection extends StatelessWidget {
  // Propriedades
  final String flagAsset;
  final bool useOwnStats;
  final int? totalXp;
  final int? currentStreak;
  final int? longestStreak;
  final int? level;

  const OverviewSection({
    super.key,
    required this.flagAsset,
    this.useOwnStats = true,
    this.totalXp,
    this.currentStreak,
    this.longestStreak,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Visão Geral', style: AppTheme.textLgBold),
          const SizedBox(height: 12),
          _buildStatsGrid(),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildStatsGrid() {
    if (useOwnStats) {
      return _buildReactiveStats();
    }
    return _buildStaticStats();
  }

  Widget _buildReactiveStats() {
    final gamification = Get.find<GamificationController>();
    final homeController = Get.find<HomeController>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => OverviewCard(
                  iconAsset: AppAssets.treasureXpCoin,
                  value: '${gamification.totalXp.value}',
                  label: 'XP Total',
                  iconSize: 45,
                  starColor: AppTheme.gold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => OverviewCard(
                  iconAsset: AppAssets.appbarFire,
                  value: '${gamification.currentStreak.value}',
                  label: 'Dias de sequência',
                  iconSize: 45,
                  starColor: AppTheme.orange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => OverviewCard(
                  iconAsset: AppAssets.appbarFire,
                  value: '${gamification.longestStreak.value}',
                  label: 'Maior sequência',
                  iconSize: 45,
                  starColor: AppTheme.red,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => OverviewCard(
                  iconAsset: flagAsset,
                  value: '${gamification.level.value}',
                  label:
                      'Nível de ${homeController.activeCourseName.value.isNotEmpty ? homeController.activeCourseName.value : 'Idioma'}',
                  iconSize: 30,
                  starColor: AppTheme.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OverviewCard(
                imageAsset: AppAssets.profileWarrior1,
                value: '',
                label: 'Guerreiro das Palavras',
                iconSize: 90,
                starColor: AppTheme.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaticStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OverviewCard(
                iconAsset: AppAssets.treasureXpCoin,
                value: '${totalXp ?? 0}',
                label: 'XP Total',
                iconSize: 45,
                starColor: AppTheme.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OverviewCard(
                iconAsset: AppAssets.appbarFire,
                value: '${currentStreak ?? 0}',
                label: 'Dias de sequência',
                iconSize: 45,
                starColor: AppTheme.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OverviewCard(
                iconAsset: AppAssets.appbarFire,
                value: '${longestStreak ?? 0}',
                label: 'Maior sequência',
                iconSize: 45,
                starColor: AppTheme.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OverviewCard(
                iconAsset: flagAsset,
                value: '${level ?? 1}',
                label: 'Nível de Francês',
                iconSize: 30,
                starColor: AppTheme.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OverviewCard(
                imageAsset: AppAssets.profileWarrior1,
                value: '',
                label: 'Guerreiro das Palavras',
                iconSize: 90,
                starColor: AppTheme.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
