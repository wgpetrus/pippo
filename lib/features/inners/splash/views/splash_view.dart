import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../controllers/splash_controller.dart';

/// Tela inicial do app
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  // Build
  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Center(
        child: SvgPicture.asset(AppAssets.logo, width: 200, fit: BoxFit.contain),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: SizedBox(
            width: Get.height * 0.075,
            height: Get.height * 0.075,
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}
