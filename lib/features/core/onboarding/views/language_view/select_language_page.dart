import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/option_card.dart';

/// Tela de seleção de idioma
class SelectLanguagePage extends StatelessWidget {
  const SelectLanguagePage({super.key});

  // Dados
  static const _languages = [
    {'flag': AppAssets.flagUsa, 'name': 'English'},
    {'flag': AppAssets.flagGermany, 'name': 'German'},
    {'flag': AppAssets.flagSpain, 'name': 'Spanish'},
    {'flag': AppAssets.flagFrance, 'name': 'French'},
    {'flag': AppAssets.flagSaudi, 'name': 'Arabic'},
    {'flag': AppAssets.flagJapan, 'name': 'Japanese'},
    {'flag': AppAssets.flagChina, 'name': 'Chinese'},
    {'flag': AppAssets.flagBrazil, 'name': 'Portuguese'},
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
            title: 'Select Language',
            bubbleText: 'Which language do you want to learn?',
            progress: 11,
          ),
          _buildLanguageList(controller),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(controller),
    );
  }

  // Widgets
  Widget _buildLanguageList(OnboardingController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final lang = _languages[index];

          return Container(
            color: AppTheme.white,
            padding: EdgeInsets.fromLTRB(24, index == 0 ? 8 : 0, 24, 12),
            child: Obx(() => OptionCard(
              iconAsset: lang['flag']!,
              label: lang['name']!,
              isSelected: controller.selectedLanguage.value == lang['name'],
              onTap: () => controller.selectedLanguage.value = lang['name']!,
            )),
          );
        },
        childCount: _languages.length,
      ),
    );
  }

  Widget _buildBottomButton(OnboardingController controller) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() => AppButton(
        text: 'Continue',
        onPressed: controller.selectedLanguage.value.isNotEmpty
            ? controller.nav.goToLanguageLevel
            : null,
      )),
    );
  }
}
