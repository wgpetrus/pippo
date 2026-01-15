import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_back_button.dart';
import 'bouncing_mascot.dart';
import 'progress_bar.dart';

/// Header colapsável do onboarding com mascote e barra de progresso
class OnboardingHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? bubbleText;
  final int? progress;
  final double expandedHeight;

  const OnboardingHeader({
    super.key,
    this.title,
    this.bubbleText,
    this.progress,
    this.expandedHeight = 0.35,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Build
  @override
  Widget build(BuildContext context) {
    // Modo simples: apenas botão voltar (+ progress bar opcional)
    if (title == null) {
      return AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: const AppBackButton(),
        title: progress != null ? ProgressBar(progress: progress!) : null,
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
      leading: const AppBackButton(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title!, style: AppTheme.textXlBold.copyWith(color: AppTheme.black)),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ProgressBar(progress: progress!),
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
