import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';

/// Header de unidade com título e botão de lista
class UnitHeader extends StatelessWidget {
  final String unitNumber;
  final String title;
  final VoidCallback? onListTap;

  const UnitHeader({
    super.key,
    required this.unitNumber,
    required this.title,
    this.onListTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onListTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDark.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone de pata
            Image.asset(
              AppAssets.iconPaw,
              width: 40,
              height: 40,
            ),

            const SizedBox(width: 12),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unitNumber,
                    style: AppTheme.textSmMedium.copyWith(
                      color: AppTheme.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: AppTheme.textLgBold.copyWith(color: AppTheme.white),
                  ),
                ],
              ),
            ),

            // Botão de lista
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.bars,
                  color: AppTheme.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
