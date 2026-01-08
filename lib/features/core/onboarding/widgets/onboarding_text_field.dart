import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/theme.dart';

/// Campo de texto customizado do onboarding com estilo de seleção
class OnboardingTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool isFocused;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffixIcon;

  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.isFocused,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    final showStyle = isFocused || hasText;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: showStyle ? AppTheme.primary100 : AppTheme.white,
        border: Border.all(
          color: showStyle ? AppTheme.primary : AppTheme.gray600,
          width: showStyle ? 2 : 1.5,
        ),
        boxShadow: showStyle
            ? [const BoxShadow(color: AppTheme.primary, offset: Offset(0, 4), blurRadius: 0)]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.textMdRegular.copyWith(color: AppTheme.gray400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
