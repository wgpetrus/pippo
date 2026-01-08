import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/onboarding_controller.dart';

/// Tela de boas-vindas
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  // Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.mascotWelcome,
                  width: screenWidth * 0.85,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                SvgPicture.asset(
                  AppAssets.logo,
                  width: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                Text(
                  'Ready to Begin Your Adventure?',
                  style: AppTheme.textLgRegular.copyWith(color: AppTheme.gray300),
                ),
                const SizedBox(height: 40),
                AppButton(
                  text: 'Get started',
                  onPressed: controller.nav.goToIntro,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Already have an account',
                  isPrimary: false,
                  onPressed: controller.nav.goToAuth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
