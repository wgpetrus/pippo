import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../controllers/onboarding_controller.dart';
import 'bouncing_mascot.dart';
import 'progress_bar.dart';

/// Header colapsável do onboarding com mascote e barra de progresso
class OnboardingHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? bubbleText;
  final String? currentScreen; // Screen name for progress calculation
  final int? progress; // Manual progress override (deprecated, use currentScreen)
  final double expandedHeight;
  final bool showBackButton; // Controls back button visibility

  const OnboardingHeader({
    super.key,
    this.title,
    this.bubbleText,
    this.currentScreen,
    this.progress,
    this.expandedHeight = 0.35,
    this.showBackButton = true, // Default: show back button
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Build
  @override
  Widget build(BuildContext context) {
    // Calculate progress if currentScreen is provided
    int? calculatedProgress;
    if (currentScreen != null) {
      try {
        final controller = Get.find<OnboardingController>();
        final progressData = controller.calculateProgress(currentScreen!);
        final current = progressData['current']!;
        final total = progressData['total']!;
        // Convert to percentage (0-100)
        calculatedProgress = ((current / total) * 100).round();
      } catch (e) {
        // Controller not found or error calculating progress
        calculatedProgress = null;
      }
    }

    // Use calculated progress or manual override
    final displayProgress = calculatedProgress ?? progress;

    // Modo simples: apenas botão voltar (+ progress bar opcional)
    if (title == null) {
      return AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: showBackButton ? const AppBackButton() : null,
        title: displayProgress != null ? ProgressBar(progress: displayProgress) : null,
        titleSpacing: 12,
      );
    }

    // Modo completo: com título, mascote e área expandida
    final screenHeight = MediaQuery.of(context).size.height;

    return SliverAppBar(
      backgroundColor: AppTheme.white,
      elevation: 0,
      pinned: true,
      expandedHeight: screenHeight * expandedHeight,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      leading: showBackButton ? const AppBackButton() : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title!, style: AppTheme.textXlBold.copyWith(color: AppTheme.black)),
          if (displayProgress != null) ...[
            const SizedBox(height: 8),
            ProgressBar(progress: displayProgress),
          ],
        ],
      ),
      titleSpacing: 12,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.mascotExcited),
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                AppTheme.white70,
                BlendMode.srcOver,
              ),
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: BouncingMascot(
                      asset: AppAssets.mascotExcited,
                      bubbleText: bubbleText ?? '',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(32),
        child: Container(
          height: 32,
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
        ),
      ),
    );
  }
}
