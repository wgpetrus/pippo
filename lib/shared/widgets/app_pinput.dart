import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../theme/theme.dart';
import '../utils/responsive_utils.dart';

/// Widget de input de PIN/código customizado
class AppPinput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final ValueChanged<String>? onCompleted;

  const AppPinput({
    super.key,
    required this.controller,
    required this.focusNode,
    this.length = 5,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Tamanho responsivo com limites para garantir usabilidade
    final size = ResponsiveUtils.width(65, min: 48, max: 75);

    final defaultTheme = PinTheme(
      width: size,
      height: size,
      textStyle: AppTheme.textXlBold.copyWith(color: AppTheme.gray400),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray600, width: 1.5),
      ),
    );

    final focusedTheme = PinTheme(
      width: size,
      height: size,
      textStyle: AppTheme.textXlBold.copyWith(color: AppTheme.gray400),
      decoration: BoxDecoration(
        color: AppTheme.primary100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppTheme.primary, offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
    );

    return Pinput(
      controller: controller,
      focusNode: focusNode,
      length: length,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: focusedTheme,
      submittedPinTheme: defaultTheme,
      followingPinTheme: defaultTheme,
      keyboardType: TextInputType.number,
      cursor: Container(width: 2, height: 24, color: AppTheme.primary),
      onCompleted: onCompleted,
    );
  }
}
