import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
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
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        surfaceTintColor: AppTheme.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Loja', style: AppTheme.displaySmBold),
        titleSpacing: 20,
        centerTitle: false,
        actions: [
          // Contador de gems
          // TODO: Substituir valor hardcoded por controller.gems.value
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Image.asset(AppAssets.appbarGem, width: 24, height: 24),
                const SizedBox(width: 6),
                Text(
                  '650',
                  style: AppTheme.textLgBold.copyWith(color: AppTheme.red),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    );
  }

  // Widgets
  Widget _buildYourPacks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Seus pacotes', style: AppTheme.textLgBold),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShopItemCard(
                iconAsset: AppAssets.shopElixirXp,
                label: 'Boost de XP x10',
              ),
              const SizedBox(width: 12),
              ShopItemCard(
                iconAsset: AppAssets.shopChest,
                label: 'Pular Lição x5',
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
          child: Text('Oferta especial', style: AppTheme.textLgBold),
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
                price: '\$ GRÁTIS',
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
          child: SectionTitle(emoji: '🚀', title: 'Boosts de Aprendizado'),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              BoostItem(
                iconAsset: AppAssets.shopElixirXp,
                title: 'Boost de XP',
                description: 'Ganhe 2× gemas nas lições!',
                price: 420,
                oldPrice: 20,
              ),
              const SizedBox(height: 12),
              BoostItem(
                iconAsset: AppAssets.shopElixir2x,
                title: 'Multiplicador de Gemas',
                description: 'Ganhe 2× gemas nas lições!',
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
          child: SectionTitle(emoji: '🎨', title: 'Personalização e Colecionáveis'),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              CollectibleItem(
                iconAsset: AppAssets.shopGemPot,
                title: 'Skins do Mascote',
                price: '\$ 4.99',
                oldPrice: '20',
                badge: 'NOVO',
                badgeColor: AppTheme.primary,
              ),
              const SizedBox(height: 12),
              CollectibleItem(
                iconAsset: AppAssets.shopChest,
                title: 'Pacotes de Emblemas',
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
