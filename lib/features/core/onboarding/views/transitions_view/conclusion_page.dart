import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/utils/responsive_utils.dart';
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
  late final OnboardingController _controller;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
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
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Column(
        children: [
          Expanded(child: _buildMascot()),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.spacing24),
              child: Column(
                children: [
                  Text(
                    'Estava te esperando! Vamos nos divertir.',
                    style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: r.spacing12),
                  Text(
                    'Seu curso está pronto e esperando — a apenas um clique.',
                    style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: r.spacing24),
                  AppButton(
                    text: 'Vamos Aprender',
                    onPressed: _onButtonPressed,
                  ),
                  SizedBox(height: r.spacing32),
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

  // Métodos
  void _onButtonPressed() {
    if (_controller.isAddingCourse.value) {
      // Volta para home e reseta estado
      _controller.isAddingCourse.value = false;
      Get.offAllNamed('/home');
    } else {
      // Finaliza onboarding normal e salva estados
      _controller.completeOnboarding();
    }
  }
}
