import 'package:flutter/material.dart';

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
            "Didn't get it?  ",
            style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
          ),
          GestureDetector(
            onTap: onResend,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tap to resend.',
                  style: AppTheme.textMdSemibold.copyWith(color: AppTheme.primary),
                ),
                Container(height: 1.5, width: 100, color: AppTheme.primary),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          "Didn't get it?  You can resend code in   ",
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
