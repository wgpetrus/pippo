import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';

/// Banner header do Treasure Hunt
class TreasureHeader extends StatelessWidget {
  const TreasureHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Container(
      margin: EdgeInsets.all(r.spacing16),
      height: ResponsiveUtils.height(180, min: 140, max: 220),
      decoration: BoxDecoration(
        color: AppTheme.pink,
        borderRadius: BorderRadius.circular(r.spacing24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r.spacing24),
        child: Stack(
          children: [
            // Conteúdo
            Padding(
              padding: EdgeInsets.all(r.spacing16),
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
                            color: AppTheme.white90,
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
              right: r.spacing16,
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
