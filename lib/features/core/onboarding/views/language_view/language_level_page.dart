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
    {'icon': AppAssets.levelIcon1, 'label': "Sou novo em {lang}"},
    {'icon': AppAssets.levelIcon2, 'label': 'Sei algumas palavras'},
    {'icon': AppAssets.levelIcon3, 'label': 'Consigo ter conversas básicas'},
    {'icon': AppAssets.levelIcon4, 'label': 'Entendo gramática e leio confortavelmente'},
    {'icon': AppAssets.levelIcon5, 'label': 'Falo, leio e escrevo com facilidade'},
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
            title: 'Nível do Idioma',
            bubbleText: 'Como você avalia seu nível?',
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
          // Usar LanguageHelper para obter o nome do idioma
          final languageName = controller.selectedLanguage.value.isNotEmpty
              ? _getLanguageName(controller.selectedLanguage.value)
              : '';
          final label = level['label']!.replaceAll('{lang}', languageName);

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

  // Helper para obter nome do idioma
  String _getLanguageName(String code) {
    const languageNames = {
      'en': 'Inglês',
      'es': 'Espanhol',
      'de': 'Alemão',
      'fr': 'Francês',
      'ar': 'Árabe',
      'ja': 'Japonês',
      'zh': 'Chinês',
      'pt': 'Português',
    };
    return languageNames[code] ?? code;
  }

  Widget _buildBottomButton(OnboardingController controller) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() => AppButton(
        text: 'Continuar',
        onPressed: controller.languageLevel.value.isNotEmpty
            ? controller.nav.goToLearningReason
            : null,
      )),
    );
  }
}
