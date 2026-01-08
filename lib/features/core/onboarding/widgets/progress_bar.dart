import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';

/// Barra de progresso do onboarding
class ProgressBar extends StatelessWidget {
  final int progress; // 0-100

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        height: 16,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              flex: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryLight, AppTheme.white],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Expanded(flex: 100 - progress, child: const SizedBox()),
          ],
        ),
      ),
    );
  }
}
