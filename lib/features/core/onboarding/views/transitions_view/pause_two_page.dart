import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';
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
    if (_mascotAnim == null) {
      return const Scaffold(backgroundColor: AppTheme.white);
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const OnboardingHeader(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildMascot(),
              const SizedBox(height: 32),
              Text(
                'Ready to Begin Your Adventure?',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'It only takes a moment to unlock your journey!',
                style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              AppButton(
                text: "Let's Goo",
                onPressed: () => Get.find<OnboardingController>().nav.goToUserName(),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets
  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: _mascotAnim!,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(_mascotAnim!.value);
        return Transform.translate(
          offset: Offset(0, -value * 12),
          child: Image.asset(
            AppAssets.mascotAdventure,
            width: 280,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
