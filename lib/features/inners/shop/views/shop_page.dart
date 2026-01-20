import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../gamification/controllers/gamification_controller.dart';
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
          // Contador de gems
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Image.asset(AppAssets.appbarGem, width: 24, height: 24),
                const SizedBox(width: 6),
                Text(
                  '${gamification.gems.value}',
                  style: AppTheme.textLgBold.copyWith(color: AppTheme.red),
                ),
              ],
            ),
          )),
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
    final gamification = Get.find<GamificationController>();
    
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
              // Recarga de Energia - 100 gems
              BoostItem(
                iconAsset: AppAssets.bottomBarRay,
                title: 'Recarga de Energia',
                description: 'Recarregue 5 energias instantaneamente!',
                price: 100,
                onTap: () => _purchaseEnergyRefill(gamification),
              ),
              const SizedBox(height: 12),
              
              // XP Booster - 150 gems
              BoostItem(
                iconAsset: AppAssets.shopElixirXp,
                title: 'Boost de XP',
                description: 'Ganhe 2× XP nas lições por 1 hora!',
                price: 150,
                onTap: () => _purchaseXpBooster(gamification),
              ),
              const SizedBox(height: 12),
              
              // Gem Multiplier - 200 gems
              BoostItem(
                iconAsset: AppAssets.shopElixir2x,
                title: 'Multiplicador de Gemas',
                description: 'Ganhe 2× gemas nas lições por 1 hora!',
                price: 200,
                badge: 'POPULAR',
                badgeColor: AppTheme.orange,
                onTap: () => _purchaseGemMultiplier(gamification),
              ),
              const SizedBox(height: 12),
              
              // Streak Freeze - 200 gems
              BoostItem(
                iconAsset: AppAssets.appbarFire,
                title: 'Proteção de Streak',
                description: 'Proteja seu streak por 1 dia!',
                price: 200,
                onTap: () => _purchaseStreakFreeze(gamification),
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

  // Métodos de compra
  /// Compra recarga de energia (100 gems)
  Future<void> _purchaseEnergyRefill(GamificationController gamification) async {
    await gamification.purchaseEnergyRefill();

    if (gamification.errorMessage.value.isNotEmpty) {
      // Mostrar erro
      Get.snackbar(
        'Erro',
        gamification.errorMessage.value,
        backgroundColor: AppTheme.red,
        colorText: AppTheme.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } else {
      // Mostrar sucesso
      Get.snackbar(
        'Sucesso!',
        'Energia recarregada! Você agora tem ${gamification.currentEnergy.value} energias.',
        backgroundColor: AppTheme.green,
        colorText: AppTheme.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Compra XP booster (150 gems, 1 hora)
  Future<void> _purchaseXpBooster(GamificationController gamification) async {
    await gamification.purchaseXpBooster();

    if (gamification.errorMessage.value.isNotEmpty) {
      // Mostrar erro
      Get.snackbar(
        'Erro',
        gamification.errorMessage.value,
        backgroundColor: AppTheme.red,
        colorText: AppTheme.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } else {
      // Mostrar sucesso
      Get.snackbar(
        'Sucesso!',
        'XP Booster ativado! Ganhe 2× XP por 1 hora.',
        backgroundColor: AppTheme.green,
        colorText: AppTheme.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Compra gem multiplier (200 gems, 1 hora)
  Future<void> _purchaseGemMultiplier(GamificationController gamification) async {
    await gamification.purchaseGemMultiplier();

    if (gamification.errorMessage.value.isNotEmpty) {
      // Mostrar erro
      Get.snackbar(
        'Erro',
        gamification.errorMessage.value,
        backgroundColor: AppTheme.red,
        colorText: AppTheme.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } else {
      // Mostrar sucesso
      Get.snackbar(
        'Sucesso!',
        'Multiplicador de Gemas ativado! Ganhe 2× gemas por 1 hora.',
        backgroundColor: AppTheme.green,
        colorText: AppTheme.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Compra streak freeze (200 gems)
  Future<void> _purchaseStreakFreeze(GamificationController gamification) async {
    await gamification.purchaseStreakFreeze();

    if (gamification.errorMessage.value.isNotEmpty) {
      // Mostrar erro
      Get.snackbar(
        'Erro',
        gamification.errorMessage.value,
        backgroundColor: AppTheme.red,
        colorText: AppTheme.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } else {
      // Mostrar sucesso
      Get.snackbar(
        'Sucesso!',
        'Proteção de Streak ativada! Seu streak está protegido por 1 dia.',
        backgroundColor: AppTheme.green,
        colorText: AppTheme.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }
}
