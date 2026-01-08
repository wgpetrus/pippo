import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';
import '../../widgets/onboarding_header.dart';

/// Tela de pausa 1 - transição entre blocos
class PauseOnePage extends StatefulWidget {
  const PauseOnePage({super.key});

  @override
  State<PauseOnePage> createState() => _PauseOnePageState();
}

class _PauseOnePageState extends State<PauseOnePage> with TickerProviderStateMixin {
  // Animações
  AnimationController? _mascotAnim;
  AnimationController? _flagsAnim;
  AnimationController? _starsAnim;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _mascotAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _flagsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _starsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mascotAnim?.dispose();
    _flagsAnim?.dispose();
    _starsAnim?.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    if (_mascotAnim == null || _flagsAnim == null || _starsAnim == null) {
      return const Scaffold(backgroundColor: AppTheme.white);
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const OnboardingHeader(),
      body: SafeArea(
        child: Stack(
          children: [
            _buildStarsBlue(),
            _buildStarsPink(),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMascotWithFlags(),
                    const SizedBox(height: 32),
                    Text(
                      "Let's craft your learning journey!",
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Pick your pace, shape your path, and unlock a world of words. Every choice you make builds your personal quest—ready to begin?",
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    AppButton(
                      text: 'Next',
                      onPressed: () => Get.find<OnboardingController>().nav.goToStudyTime(),
                      suffixIcon: const FaIcon(FontAwesomeIcons.arrowRight, color: AppTheme.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _buildStarsBlue() {
    return Positioned(
      top: 60,
      left: 24,
      child: AnimatedBuilder(
        animation: _starsAnim!,
        builder: (context, child) {
          final scale = 0.9 + (_starsAnim!.value * 0.2);
          final rotation = _starsAnim!.value * 0.3;
          return Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: Image.asset(AppAssets.starsBlue, width: 48),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStarsPink() {
    return Positioned(
      top: 180,
      right: 24,
      child: AnimatedBuilder(
        animation: _starsAnim!,
        builder: (context, child) {
          final scale = 1.1 - (_starsAnim!.value * 0.2);
          final rotation = -_starsAnim!.value * 0.4;
          return Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: Image.asset(AppAssets.starsPink, width: 32),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMascotWithFlags() {
    return SizedBox(
      width: 280,
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _buildAnimatedFlag(AppAssets.flagFrance, top: 0, left: 40, phaseOffset: 0),
          _buildAnimatedFlag(AppAssets.flagUsa, top: 0, right: 40, phaseOffset: math.pi / 2),
          _buildAnimatedFlag(AppAssets.flagBrazil, top: 60, left: 0, phaseOffset: math.pi),
          _buildAnimatedFlag(AppAssets.flagGermany, top: 60, right: 0, phaseOffset: math.pi * 1.5),
          _buildMascot(),
        ],
      ),
    );
  }

  Widget _buildAnimatedFlag(
    String asset, {
    double? top,
    double? left,
    double? right,
    required double phaseOffset,
  }) {
    return AnimatedBuilder(
      animation: _flagsAnim!,
      builder: (context, child) {
        final value = math.sin(_flagsAnim!.value * 2 * math.pi + phaseOffset);
        return Positioned(
          top: (top ?? 0) + (value * 6),
          left: left != null ? left + (value * 4) : null,
          right: right != null ? right + (value * -4) : null,
          child: _buildFlag(asset),
        );
      },
    );
  }

  Widget _buildMascot() {
    return Positioned(
      bottom: 0,
      child: AnimatedBuilder(
        animation: _mascotAnim!,
        builder: (context, child) {
          final value = Curves.easeInOut.transform(_mascotAnim!.value);
          return Transform.translate(
            offset: Offset(0, -value * 10),
            child: Image.asset(
              AppAssets.mascotPause,
              width: 160,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlag(String asset) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}
