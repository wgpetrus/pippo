import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../widgets/challenge_card.dart';
import '../widgets/treasure_header.dart';

/// Página do treasure hunter
class TreasurePage extends StatelessWidget {
  const TreasurePage({super.key});

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        surfaceTintColor: AppTheme.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Caça ao Tesouro', style: AppTheme.displaySmBold),
        titleSpacing: 20,
      ),
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner header
            const TreasureHeader(),

            // Daily Challenges
            _buildSectionHeader('Desafios Diários', '6 horas restantes'),
            _buildDailyChallenges(),

            const SizedBox(height: 8),

            // Weekly Quests
            _buildSectionHeader('Missões Semanais', '2 dias restantes'),
            _buildWeeklyQuests(),
          ],
        ),
      ),
    );
  }

  // Widgets privados
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
            title: 'Complete 1 lição',
            current: 2,
            total: 2,
            rewardAsset: AppAssets.treasureChest,
            progressColor: AppTheme.primary,
          ),
          ChallengeCard(
            iconAsset: AppAssets.treasureTarget,
            title: 'Ganhe 50 XP',
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
            title: 'Termine 5 lições',
            current: 2,
            total: 2,
            rewardAsset: AppAssets.treasureChestGem,
            backgroundColor: AppTheme.pink100,
            borderColor: AppTheme.pink,
            progressColor: AppTheme.pink,
          ),
          ChallengeCard(
            iconAsset: AppAssets.treasureXpCoin,
            title: 'Mantenha 5 dias de sequência',
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
