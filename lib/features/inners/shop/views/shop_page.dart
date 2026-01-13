import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../home/controllers/home_controller.dart';
import '../../../../shared/widgets/app_bottombar.dart';
import '../widgets/boost_item.dart';
import '../widgets/collectible_item.dart';
import '../widgets/section_title.dart';
import '../widgets/shop_item_card.dart';

/// Página da loja
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  // Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Stack(
        children: [
          // Conteúdo scrollável
          SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(top: 60, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const AppPageHeader(title: 'Shop', gemCount: 650),
                const SizedBox(height: 24),

                // Your packs
                _buildYourPacks(),
                const SizedBox(height: 32),

                // Spatial offer (espaço extra para badge NEW)
                _buildSpatialOffer(),
                const SizedBox(height: 24),

                // Learning Boosts
                _buildLearningBoosts(),
                const SizedBox(height: 24),

                // Customization & Collectibles
                _buildCustomization(),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() => AppBottombar(
              currentIndex: controller.currentNavIndex.value,
              avatarAsset: AppAssets.charDiogo,
              onTap: controller.onNavTap,
            )),
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildYourPacks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Your packs', style: AppTheme.textLgBold),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShopItemCard(
                iconAsset: AppAssets.shopElixirXp,
                label: 'XP Booster x10',
              ),
              const SizedBox(width: 12),
              ShopItemCard(
                iconAsset: AppAssets.shopChest,
                label: 'Lesson Skip x5',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpatialOffer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Spatial offer', style: AppTheme.textLgBold),
        ),
        const SizedBox(height: 16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShopItemCard(
                iconAsset: AppAssets.shopGemCar,
                label: '1600',
                price: '\$ 4.99',
                backgroundColor: AppTheme.primary100,
                borderColor: AppTheme.primary,
                priceColor: AppTheme.primary,
                badge: 'NEW',
                badgeColor: AppTheme.primary,
              ),
              const SizedBox(width: 12),
              ShopItemCard(
                iconAsset: AppAssets.shopChest,
                label: '100',
                price: '\$ FREE',
                backgroundColor: AppTheme.green100,
                borderColor: AppTheme.green,
                priceColor: AppTheme.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningBoosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(emoji: '🚀', title: 'Learning Boosts'),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              BoostItem(
                iconAsset: AppAssets.shopElixirXp,
                title: 'XP Booster',
                description: 'Earn 2× gems from lessons!',
                price: 420,
                oldPrice: 20,
              ),
              const SizedBox(height: 12),
              BoostItem(
                iconAsset: AppAssets.shopElixir2x,
                title: 'Gem Multiplier',
                description: 'Earn 2× gems from lessons!',
                price: 50,
                badge: 'POPULAR',
                badgeColor: AppTheme.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(emoji: '🎨', title: 'Customization & Collectibles'),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              CollectibleItem(
                iconAsset: AppAssets.shopGemPot,
                title: 'Mascot Skins',
                price: '\$ 4.99',
                oldPrice: '20',
                badge: 'NEW',
                badgeColor: AppTheme.primary,
              ),
              const SizedBox(height: 12),
              CollectibleItem(
                iconAsset: AppAssets.shopChest,
                title: 'Badge Packs',
                price: '\$ 8',
                oldPrice: '20',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
