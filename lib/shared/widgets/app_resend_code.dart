import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/theme.dart';

/// Widget de texto para reenviar código de verificação
class AppResendCode extends StatelessWidget {
  final bool isComplete;
  final int secondsRemaining;
  final VoidCallback? onResend;

  const AppResendCode({
    super.key,
    required this.isComplete,
    this.secondsRemaining = 55,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return Row(
        children: [
          Text(
            '${'common_didnt_receive'.tr}  ',
            style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
          ),
          GestureDetector(
            onTap: onResend,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'common_tap_to_resend'.tr,
                  style: AppTheme.textMdSemibold.copyWith(color: AppTheme.primary),
                ),
                Container(height: 1.5, width: 130, color: AppTheme.primary),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          '${'common_didnt_receive'.tr}  ${'common_resend_code_in'.tr}   ',
          style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
        ),
        Text(
          '$secondsRemaining s',
          style: AppTheme.textMdBold.copyWith(color: AppTheme.primary),
        ),
      ],
    );
  }
}
