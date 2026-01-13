import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';

/// Card de overview (Total XP, Day streak, etc)
/// Borda cinza com borda inferior grossa para o label
class OverviewCard extends StatelessWidget {
  final String? iconAsset;
  final String? imageAsset;
  final String value;
  final String label;
  final bool showStar;
  final double iconSize;
  final Color starColor;

  const OverviewCard({
    super.key,
    this.iconAsset,
    this.imageAsset,
    required this.value,
    required this.label,
    this.showStar = true,
    this.iconSize = 32,
    this.starColor = AppTheme.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120, // Altura fixa para todos os cards
      decoration: BoxDecoration(
        color: AppTheme.gray600,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray600, width: 2),
      ),
      child: Column(
        children: [
          // Seção superior branca com conteúdo
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Stack(
                children: [
                  // Conteúdo centralizado
                  Center(child: _buildContent()),

                  // Estrela decorativa
                  if (showStar)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: SvgPicture.asset(
                        AppAssets.profileStar,
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          starColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Seção inferior cinza grossa com label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.gray600,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTheme.textSmBold.copyWith(color: AppTheme.gray200),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildContent() {
    // Se tem imagem (warrior)
    if (imageAsset != null) {
      return Image.asset(imageAsset!, width: iconSize, height: iconSize);
    }

    // Se tem ícone + valor
    if (iconAsset != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconAsset!, width: iconSize, height: iconSize),
          const SizedBox(width: 6),
          Text(value, style: AppTheme.displaySmBold),
        ],
      );
    }

    // Fallback só valor
    return Text(value, style: AppTheme.displaySmBold);
  }
}
