import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/responsive_utils.dart';

/// Botão principal do app
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? color;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.color,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  bool get _isDisabled => widget.onPressed == null;

  // Cores
  Color get _mainColor => widget.color ?? AppTheme.primary;
  Color get _darkColor {
    if (widget.color == AppTheme.green) return const Color(0xFF28A000);
    if (widget.color == AppTheme.red) return const Color(0xFFCC0000);
    return AppTheme.primaryDark;
  }
  Color get _lightColor {
    if (widget.color != null) return widget.color!.withOpacity(0.8);
    return AppTheme.primaryLight;
  }

  // Build
  @override
  Widget build(BuildContext context) {
    if (_isDisabled) return _buildDisabledButton();
    if (widget.isPrimary) return _buildPrimaryButton();
    return _buildSecondaryButton();
  }

  // Widgets
  Widget _buildContent(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
      );
    }

    // Com prefix e suffix
    if (widget.prefixIcon != null || widget.suffixIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.prefixIcon != null) ...[
            widget.prefixIcon!,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.text,
              style: AppTheme.textLgBold.copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.suffixIcon != null) ...[
            const SizedBox(width: 8),
            widget.suffixIcon!,
          ],
        ],
      );
    }

    return Text(widget.text, style: AppTheme.textLgBold.copyWith(color: textColor));
  }

  Widget _buildPrimaryButton() {
    final buttonHeight = ResponsiveUtils.height(62, min: 48, max: 72);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: _darkColor,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: _isPressed ? 0 : 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: widget.color != null
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryLight, AppTheme.primary, AppTheme.primary],
                    stops: [0.0, 0.3, 1.0],
                  ),
            color: widget.color,
          ),
          child: Center(child: _buildContent(AppTheme.white)),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    final buttonHeight = ResponsiveUtils.height(62, min: 48, max: 72);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppTheme.gray600,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: _isPressed ? 0 : 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AppTheme.white,
            border: Border.all(color: AppTheme.gray600, width: 1.5),
          ),
          child: Center(child: _buildContent(_mainColor)),
        ),
      ),
    );
  }

  Widget _buildDisabledButton() {
    final buttonHeight = ResponsiveUtils.height(62, min: 48, max: 72);
    
    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppTheme.gray600,
      ),
      child: Center(
        child: Text(
          widget.text,
          style: AppTheme.textLgBold.copyWith(color: AppTheme.gray400),
        ),
      ),
    );
  }
}
