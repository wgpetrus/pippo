import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../gamification/controllers/gamification_controller.dart';

/// Tipo de stat para definir cor
enum StatType { flag, fire, gem, ray }

/// AppBar da home com avatar e stats
class HomeAppbar extends StatelessWidget {
  final String avatarAsset;
  final String flagAsset;
  final StatType? selectedStat;
  final VoidCallback? onAvatarTap;
  final ValueChanged<StatType>? onStatTap;

  const HomeAppbar({
    super.key,
    required this.avatarAsset,
    required this.flagAsset,
    this.selectedStat,
    this.onAvatarTap,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    // Obter GamificationController
    final gamificationController = Get.find<GamificationController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: onAvatarTap,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Círculo de fundo (metade inferior)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: 48,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    // Imagem do avatar
                    Image.asset(avatarAsset, fit: BoxFit.contain),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Stats
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flag (não reativo - mantém valor fixo)
                  Flexible(child: _buildStatChip(flagAsset, 5, StatType.flag)),
                  
                  // Fire (Streak) - reativo
                  Flexible(
                    child: Obx(() => _buildStatChip(
                      AppAssets.appbarFire,
                      gamificationController.currentStreak.value,
                      StatType.fire,
                    )),
                  ),
                  
                  // Gem (Gems) - reativo
                  Flexible(
                    child: Obx(() => _buildStatChip(
                      AppAssets.appbarGem,
                      gamificationController.gems.value,
                      StatType.gem,
                    )),
                  ),
                  
                  // Ray (Energy) - reativo
                  Flexible(
                    child: Obx(() => _buildStatChip(
                      AppAssets.appbarRay,
                      gamificationController.currentEnergy.value,
                      StatType.ray,
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _buildStatChip(String iconAsset, int count, StatType type) {
    final isSelected = selectedStat == type;

    return GestureDetector(
      onTap: () => onStatTap?.call(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _getBackgroundColor(type) : AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: _getBorderColor(type), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconAsset,
              width: type == StatType.flag ? 24 : 22,
              height: type == StatType.flag ? 24 : 22,
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: AppTheme.textMdBold.copyWith(color: _getTextColor(type)),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos privados
  Color _getTextColor(StatType type) {
    switch (type) {
      case StatType.flag:
        return AppTheme.black;
      case StatType.fire:
        return AppTheme.orange;
      case StatType.gem:
        return AppTheme.red;
      case StatType.ray:
        return AppTheme.primary;
    }
  }

  Color _getBackgroundColor(StatType type) {
    switch (type) {
      case StatType.flag:
        return AppTheme.primary100;
      case StatType.fire:
        return AppTheme.orange100;
      case StatType.gem:
        return AppTheme.red100;
      case StatType.ray:
        return AppTheme.primary100;
    }
  }

  Color _getBorderColor(StatType type) {
    switch (type) {
      case StatType.flag:
        return AppTheme.primary;
      case StatType.fire:
        return AppTheme.orange;
      case StatType.gem:
        return AppTheme.red;
      case StatType.ray:
        return AppTheme.primary;
    }
  }
}
