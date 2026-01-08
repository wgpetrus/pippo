import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/theme/theme.dart';

/// Botão de login social (Facebook, Google)
class SocialButton extends StatefulWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.iconPath,
    this.onPressed,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  // Estados
  bool _isPressed = false;

  // Build
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
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
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(widget.iconPath, width: 24, height: 24),
                const SizedBox(width: 12),
                Text(widget.text, style: AppTheme.textLgBold.copyWith(color: AppTheme.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
