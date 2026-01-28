import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../controllers/shop_controller.dart';
import '../widgets/boost_item.dart';
import '../widgets/collectible_item.dart';
import '../widgets/section_title.dart';
import '../widgets/shop_item_card.dart';

/// Página da loja
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final controller = Get.put(ShopController());
    final gamification = Get.find<GamificationController>();
    
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
          // Contador de gems com loading
          Obx(() {
            final isLoading = gamification.isLoading.value;
            
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  Image.asset(AppAssets.appbarGem, width: 24, height: 24),
                  const SizedBox(width: 6),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    )
                  else
                    Text(
                      '${gamification.gems.value}',
                      style: AppTheme.textLgBold.copyWith(color: AppTheme.red),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.only(top: r.spacing16, bottom: r.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your packs
            _buildYourPacks(r),
            SizedBox(height: r.spacing32),

            // Spatial offer (espaço extra para badge NEW)
            _buildSpatialOffer(r),
            SizedBox(height: r.spacing24),

            // Learning Boosts
            _buildLearningBoosts(r),
            SizedBox(height: r.spacing24),

            // Customization & Collectibles
            _buildCustomization(r),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _buildYourPacks(ResponsiveUtils r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16 + 4),
          child: const Text('Seus pacotes', style: AppTheme.textLgBold),
        ),
        SizedBox(height: r.spacing12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: r.spacing16 + 4),
          child: Row(
            children: [
              ShopItemCard(
                iconAsset: AppAssets.shopElixirXp,
                label: 'Boost de XP x10',
              ),
              SizedBox(width: r.spacing12),
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

  Widget _buildSpatialOffer(ResponsiveUtils r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16 + 4),
          child: const Text('Oferta especial', style: AppTheme.textLgBold),
        ),
        SizedBox(height: r.spacing16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.symmetric(horizontal: r.spacing16 + 4),
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
              SizedBox(width: r.spacing12),
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

  Widget _buildLearningBoosts(ResponsiveUtils r) {
    final controller = Get.find<ShopController>();
    final gamification = Get.find<GamificationController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16 + 4),
          child: const SectionTitle(emoji: '🚀', title: 'Boosts de Aprendizado'),
        ),
        SizedBox(height: r.spacing12),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16 + 4),
          child: Obx(() {
            final isLoading = gamification.isLoading.value;
            
            return Column(
              children: [
                // Recarga de Energia - 100 gems
                BoostItem(
                  iconAsset: AppAssets.appbarRay,
                  title: 'Recarga de Energia',
                  description: 'Recarregue 5 energias instantaneamente!',
                  price: 100,
                  isLoading: isLoading,
                  onTap: isLoading ? null : controller.purchaseEnergyRefill,
                ),
                SizedBox(height: r.spacing12),
                
                // XP Booster - 150 gems
                Builder(
                  builder: (context) {
                    final isActive = gamification.hasXpBooster;
                    final timeRemaining = gamification.getXpBoosterTimeRemaining();
                    final description = timeRemaining.isNotEmpty
                        ? 'Ativo! $timeRemaining'
                        : 'Ganhe 2× XP nas lições por 1 hora!';
                    
                    return BoostItem(
                      iconAsset: AppAssets.shopElixirXp,
                      title: 'Boost de XP',
                      description: description,
                      price: 150,
                      badge: isActive ? 'ATIVO' : null,
                      badgeColor: isActive ? AppTheme.green : null,
                      isLoading: isLoading,
                      onTap: (isActive || isLoading) ? null : controller.purchaseXpBooster,
                    );
                  }
                ),
                SizedBox(height: r.spacing12),
                
                // Gem Multiplier - 200 gems
                Builder(
                  builder: (context) {
                    final isActive = gamification.hasGemMultiplier;
                    final timeRemaining = gamification.getGemMultiplierTimeRemaining();
                    final description = timeRemaining.isNotEmpty
                        ? 'Ativo! $timeRemaining'
                        : 'Ganhe 2× gemas nas lições por 1 hora!';
                    
                    return BoostItem(
                      iconAsset: AppAssets.shopElixir2x,
                      title: 'Multiplicador de Gemas',
                      description: description,
                      price: 200,
                      badge: isActive ? 'ATIVO' : 'POPULAR',
                      badgeColor: isActive ? AppTheme.green : AppTheme.orange,
                      isLoading: isLoading,
                      onTap: (isActive || isLoading) ? null : () => controller.purchaseGemMultiplier(context),
                    );
                  }
                ),
                SizedBox(height: r.spacing12),
                
                // Streak Freeze - 200 gems
                Builder(
                  builder: (context) {
                    final isActive = gamification.streakFreezeAvailable;
                    
                    return BoostItem(
                      iconAsset: AppAssets.appbarFire,
                      title: 'Proteção de Streak',
                      description: 'Proteja seu streak por 1 dia!',
                      price: 200,
                      badge: isActive ? 'ATIVO' : null,
                      badgeColor: isActive ? AppTheme.green : null,
                      isLoading: isLoading,
                      onTap: (isActive || isLoading) ? null : () => controller.purchaseStreakFreeze(context),
                    );
                  }
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCustomization(ResponsiveUtils r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16 + 4),
          child: const SectionTitle(emoji: '🎨', title: 'Personalização e Colecionáveis'),
        ),
        SizedBox(height: r.spacing12),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16 + 4),
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
              SizedBox(height: r.spacing12),
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
