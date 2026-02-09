import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_data_controller.dart';
import '../../controllers/onboarding_flow_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/option_card.dart';

/// Tela de seleção de nível do idioma
class LanguageLevelPage extends StatelessWidget {
  const LanguageLevelPage({super.key});

  // Dados
  static final _levels = [
    {'icon': AppAssets.levelIcon1, 'label': "onboarding_language_level_new"},
    {'icon': AppAssets.levelIcon2, 'label': 'onboarding_language_level_some_words'},
    {'icon': AppAssets.levelIcon3, 'label': 'onboarding_language_level_basic_conversations'},
    {'icon': AppAssets.levelIcon4, 'label': 'onboarding_language_level_grammar_reading'},
    {'icon': AppAssets.levelIcon5, 'label': 'onboarding_language_level_fluent'},
  ];

  // Build
  @override
  Widget build(BuildContext context) {
    final dataController = Get.find<OnboardingDataController>();
    final flowController = Get.find<OnboardingFlowController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          OnboardingHeader(
            title: 'onboarding_language_level_title'.tr,
            bubbleText: 'onboarding_language_level_bubble'.tr,
            progress: 22,
          ),
          _buildLevelList(dataController),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(dataController, flowController),
    );
  }

  // Widgets
  Widget _buildLevelList(OnboardingDataController dataController) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final level = _levels[index];
          // Usar LanguageHelper para obter o nome do idioma
          final languageName = dataController.selectedLanguage.value.isNotEmpty
              ? _getLanguageName(dataController.selectedLanguage.value)
              : '';
          final label = level['label']!.tr.replaceAll('{lang}', languageName);

          return Container(
            color: AppTheme.white,
            padding: EdgeInsets.fromLTRB(24, index == 0 ? 8 : 0, 24, 12),
            child: Obx(() => OptionCard(
              iconAsset: level['icon']!,
              label: label,
              isSelected: dataController.languageLevel.value == level['label'],
              onTap: () => dataController.setLanguageLevel(level['label']!),
              isCircularIcon: false,
            )),
          );
        },
        childCount: _levels.length,
      ),
    );
  }

  // Helper para obter nome do idioma
  String _getLanguageName(String code) {
    final languageNames = {
      'en': 'onboarding_select_language_english'.tr,
      'es': 'onboarding_select_language_spanish'.tr,
      'de': 'onboarding_select_language_german'.tr,
      'fr': 'onboarding_select_language_french'.tr,
      'ar': 'onboarding_select_language_arabic'.tr,
      'ja': 'onboarding_select_language_japanese'.tr,
      'zh': 'onboarding_select_language_chinese'.tr,
      'pt': 'onboarding_select_language_portuguese'.tr,
    };
    return languageNames[code] ?? code;
  }

  Widget _buildBottomButton(OnboardingDataController dataController, OnboardingFlowController flowController) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() => AppButton(
        text: 'common_continue'.tr,
        onPressed: dataController.languageLevel.value.isNotEmpty
            ? flowController.nav.goToLearningReason
            : null,
      )),
    );
  }
}
