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
    Get.put(ShopController());
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
          child: const Text('Seus pacotes', style: AppTheme.textLgBold),
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
                        'Você ainda não possui pacotes. Adquira nas ofertas especiais!',
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
                    label: 'Boost de XP x$xpBoostQty',
                  ),
                  SizedBox(width: r.spacing12),
                ],
                if (skipLessonQty > 0) ...[
                  ShopItemCard(
                    iconAsset: AppAssets.shopChest,
                    label: 'Pular Lição x$skipLessonQty',
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
          child: const Text('Oferta especial', style: AppTheme.textLgBold),
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
                badge: 'NEW',
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
                  price: isClaimed ? 'RESGATADO' : '\$ GRÁTIS',
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
    final gamification = Get.find<GamificationController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: const SectionTitle(emoji: '🚀', title: 'Boosts de Aprendizado'),
        ),
        SizedBox(height: r.spacing12),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: Obx(() {
            final isLoading = gamification.isLoading.value;
            
            return Column(
              children: [
                // Recarga de Energia - 100 gems
                Builder(
                  builder: (context) {
                    final currentEnergy = gamification.currentEnergy.value;
                    final isEnergyFull = currentEnergy >= 5;
                    final description = isEnergyFull
                        ? 'Energia completa! ($currentEnergy/5)'
                        : 'Recarregue 5 energias instantaneamente!';
                    
                    return BoostItem(
                      iconAsset: AppAssets.appbarRay,
                      title: 'Recarga de Energia',
                      description: description,
                      price: 100,
                      badge: isEnergyFull ? 'COMPLETA' : null,
                      badgeColor: isEnergyFull ? AppTheme.green : null,
                      isLoading: isLoading,
                      onTap: (isEnergyFull || isLoading) ? null : controller.purchaseEnergyRefill,
                    );
                  }
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
                    onTap: (isActive || isLoading) ? null : () => controller.purchaseGemMultiplier(Get.context!),
                  );
                }),
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
                      onTap: (isActive || isLoading) ? null : () => controller.purchaseStreakFreeze(Get.context!),
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
          child: const SectionTitle(emoji: '🎨', title: 'Personalização e Colecionáveis'),
        ),
        SizedBox(height: r.spacing12),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: Column(
            children: [
              CollectibleItem(
                iconAsset: AppAssets.shopGemPot,
                title: 'Skins do Mascote',
                price: '\$ 4.99',
                oldPrice: '20',
                badge: 'NOVO',
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
                title: 'Pacotes de Emblemas',
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
