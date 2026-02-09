import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_button.dart';

/// Card "Complete seu perfil!"
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone e título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.solidStar,
                  color: AppTheme.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'complete_profile_title'.tr,
                      style: AppTheme.textLgBold.copyWith(color: AppTheme.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stepsLeft == 1
                          ? '$stepsLeft ${'complete_profile_step_singular'.tr}'
                          : '$stepsLeft ${'complete_profile_step_plural'.tr}',
                      style: AppTheme.textSmRegular.copyWith(
                        color: AppTheme.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Botão
          AppButton(
            text: 'complete_profile_button'.tr,
            isPrimary: false,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
