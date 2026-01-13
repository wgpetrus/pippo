import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_button.dart';

/// Card "Finish your profile!"
class CompleteProfileCard extends StatelessWidget {
  final int stepsLeft;
  final VoidCallback? onTap;

  const CompleteProfileCard({
    super.key,
    required this.stepsLeft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray600, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text('Finish your profile!', style: AppTheme.textLgBold),
          const SizedBox(height: 4),

          // Steps left
          Text(
            '$stepsLeft step left',
            style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray300),
          ),
          const SizedBox(height: 12),

          // Botão usando AppButton
          AppButton(
            text: 'Complete your profile',
            isPrimary: false,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
