import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/responsive_utils.dart';

/// Campo de texto padrão do app
class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.textMdBold.copyWith(color: AppTheme.black),
        ),
        SizedBox(height: ResponsiveUtils.height(8, min: 6, max: 10)),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          enabled: enabled,
          style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.textMdRegular.copyWith(color: AppTheme.gray400),
            filled: true,
            fillColor: AppTheme.white,
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.width(20, min: 16, max: 24),
              vertical: ResponsiveUtils.height(20, min: 16, max: 24),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.width(16, min: 12, max: 20)),
              borderSide: const BorderSide(color: AppTheme.gray600, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.width(16, min: 12, max: 20)),
              borderSide: const BorderSide(color: AppTheme.gray600, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.width(16, min: 12, max: 20)),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.width(16, min: 12, max: 20)),
              borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.width(16, min: 12, max: 20)),
              borderSide: const BorderSide(color: AppTheme.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
