import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';

/// Dados de um pack de gems
class GemPackData {
  final String iconAsset;
  final int gems;
  final String price;
  final String? oldPrice;
  final bool isHighlighted;
  final String? badge;
  final double iconSize;

  const GemPackData({
    required this.iconAsset,
    required this.gems,
    required this.price,
    this.oldPrice,
    this.isHighlighted = false,
    this.badge,
    this.iconSize = 48,
  });
}

/// Modal de compra de Gems
class GemsModal extends StatelessWidget {
  final int currentGems;
  final List<GemPackData> packs;
  final VoidCallback? onGoToShop;
  final Function(GemPackData)? onPackTap;

  const GemsModal({
    super.key,
    required this.currentGems,
    required this.packs,
    this.onGoToShop,
    this.onPackTap,
  });

  // Build
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Invest in gems, invest in your learning fun.',
              style: AppTheme.textMdMedium.copyWith(color: AppTheme.gray400),
            ),
            const SizedBox(height: 20),

            // Packs de gems
            ...packs.map((pack) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GemPackCard(
                pack: pack,
                onTap: () => onPackTap?.call(pack),
              ),
            )),
            const SizedBox(height: 8),

            // Botão Go to shop
            AppButton(
              text: 'Go to shop',
              isPrimary: false,
              onPressed: onGoToShop,
            ),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Gems', style: AppTheme.displayXsBold),
        Row(
          children: [
            Image.asset(AppAssets.appbarGem, width: 28, height: 28),
            const SizedBox(width: 6),
            Text(
              currentGems.toString(),
              style: AppTheme.textXlBold.copyWith(color: AppTheme.red),
            ),
          ],
        ),
      ],
    );
  }

  // Métodos estáticos
  static void show(
    BuildContext context, {
    required int currentGems,
    required List<GemPackData> packs,
    VoidCallback? onGoToShop,
    Function(GemPackData)? onPackTap,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GemsModal(
              currentGems: currentGems,
              packs: packs,
              onGoToShop: () {
                Navigator.of(ctx).pop();
                onGoToShop?.call();
              },
              onPackTap: (pack) {
                Navigator.of(ctx).pop();
                onPackTap?.call(pack);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Card de pack de gems
class _GemPackCard extends StatelessWidget {
  final GemPackData pack;
  final VoidCallback? onTap;

  const _GemPackCard({
    required this.pack,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = pack.isHighlighted ? AppTheme.pink100 : AppTheme.white;
    final borderColor = pack.isHighlighted ? AppTheme.pink : AppTheme.gray600;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: borderColor,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Ícone do pack
                Image.asset(
                  pack.iconAsset,
                  width: pack.iconSize,
                  height: pack.iconSize,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),

                // Quantidade
                Text(
                  '${pack.gems}',
                  style: AppTheme.displayXsBold,
                ),
                const Spacer(),

                // Preço
                _buildPrice(),
              ],
            ),
          ),

          // Badge
          if (pack.badge != null)
            Positioned(
              top: -8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.pink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pack.badge!,
                  style: AppTheme.textSmBold.copyWith(color: AppTheme.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    if (pack.oldPrice != null) {
      return Row(
        children: [
          Text(
            pack.price,
            style: AppTheme.textXlBold.copyWith(color: AppTheme.red),
          ),
          const SizedBox(width: 6),
          Text(
            pack.oldPrice!,
            style: AppTheme.textMdMedium.copyWith(
              color: AppTheme.gray400,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }

    return Text(
      pack.price,
      style: AppTheme.textXlBold.copyWith(color: AppTheme.red),
    );
  }
}
