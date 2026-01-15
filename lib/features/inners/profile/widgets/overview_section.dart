import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import 'overview_card.dart';

/// Seção de overview do perfil (Total XP, Day streak, etc)
class OverviewSection extends StatelessWidget {
  final int xp;
  final int streak;
  final int level;
  final String flagAsset;

  const OverviewSection({
    super.key,
    required this.xp,
    required this.streak,
    required this.level,
    required this.flagAsset,
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

          Row(
            children: [
              Expanded(
                child: OverviewCard(
                  iconAsset: AppAssets.treasureXpCoin,
                  value: '$xp',
                  label: 'XP Total',
                  iconSize: 45,
                  starColor: AppTheme.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OverviewCard(
                  iconAsset: AppAssets.appbarFire,
                  value: '$streak',
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
                  iconAsset: flagAsset,
                  value: '$level',
                  label: 'Nível de Francês',
                  iconSize: 30,
                  starColor: AppTheme.red,
                ),
              ),
              const SizedBox(width: 12),
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
