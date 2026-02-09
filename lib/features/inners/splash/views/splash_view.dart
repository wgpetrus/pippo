import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/splash_controller.dart';

/// Tela inicial do app
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final controller = Get.find<SplashController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppAssets.logo,
              width: r.wp(50),
              fit: BoxFit.contain,
            ),
            SizedBox(height: r.spacing32),
            
            // Mensagem de erro
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.spacing32),
                  child: Text(
                    controller.errorMessage.value,
                    style: AppTheme.textMdMedium.copyWith(
                      color: AppTheme.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Obx(() {
            if (controller.showRetryButton.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppButton(
                  text: 'splash_retry_button'.tr,
                  onPressed: () => controller.retry(),
                ),
              );
            }
            
            if (controller.isLoading.value) {
              return SizedBox(
                width: Get.height * 0.075,
                height: Get.height * 0.075,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              );
            }
            
            return const SizedBox.shrink();
          }),
        ),
      ),
    );
  }
}
