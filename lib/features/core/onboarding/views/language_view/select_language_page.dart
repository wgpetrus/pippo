import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_data_controller.dart';
import '../../controllers/onboarding_flow_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/option_card.dart';

/// Tela de seleção de idioma
class SelectLanguagePage extends StatelessWidget {
  const SelectLanguagePage({super.key});

  // Dados
  static final _languages = [
    {'code': 'en', 'flag': AppAssets.flagUsa, 'name': 'onboarding_select_language_english'.tr},
    {'code': 'de', 'flag': AppAssets.flagGermany, 'name': 'onboarding_select_language_german'.tr},
    {'code': 'es', 'flag': AppAssets.flagSpain, 'name': 'onboarding_select_language_spanish'.tr},
    {'code': 'fr', 'flag': AppAssets.flagFrance, 'name': 'onboarding_select_language_french'.tr},
    {'code': 'ar', 'flag': AppAssets.flagSaudi, 'name': 'onboarding_select_language_arabic'.tr},
    {'code': 'ja', 'flag': AppAssets.flagJapan, 'name': 'onboarding_select_language_japanese'.tr},
    {'code': 'zh', 'flag': AppAssets.flagChina, 'name': 'onboarding_select_language_chinese'.tr},
    {'code': 'pt', 'flag': AppAssets.flagBrazil, 'name': 'onboarding_select_language_portuguese'.tr},
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
            title: 'onboarding_select_language_title'.tr,
            bubbleText: 'onboarding_select_language_bubble'.tr,
            progress: 11,
          ),
          _buildLanguageList(dataController),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(dataController, flowController),
    );
  }

  // Widgets
  Widget _buildLanguageList(OnboardingDataController dataController) {
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
              isSelected: dataController.selectedLanguage.value == lang['code'],
              onTap: () => dataController.setLanguage(lang['code']!),
            )),
          );
        },
        childCount: _languages.length,
      ),
    );
  }

  Widget _buildBottomButton(OnboardingDataController dataController, OnboardingFlowController flowController) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() => AppButton(
        text: 'common_continue'.tr,
        onPressed: dataController.selectedLanguage.value.isNotEmpty
            ? flowController.nav.goToLanguageLevel
            : null,
      )),
    );
  }
}
