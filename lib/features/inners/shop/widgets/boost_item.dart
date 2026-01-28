import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';

/// Item de boost (XP Booster, Gem Multiplier)
class BoostItem extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String description;
  final int price;
  final int? oldPrice;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const BoostItem({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.price,
    this.oldPrice,
    this.badge,
    this.badgeColor,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null || isLoading;
    
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDisabled ? AppTheme.gray400 : AppTheme.gray600, 
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Ícone ou loading
              if (isLoading)
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                )
              else
                Image.asset(iconAsset, width: 48, height: 48),
              const SizedBox(width: 12),

              // Título e descrição
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.textMdBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTheme.textSmRegular.copyWith(
                        color: AppTheme.gray300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Badge ou preço
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppTheme.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: AppTheme.textXsBold.copyWith(color: AppTheme.white),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Preço com gem
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppAssets.appbarGem, width: 18, height: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$price',
                        style: AppTheme.textMdBold.copyWith(color: AppTheme.red),
                      ),
                    ],
                  ),

                  // Preço antigo riscado
                  if (oldPrice != null)
                    Text(
                      '$oldPrice',
                      style: AppTheme.textSmRegular.copyWith(
                        color: AppTheme.gray400,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
