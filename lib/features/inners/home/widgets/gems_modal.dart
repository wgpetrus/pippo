import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../gamification/controllers/gems_controller.dart';

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
  final VoidCallback? onGoToShop;

  const GemsModal({
    super.key,
    this.onGoToShop,
  });

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final gemsController = Get.find<GemsController>();
    
    // Calcular altura máxima disponível (80% da tela)
    final maxHeight = r.heightScreen * 0.8;

    // TODO: Replace with real IAP (In-App Purchase) data from ShopController
    // MOCK DATA: Placeholder gem packs for UI testing
    final packs = [
      GemPackData(
        iconAsset: AppAssets.shopGemPot,
        gems: 100,
        price: 'R\$ 4,99',
        iconSize: r.value(mobile: 48, tablet: 56, desktop: 64),
      ),
      GemPackData(
        iconAsset: AppAssets.shopGemCar,
        gems: 500,
        price: 'R\$ 19,99',
        oldPrice: 'R\$ 24,99',
        badge: 'home_gems_modal_pack_most_popular'.tr,
        isHighlighted: true,
        iconSize: r.value(mobile: 56, tablet: 64, desktop: 72),
      ),
      GemPackData(
        iconAsset: AppAssets.shopChest,
        gems: 1000,
        price: 'R\$ 34,99',
        oldPrice: 'R\$ 49,99',
        badge: 'home_gems_modal_pack_best_value'.tr,
        isHighlighted: true,
        iconSize: r.value(mobile: 64, tablet: 72, desktop: 80),
      ),
    ];

    return Obx(() {
      final currentGems = gemsController.gems.value;
      final totalGemsEarned = gemsController.totalGemsEarned.value;
      
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(r.value(mobile: 24, tablet: 28, desktop: 32)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(r.spacing16, r.spacing24, r.spacing16, r.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(currentGems, r),
                SizedBox(height: r.spacing8),

                // Total earned
                Text(
                  'home_gems_modal_total_earned'.tr.replaceAll('{count}', totalGemsEarned.toString()),
                  style: AppTheme.textSmMedium.copyWith(color: AppTheme.gray400),
                ),
                SizedBox(height: r.spacing4),

                // Subtítulo
                Text(
                  'home_gems_modal_subtitle'.tr,
                  style: AppTheme.textMdMedium.copyWith(color: AppTheme.gray400),
                ),
                SizedBox(height: r.spacing16),

                // Packs de gems (IAP placeholder)
                ...packs.map((pack) => Padding(
                  padding: EdgeInsets.only(bottom: r.spacing12),
                  child: _GemPackCard(
                    pack: pack,
                    onTap: () {
                      // TODO: Implementar IAP (In-App Purchase)
                      Get.snackbar(
                        'home_gems_modal_coming_soon'.tr,
                        'home_gems_modal_iap_message'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.primary,
                        colorText: AppTheme.white,
                        margin: EdgeInsets.all(r.spacing16),
                      );
                    },
                  ),
                )),
                SizedBox(height: r.spacing8),

                // Botão Go to shop
                AppButton(
                  text: 'home_gems_modal_go_to_shop'.tr,
                  isPrimary: false,
                  onPressed: onGoToShop,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Widgets
  Widget _buildHeader(int currentGems, ResponsiveUtils r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('home_gems_modal_title'.tr, style: AppTheme.displayXsBold),
        Row(
          children: [
            Image.asset(AppAssets.appbarGem, width: r.value(mobile: 28, tablet: 32, desktop: 36), height: r.value(mobile: 28, tablet: 32, desktop: 36)),
            SizedBox(width: r.spacing4),
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
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onGoToShop,
  }) async {
    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: GemsModal(
            onGoToShop: () {
              Navigator.of(context).pop();
              onGoToShop?.call();
            },
          ),
        ),
      ],
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
    final r = ResponsiveUtils(context);
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
            padding: EdgeInsets.symmetric(horizontal: r.spacing16, vertical: r.spacing12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(r.value(mobile: 20, tablet: 24, desktop: 28)),
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
                SizedBox(width: r.spacing16),

                // Quantidade
                Text(
                  '${pack.gems}',
                  style: AppTheme.displayXsBold,
                ),
                const Spacer(),

                // Preço
                _buildPrice(r),
              ],
            ),
          ),

          // Badge
          if (pack.badge != null)
            Positioned(
              top: -8,
              right: r.spacing16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: r.spacing12, vertical: r.spacing4),
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

  Widget _buildPrice(ResponsiveUtils r) {
    if (pack.oldPrice != null) {
      return Row(
        children: [
          Text(
            pack.price,
            style: AppTheme.textXlBold.copyWith(color: AppTheme.red),
          ),
          SizedBox(width: r.spacing4),
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
