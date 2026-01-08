import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/theme/theme.dart';

/// Card genérico de opção selecionável (idioma, nível, motivo, etc)
class OptionCard extends StatelessWidget {
  final String? iconAsset;
  final Widget? iconWidget;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCircularIcon;

  const OptionCard({
    super.key,
    this.iconAsset,
    this.iconWidget,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCircularIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary100 : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.gray600,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [const BoxShadow(color: AppTheme.primary, offset: Offset(0, 4), blurRadius: 0)]
              : null,
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTheme.textMdSemibold.copyWith(
                  color: isSelected ? AppTheme.primary : AppTheme.black,
                ),
              ),
            ),
            if (isSelected) _buildCheckbox(),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _buildIcon() {
    if (iconWidget != null) return iconWidget!;

    if (isCircularIcon) {
      return ClipOval(
        child: Image.asset(iconAsset!, width: 40, height: 40, fit: BoxFit.cover),
      );
    }

    return Image.asset(iconAsset!, width: 48, height: 48, fit: BoxFit.contain);
  }

  Widget _buildCheckbox() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryDark,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.check, color: AppTheme.white, size: 14),
        ),
      ),
    );
  }
}
