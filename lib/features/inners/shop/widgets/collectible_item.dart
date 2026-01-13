import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';

/// Item de colecionável (Mascot Skins, Badge Packs)
class CollectibleItem extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String price;
  final String? oldPrice;
  final String? badge;
  final Color? badgeColor;
  final double iconSize;
  final VoidCallback? onTap;

  const CollectibleItem({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.price,
    this.oldPrice,
    this.badge,
    this.badgeColor,
    this.iconSize = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gray600, width: 1.5),
        ),
        child: Row(
          children: [
            // Ícone
            Image.asset(iconAsset, width: iconSize, height: iconSize),
            const SizedBox(width: 12),

            // Título
            Expanded(
              child: Text(title, style: AppTheme.textMdBold),
            ),

            // Badge
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: AppTheme.textXsBold.copyWith(color: AppTheme.white),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Preço
            Row(
              children: [
                Text(
                  price,
                  style: AppTheme.textMdBold.copyWith(color: AppTheme.green),
                ),
                if (oldPrice != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    oldPrice!,
                    style: AppTheme.textSmRegular.copyWith(
                      color: AppTheme.gray400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
