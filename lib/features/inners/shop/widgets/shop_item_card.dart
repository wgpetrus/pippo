import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';

/// Card unificado para packs e ofertas da shop
class ShopItemCard extends StatelessWidget {
  final String iconAsset;
  final String? label;
  final String? price;
  final Color backgroundColor;
  final Color borderColor;
  final Color? priceColor;
  final String? badge;
  final Color? badgeColor;
  final double iconSize;
  final VoidCallback? onTap;

  const ShopItemCard({
    super.key,
    required this.iconAsset,
    this.label,
    this.price,
    this.backgroundColor = AppTheme.white,
    this.borderColor = AppTheme.gray600,
    this.priceColor,
    this.badge,
    this.badgeColor,
    this.iconSize = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card com borda inferior mais grossa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                top: BorderSide(color: borderColor, width: 2),
                left: BorderSide(color: borderColor, width: 2),
                right: BorderSide(color: borderColor, width: 2),
                bottom: BorderSide(color: borderColor, width: 4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(iconAsset, width: iconSize, height: iconSize),

                if (label != null) ...[
                  const SizedBox(width: 12),
                  Text(label!, style: AppTheme.textMdBold),
                ],

                if (price != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    price!,
                    style: AppTheme.textMdBold.copyWith(
                      color: priceColor ?? AppTheme.blue,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Badge (NEW, POPULAR, etc)
          if (badge != null)
            Positioned(
              top: -10,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: AppTheme.textXsBold.copyWith(color: AppTheme.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
