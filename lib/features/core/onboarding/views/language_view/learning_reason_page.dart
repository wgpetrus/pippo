import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/option_card.dart';

/// Tela de motivo para aprender o idioma
class LearningReasonPage extends StatelessWidget {
  const LearningReasonPage({super.key});

  // Dados
  static const _reasons = [
    {'icon': AppAssets.motivIcon1, 'label': 'Quero explorar o mundo.'},
    {'icon': AppAssets.motivIcon2, 'label': 'Preciso para trabalho ou estudo.'},
    {'icon': AppAssets.motivIcon3, 'label': 'Quero me conectar com pessoas.'},
    {'icon': AppAssets.motivIcon4, 'label': 'Adoro aprender coisas novas.'},
    {'icon': AppAssets.motivIcon5, 'label': 'Quero curtir filmes, músicas e livros.'},
    {'icon': AppAssets.motivIcon6, 'label': 'Quero falar sem medo.'},
  ];

  // Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    
    // Obter nome do idioma
    final languageName = controller.selectedLanguage.value.isNotEmpty
        ? _getLanguageName(controller.selectedLanguage.value)
        : '';

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          OnboardingHeader(
            title: 'Motivo para Aprender',
            bubbleText: 'Por que você quer aprender $languageName?',
            progress: 33,
          ),
          _buildReasonList(context, controller),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(controller),
    );
  }

  // Widgets
  Widget _buildReasonList(BuildContext context, OnboardingController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          // Opção "Other"
          if (index == _reasons.length) {
            return Container(
              color: AppTheme.white,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Obx(() => OptionCard(
                iconWidget: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.gray600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.ellipsis, color: AppTheme.gray300, size: 20),
                  ),
                ),
                label: controller.learningReason.value.startsWith('Outro:')
                    ? controller.learningReason.value.replaceFirst('Outro: ', '')
                    : 'Outro',
                isSelected: controller.learningReason.value.startsWith('Outro'),
                onTap: () => _showOtherModal(context, controller),
              )),
            );
          }

          final reason = _reasons[index];

          return Container(
            color: AppTheme.white,
            padding: EdgeInsets.fromLTRB(24, index == 0 ? 8 : 0, 24, 12),
            child: Obx(() => OptionCard(
              iconAsset: reason['icon']!,
              label: reason['label']!,
              isSelected: controller.learningReason.value == reason['label'],
              onTap: () => controller.learningReason.value = reason['label']!,
              isCircularIcon: false,
            )),
          );
        },
        childCount: _reasons.length + 1,
      ),
    );
  }

  Widget _buildBottomButton(OnboardingController controller) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() => AppButton(
        text: 'Continuar',
        onPressed: controller.learningReason.value.isNotEmpty
            ? controller.nav.goToPauseOne
            : null,
      )),
    );
  }

  // Handlers
  void _showOtherModal(BuildContext context, OnboardingController controller) {
    final textController = TextEditingController();

    if (controller.learningReason.value.startsWith('Outro:')) {
      textController.text = controller.learningReason.value.replaceFirst('Outro: ', '');
    }

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          hasTopBarLayer: true,
          topBarTitle: Text('Outro Motivo', style: AppTheme.textLgBold.copyWith(color: AppTheme.black)),
          isTopBarLayerAlwaysVisible: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conte-nos seu motivo', style: AppTheme.textMdSemibold.copyWith(color: AppTheme.black)),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
                  decoration: InputDecoration(
                    hintText: 'Escreva seu motivo aqui...',
                    hintStyle: AppTheme.textMdRegular.copyWith(color: AppTheme.gray400),
                    filled: true,
                    fillColor: AppTheme.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.gray600, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.gray600, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Confirmar',
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      controller.learningReason.value = 'Outro: $text';
                    } else {
                      controller.learningReason.value = 'Outro';
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
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
}
