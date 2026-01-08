import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';

/// Tela de conclusão do onboarding
class ConclusionPage extends StatefulWidget {
  const ConclusionPage({super.key});

  @override
  State<ConclusionPage> createState() => _ConclusionPageState();
}

class _ConclusionPageState extends State<ConclusionPage> with SingleTickerProviderStateMixin {
  // Animações
  late final AnimationController _animController;
  late final Animation<double> _animation;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Column(
        children: [
          Expanded(child: _buildMascot()),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'I\'ve been waiting for you! Let\'s make this fun.',
                    style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your course is ready and waiting — just one click away.',
                    style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Let\'s Get Learning',
                    onPressed: controller.nav.finishOnboarding,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: child,
      ),
      child: Image.asset(
        AppAssets.mascotConclusion,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
