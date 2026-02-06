import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../gamification/controllers/streak_controller.dart';
import '../../gamification/controllers/energy_controller.dart';
import '../../gamification/controllers/gems_controller.dart';
import '../../gamification/controllers/xp_level_controller.dart';

/// Tipo de stat para definir cor
enum StatType { flag, fire, gem, ray }

/// AppBar da home com avatar e stats
class HomeAppbar extends StatelessWidget {
  final String avatarAsset;
  final String flagAsset;
  final StatType? selectedStat;
  final VoidCallback? onAvatarTap;
  final ValueChanged<StatType>? onStatTap;
  final dynamic controller; // HomeController para observar selectedStat

  const HomeAppbar({
    super.key,
    required this.avatarAsset,
    required this.flagAsset,
    this.selectedStat,
    this.onAvatarTap,
    this.onStatTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Obter controllers
    final streakController = Get.find<StreakController>();
    final energyController = Get.find<EnergyController>();
    final gemsController = Get.find<GemsController>();
    final xpLevelController = Get.find<XpLevelController>();

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
                  // Flag (nível do curso) - reativo
                  Flexible(
                    child: _buildStatChip(
                      flagAsset,
                      null, // será obtido do controller
                      StatType.flag,
                      xpLevelController,
                    ),
                  ),
                  
                  // Fire (Streak) - reativo
                  Flexible(
                    child: _buildStatChip(
                      AppAssets.appbarFire,
                      null, // será obtido do controller
                      StatType.fire,
                      streakController,
                    ),
                  ),
                  
                  // Gem (Gems) - reativo
                  Flexible(
                    child: _buildStatChip(
                      AppAssets.appbarGem,
                      null, // será obtido do controller
                      StatType.gem,
                      gemsController,
                    ),
                  ),
                  
                  // Ray (Energy) - reativo
                  Flexible(
                    child: _buildStatChip(
                      AppAssets.appbarRay,
                      null, // será obtido do controller
                      StatType.ray,
                      energyController,
                    ),
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
  Widget _buildStatChip(
    String iconAsset,
    int? fixedCount,
    StatType type,
    dynamic controller,
  ) {
    // Envolver APENAS o widget que precisa ser reativo
    return Obx(() {
      // Obter count (fixo ou reativo)
      final count = fixedCount ?? _getCountForType(type, controller);
      
      // Obter isSelected
      final isSelected = this.controller.selectedStat.value == type;
      
      // Construir o widget
      return _buildStatChipContent(
        iconAsset: iconAsset,
        count: count,
        type: type,
        isSelected: isSelected,
      );
    });
  }
  
  /// Obtém o count para um tipo específico de stat
  int _getCountForType(StatType type, dynamic controller) {
    switch (type) {
      case StatType.flag:
        return (controller as XpLevelController).level.value;
      case StatType.fire:
        return (controller as StreakController).currentStreak.value;
      case StatType.gem:
        return (controller as GemsController).gems.value;
      case StatType.ray:
        return (controller as EnergyController).currentEnergy.value;
      default:
        return 0;
    }
  }
  
  Widget _buildStatChipContent({
    required String iconAsset,
    required int count,
    required StatType type,
    required bool isSelected,
  }) {
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
            Flexible(
              child: Text(
                _formatCount(count),
                style: AppTheme.textMdBold.copyWith(
                  color: isSelected ? _getBorderColor(type) : _getTextColor(type),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formata números grandes (ex: 1000 → 1k, 1500 → 1.5k)
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(count % 1000000 == 0 ? 0 : 1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
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
