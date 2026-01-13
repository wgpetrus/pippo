import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../home/controllers/home_controller.dart';
import '../../../../shared/widgets/app_bottombar.dart';
import '../widgets/challenge_card.dart';
import '../widgets/treasure_header.dart';

/// Página do treasure hunter
class TreasurePage extends StatelessWidget {
  const TreasurePage({super.key});

  // Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Stack(
        children: [
          // Conteúdo scrollável
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 50, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner header
                const TreasureHeader(),

                // Daily Challenges
                _buildSectionHeader('Daily Challenges', '6 hours left'),
                _buildDailyChallenges(),

                const SizedBox(height: 8),

                // Weekly Quests
                _buildSectionHeader('Weekly Quests', '2 day left'),
                _buildWeeklyQuests(),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() => AppBottombar(
              currentIndex: controller.currentNavIndex.value,
              avatarAsset: AppAssets.charDiogo,
              onTap: controller.onNavTap,
            )),
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildSectionHeader(String title, String timeLeft) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.textLgBold),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.clock, size: 14, color: AppTheme.orange),
              const SizedBox(width: 6),
              Text(
                timeLeft,
                style: AppTheme.textSmSemibold.copyWith(color: AppTheme.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ChallengeCard(
            iconAsset: AppAssets.treasureBook,
            title: 'Complete 1 lesson',
            current: 2,
            total: 2,
            rewardAsset: AppAssets.treasureChest,
            progressColor: AppTheme.primary,
          ),
          ChallengeCard(
            iconAsset: AppAssets.treasureTarget,
            title: 'Earn 50 XP',
            current: 2,
            total: 2,
            rewardAsset: AppAssets.treasureChestGem,
            backgroundColor: AppTheme.pink100,
            borderColor: AppTheme.pink,
            progressColor: AppTheme.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyQuests() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ChallengeCard(
            iconAsset: AppAssets.treasureBook,
            title: 'Finish 5 lessons',
            current: 2,
            total: 2,
            rewardAsset: AppAssets.treasureChestGem,
            backgroundColor: AppTheme.pink100,
            borderColor: AppTheme.pink,
            progressColor: AppTheme.pink,
          ),
          ChallengeCard(
            iconAsset: AppAssets.treasureXpCoin,
            title: 'Maintain a 5-day streak',
            current: 0,
            total: 5,
            rewardAsset: AppAssets.treasureChest,
            progressColor: AppTheme.gray400,
          ),
        ],
      ),
    );
  }
}
