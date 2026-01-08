import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/option_card.dart';

/// Tela de seleção de nível do idioma
class LanguageLevelPage extends StatelessWidget {
  const LanguageLevelPage({super.key});

  // Dados
  static const _levels = [
    {'icon': AppAssets.levelIcon1, 'label': "I'm new to {lang}"},
    {'icon': AppAssets.levelIcon2, 'label': 'I know a few words'},
    {'icon': AppAssets.levelIcon3, 'label': 'I can hold basic conversations'},
    {'icon': AppAssets.levelIcon4, 'label': 'I understand grammar and read comfortably.'},
    {'icon': AppAssets.levelIcon5, 'label': 'I speak, read, and write with ease.'},
  ];

  // Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          const OnboardingHeader(
            title: 'Language Level',
            bubbleText: 'How would you rate your level?',
            progress: 22,
          ),
          _buildLevelList(controller),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(controller),
    );
  }

  // Widgets
  Widget _buildLevelList(OnboardingController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final level = _levels[index];
          final label = level['label']!.replaceAll('{lang}', controller.selectedLanguage.value);

          return Container(
            color: AppTheme.white,
            padding: EdgeInsets.fromLTRB(24, index == 0 ? 8 : 0, 24, 12),
            child: Obx(() => OptionCard(
              iconAsset: level['icon']!,
              label: label,
              isSelected: controller.languageLevel.value == level['label'],
              onTap: () => controller.languageLevel.value = level['label']!,
              isCircularIcon: false,
            )),
          );
        },
        childCount: _levels.length,
      ),
    );
  }

  Widget _buildBottomButton(OnboardingController controller) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() => AppButton(
        text: 'Continue',
        onPressed: controller.languageLevel.value.isNotEmpty
            ? controller.nav.goToLearningReason
            : null,
      )),
    );
  }
}
