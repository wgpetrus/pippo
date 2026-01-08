import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Botão principal do app
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final Widget? suffixIcon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.suffixIcon,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  bool get _isDisabled => widget.onPressed == null;

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

    if (widget.suffixIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.text, style: AppTheme.textLgBold.copyWith(color: textColor)),
          const SizedBox(width: 8),
          widget.suffixIcon!,
        ],
      );
    }

    return Text(widget.text, style: AppTheme.textLgBold.copyWith(color: textColor));
  }

  Widget _buildPrimaryButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppTheme.primaryDark,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: _isPressed ? 0 : 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryLight, AppTheme.primary, AppTheme.primary],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
          child: Center(child: _buildContent(AppTheme.white)),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: double.infinity,
        height: 62,
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
          child: Center(child: _buildContent(AppTheme.primary)),
        ),
      ),
    );
  }

  Widget _buildDisabledButton() {
    return Container(
      width: double.infinity,
      height: 62,
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
