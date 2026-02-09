import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/utils/responsive_utils.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_flow_controller.dart';
import '../../widgets/onboarding_header.dart';

/// Tela de pausa 2 - transição para cadastro
class PauseTwoPage extends StatefulWidget {
  const PauseTwoPage({super.key});

  @override
  State<PauseTwoPage> createState() => _PauseTwoPageState();
}

class _PauseTwoPageState extends State<PauseTwoPage> with SingleTickerProviderStateMixin {
  // Animações
  AnimationController? _mascotAnim;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _mascotAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mascotAnim?.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    if (_mascotAnim == null) {
      return const Scaffold(backgroundColor: AppTheme.white);
    }

    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const OnboardingHeader(showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildMascot(),
              SizedBox(height: r.spacing32),
              Text(
                'onboarding_pause_two_title'.tr,
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacing16),
              Text(
                'onboarding_pause_two_subtitle'.tr,
                style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              AppButton(
                text: 'onboarding_pause_two_button'.tr,
                onPressed: () => Get.find<OnboardingFlowController>().nav.goToUserName(),
              ),
              SizedBox(height: r.spacing48),
            ],
          ),
        ),
      ),
    ));
  }

  // Widgets
  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: _mascotAnim!,
      builder: (context, child) {
        final r = ResponsiveUtils(context);
        final value = Curves.easeInOut.transform(_mascotAnim!.value);
        return Transform.translate(
          offset: Offset(0, -value * 12),
          child: Image.asset(
            AppAssets.mascotAdventure,
            width: r.wp(70),
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
