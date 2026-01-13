import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';

/// Banner header do Treasure Hunt
class TreasureHeader extends StatelessWidget {
  const TreasureHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.pink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Texto (título no top, descrição no bottom)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título no topo
                        Text(
                          'Treasure Hunt',
                          style: AppTheme.displayXsExtrabold.copyWith(color: AppTheme.white),
                        ),
                        
                        const Spacer(),
                        
                        // Descrição no bottom
                        Text(
                          'Where every challenge\nleads to a reward.',
                          style: AppTheme.textSmRegular.copyWith(
                            color: AppTheme.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mascote treasure hunter (máximo tamanho)
            Positioned(
              right: 20,
              bottom: 0,
              top: 0,
              child: Image.asset(
                AppAssets.mascotTreasure,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
