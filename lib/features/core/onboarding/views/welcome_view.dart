import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/onboarding_controller.dart';
import 'transitions_view/intro_page.dart';

/// Tela de boas-vindas
class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  late final OnboardingController _controller;

  // Lifecycle

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    _checkSkipWelcome();
  }

  // Métodos privados

  void _checkSkipWelcome() {
    if (OnboardingController.shouldSkipWelcome) {
      OnboardingController.shouldSkipWelcome = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.off(() => const IntroPage());
      });
    }
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: r.spacing24,
              vertical: r.spacing32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.mascotWelcome,
                  width: r.wp(85),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: r.spacing24),
                SvgPicture.asset(
                  AppAssets.logo,
                  width: r.wp(40),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: r.spacing12),
                Text(
                  'Pronto para Começar sua Aventura?',
                  style: AppTheme.textLgRegular.copyWith(color: AppTheme.gray300),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: r.spacing32),
                AppButton(
                  text: 'Começar',
                  onPressed: _controller.nav.goToIntro,
                ),
                SizedBox(height: r.spacing16),
                AppButton(
                  text: 'Já tenho uma conta',
                  isPrimary: false,
                  onPressed: _controller.nav.goToAuth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
