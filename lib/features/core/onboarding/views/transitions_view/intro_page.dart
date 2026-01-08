import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';

/// Tela de introdução do mascote
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(builder: (context) => const _IntroContent());
  }
}

class _IntroContent extends StatefulWidget {
  const _IntroContent();

  @override
  State<_IntroContent> createState() => _IntroContentState();
}

class _IntroContentState extends State<_IntroContent> with SingleTickerProviderStateMixin {
  // Keys
  final _showcaseKey = GlobalKey();

  late final OnboardingController _controller;
  late final AnimationController _animController;
  late final Animation<double> _bounceAnim;

  // Estados
  bool _showSecondBubble = false;

  // Constantes
  static const double _largeMascotSize = 280;
  static const double _smallMascotSize = 200;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([_showcaseKey]);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Handlers
  void _onShowcaseComplete() => setState(() => _showSecondBubble = true);

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _showSecondBubble ? _buildSecondBubble() : _buildFirstShowcase(),
              const Spacer(flex: 1),
              Text(
                'Start Your Adventure!',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                "Just a few steps and you're in!",
                style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Get started',
                onPressed: _controller.nav.goToSelectLanguage,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets
  Widget _buildFirstShowcase() {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: Showcase(
            key: _showcaseKey,
            description: "Hi Buddy! i'm Gem!",
            descTextStyle: AppTheme.textXlBold.copyWith(color: AppTheme.black),
            tooltipBackgroundColor: AppTheme.gray700,
            tooltipBorderRadius: BorderRadius.circular(12),
            targetPadding: const EdgeInsets.only(bottom: 8),
            targetBorderRadius: BorderRadius.circular(100),
            showArrow: true,
            disableDefaultTargetGestures: true,
            disableMovingAnimation: true,
            disposeOnTap: false,
            onToolTipClick: _onShowcaseComplete,
            onTargetClick: _onShowcaseComplete,
            onBarrierClick: _onShowcaseComplete,
            child: Image.asset(
              AppAssets.mascotHappy,
              width: _largeMascotSize,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondBubble() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _largeMascotSize, end: _smallMascotSize),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, mascotSize, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Image.asset(
                AppAssets.mascotHappy,
                width: mascotSize,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: -40,
              right: 70,
              child: AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnim.value),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.gray700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Let's go together!",
                            style: AppTheme.textXlBold.copyWith(color: AppTheme.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: CustomPaint(
                            size: const Size(16, 8),
                            painter: _ArrowPainter(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.gray700
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
