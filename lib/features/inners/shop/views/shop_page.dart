import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../gamification/controllers/energy_controller.dart';
import '../../gamification/controllers/gems_controller.dart';
import '../../gamification/controllers/streak_controller.dart';
import '../../gamification/controllers/xp_level_controller.dart';
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
    Get.put(ShopController());
    final gemsController = Get.find<GemsController>();
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        surfaceTintColor: AppTheme.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('shop_title'.tr, style: AppTheme.displaySmBold),
        titleSpacing: 20,
        centerTitle: false,
        actions: [
          // Contador de gems com loading
          Obx(() {
            final isLoading = gemsController.isLoading.value;
            
            return Padding(
              padding: EdgeInsets.only(right: r.spacing16),
              child: Row(
                children: [
                  Image.asset(AppAssets.appbarGem, width: r.spacing24, height: r.spacing24),
                  SizedBox(width: r.spacing4),
                  if (isLoading)
                    SizedBox(
                      width: r.spacing16,
                      height: r.spacing16,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    )
                  else
                    Text(
                      '${gemsController.gems.value}',
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
            // Seus pacotes
            _buildYourPacks(r),
            SizedBox(height: r.spacing32),

            // Oferta especial
            _buildSpatialOffer(r),
            SizedBox(height: r.spacing24),

            // Boosts de aprendizado
            _buildLearningBoosts(r),
            SizedBox(height: r.spacing24),

            // Personalização e colecionáveis
            _buildCustomization(r),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _buildYourPacks(ResponsiveUtils r) {
    final controller = Get.find<ShopController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: Text('shop_your_packs'.tr, style: AppTheme.textLgBold),
        ),
        SizedBox(height: r.spacing12),

        Obx(() {
          // Pacotes disponíveis
          final xpBoostQty = controller.getPackQuantity('xp_boost');
          final skipLessonQty = controller.getPackQuantity('skip_lesson');
          
          // Se não tem nenhum pacote, mostrar mensagem
          if (xpBoostQty == 0 && skipLessonQty == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: r.spacing16),
              child: Container(
                padding: EdgeInsets.all(r.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.gray400, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: r.spacing24,
                      color: AppTheme.gray300,
                    ),
                    SizedBox(width: r.spacing12),
                    Expanded(
                      child: Text(
                        'shop_no_packs_message'.tr,
                        style: AppTheme.textSmRegular.copyWith(
                          color: AppTheme.gray300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Mostrar pacotes adquiridos
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: r.spacing16),
            child: Row(
              children: [
                if (xpBoostQty > 0) ...[
                  ShopItemCard(
                    iconAsset: AppAssets.shopElixirXp,
                    label: 'shop_xp_boost_label'.tr.replaceAll('{count}', xpBoostQty.toString()),
                  ),
                  SizedBox(width: r.spacing12),
                ],
                if (skipLessonQty > 0) ...[
                  ShopItemCard(
                    iconAsset: AppAssets.shopChest,
                    label: 'shop_skip_lesson_label'.tr.replaceAll('{count}', skipLessonQty.toString()),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSpatialOffer(ResponsiveUtils r) {
    final controller = Get.find<ShopController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: Text('shop_special_offer'.tr, style: AppTheme.textLgBold),
        ),
        SizedBox(height: r.spacing16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: Row(
            children: [
              // Pacote de gems com dinheiro real
              ShopItemCard(
                iconAsset: AppAssets.shopGemCar,
                label: '1600',
                price: '\$ 4.99',
                backgroundColor: AppTheme.primary100,
                borderColor: AppTheme.primary,
                priceColor: AppTheme.primary,
                badge: 'shop_badge_new'.tr,
                badgeColor: AppTheme.primary,
                onTap: () => controller.purchaseGemPack(
                  Get.context!,
                  'gem_pack_1600',
                  1600,
                  '\$ 4.99',
                ),
              ),
              SizedBox(width: r.spacing12),
              
              // Recompensa gratuita (reativo)
              Obx(() {
                final isClaimed = controller.isRewardClaimedReactive('free_chest_100');
                
                return ShopItemCard(
                  iconAsset: AppAssets.shopChest,
                  label: '100',
                  price: isClaimed ? 'shop_claimed'.tr : 'shop_free'.tr,
                  backgroundColor: isClaimed ? AppTheme.white : AppTheme.green100,
                  borderColor: isClaimed ? AppTheme.gray300 : AppTheme.green,
                  priceColor: isClaimed ? AppTheme.gray300 : AppTheme.green,
                  onTap: isClaimed 
                      ? null 
                      : () => controller.claimFreeReward(
                            Get.context!,
                            'free_chest_100',
                            100,
                          ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningBoosts(ResponsiveUtils r) {
    final controller = Get.find<ShopController>();
    final energyController = Get.find<EnergyController>();
    final xpLevelController = Get.find<XpLevelController>();
    final gemsController = Get.find<GemsController>();
    final streakController = Get.find<StreakController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: SectionTitle(emoji: '🚀', title: 'shop_section_boosts'.tr),
        ),
        SizedBox(height: r.spacing12),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: Obx(() {
            final isEnergyLoading = energyController.isLoading.value;
            final isXpLoading = xpLevelController.isLoading.value;
            final isGemsLoading = gemsController.isLoading.value;
            final isStreakLoading = streakController.isLoading.value;
            
            return Column(
              children: [
                // Recarga de Energia - 100 gems
                Builder(
                  builder: (context) {
                    final currentEnergy = energyController.currentEnergy.value;
                    final isEnergyFull = currentEnergy >= 5;
                    final description = isEnergyFull
                        ? 'shop_energy_full'.tr.replaceAll('{current}', currentEnergy.toString())
                        : 'shop_energy_refill_description'.tr;
                    
                    return BoostItem(
                      iconAsset: AppAssets.appbarRay,
                      title: 'shop_energy_refill_title'.tr,
                      description: description,
                      price: 100,
                      badge: isEnergyFull ? 'shop_badge_full'.tr : null,
                      badgeColor: isEnergyFull ? AppTheme.green : null,
                      isLoading: isEnergyLoading,
                      onTap: (isEnergyFull || isEnergyLoading) ? null : controller.purchaseEnergyRefill,
                    );
                  }
                ),
                SizedBox(height: r.spacing12),
                
                // XP Booster - 150 gems
                Builder(
                  builder: (context) {
                    final isActive = xpLevelController.hasXpBooster;
                    final timeRemaining = xpLevelController.getXpBoosterTimeRemaining();
                    final description = timeRemaining.isNotEmpty
                        ? 'shop_xp_booster_active'.tr.replaceAll('{time}', timeRemaining)
                        : 'shop_xp_booster_description'.tr;
                    
                    return BoostItem(
                      iconAsset: AppAssets.shopElixirXp,
                      title: 'shop_xp_booster_title'.tr,
                      description: description,
                      price: 150,
                      badge: isActive ? 'shop_badge_active'.tr : null,
                      badgeColor: isActive ? AppTheme.green : null,
                      isLoading: isXpLoading,
                      onTap: (isActive || isXpLoading) ? null : controller.purchaseXpBooster,
                    );
                  }
                ),
                SizedBox(height: r.spacing12),
                
                // Gem Multiplier - 200 gems
                Builder(
                  builder: (context) {
                    final isActive = gemsController.hasGemMultiplier;
                    final timeRemaining = gemsController.getGemMultiplierTimeRemaining();
                    final description = timeRemaining.isNotEmpty
                      ? 'shop_gem_multiplier_active'.tr.replaceAll('{time}', timeRemaining)
                      : 'shop_gem_multiplier_description'.tr;
                  
                  return BoostItem(
                    iconAsset: AppAssets.shopElixir2x,
                    title: 'shop_gem_multiplier_title'.tr,
                    description: description,
                    price: 200,
                    badge: isActive ? 'shop_badge_active'.tr : 'shop_badge_popular'.tr,
                    badgeColor: isActive ? AppTheme.green : AppTheme.orange,
                    isLoading: isGemsLoading,
                    onTap: (isActive || isGemsLoading) ? null : () => controller.purchaseGemMultiplier(Get.context!),
                  );
                }),
                SizedBox(height: r.spacing12),
                
                // Streak Freeze - 200 gems
                Builder(
                  builder: (context) {
                    final isActive = streakController.streakFreezeAvailable;
                    
                    return BoostItem(
                      iconAsset: AppAssets.appbarFire,
                      title: 'shop_streak_freeze_title'.tr,
                      description: 'shop_streak_freeze_description'.tr,
                      price: 200,
                      badge: isActive ? 'shop_badge_active'.tr : null,
                      badgeColor: isActive ? AppTheme.green : null,
                      isLoading: isStreakLoading,
                      onTap: (isActive || isStreakLoading) ? null : () => controller.purchaseStreakFreeze(Get.context!),
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
    final controller = Get.find<ShopController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: SectionTitle(emoji: '🎨', title: 'shop_section_customization'.tr),
        ),
        SizedBox(height: r.spacing12),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: Column(
            children: [
              CollectibleItem(
                iconAsset: AppAssets.shopGemPot,
                title: 'shop_mascot_skins'.tr,
                price: '\$ 4.99',
                oldPrice: '20',
                badge: 'shop_badge_new'.tr,
                badgeColor: AppTheme.primary,
                onTap: () => controller.purchaseCollectible(
                  Get.context!,
                  'mascot_skins',
                  '\$ 4.99',
                ),
              ),
              SizedBox(height: r.spacing12),
              CollectibleItem(
                iconAsset: AppAssets.shopChest,
                title: 'shop_badge_packs'.tr,
                price: '\$ 8',
                oldPrice: '20',
                onTap: () => controller.purchaseCollectible(
                  Get.context!,
                  'badge_packs',
                  '\$ 8',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
