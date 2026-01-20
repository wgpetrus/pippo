import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../gamification/controllers/gamification_controller.dart';
import 'overview_card.dart';

/// Seção de overview do perfil (Total XP, Day streak, etc)
class OverviewSection extends StatelessWidget {
  final String flagAsset;

  const OverviewSection({
    super.key,
    required this.flagAsset,
  });

  @override
  Widget build(BuildContext context) {
    final gamification = Get.find<GamificationController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Visão Geral', style: AppTheme.textLgBold),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Obx(() => OverviewCard(
                  iconAsset: AppAssets.treasureXpCoin,
                  value: '${gamification.totalXp.value}',
                  label: 'XP Total',
                  iconSize: 45,
                  starColor: AppTheme.gold,
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => OverviewCard(
                  iconAsset: AppAssets.appbarFire,
                  value: '${gamification.currentStreak.value}',
                  label: 'Dias de sequência',
                  iconSize: 45,
                  starColor: AppTheme.orange,
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Obx(() => OverviewCard(
                  iconAsset: AppAssets.appbarFire,
                  value: '${gamification.longestStreak.value}',
                  label: 'Maior sequência',
                  iconSize: 45,
                  starColor: AppTheme.red,
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => OverviewCard(
                  iconAsset: flagAsset,
                  value: '${gamification.level.value}',
                  label: 'Nível de Francês',
                  iconSize: 30,
                  starColor: AppTheme.blue,
                )),
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
      ),
    );
  }
}
