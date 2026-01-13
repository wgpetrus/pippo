import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/app_assets.dart';

/// Bottom bar de navegação principal do app
class AppBottombar extends StatelessWidget {
  final int currentIndex;
  final String avatarAsset;
  final ValueChanged<int>? onTap;

  const AppBottombar({
    super.key,
    required this.currentIndex,
    required this.avatarAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(0, AppAssets.bottomRay),
              _buildItem(1, AppAssets.bottomCoins),
              _buildItem(2, AppAssets.bottomCoroa),
              _buildItem(3, AppAssets.bottomBox),
              _buildAvatarItem(4),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets
  Widget _buildItem(int index, String iconAsset) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppTheme.primary100 : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Image.asset(
            iconAsset,
            width: 28,
            height: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarItem(int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppTheme.primary100 : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary,
          ),
          child: ClipOval(
            child: Image.asset(avatarAsset, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
