import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_data_controller.dart';
import '../../controllers/onboarding_flow_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/option_card.dart';

/// Tela de motivo para aprender o idioma
class LearningReasonPage extends StatelessWidget {
  const LearningReasonPage({super.key});

  // Dados
  static final _reasons = [
    {'icon': AppAssets.motivIcon1, 'label': 'onboarding_learning_reason_explore_world'},
    {'icon': AppAssets.motivIcon2, 'label': 'onboarding_learning_reason_work_study'},
    {'icon': AppAssets.motivIcon3, 'label': 'onboarding_learning_reason_connect_people'},
    {'icon': AppAssets.motivIcon4, 'label': 'onboarding_learning_reason_love_learning'},
    {'icon': AppAssets.motivIcon5, 'label': 'onboarding_learning_reason_enjoy_media'},
    {'icon': AppAssets.motivIcon6, 'label': 'onboarding_learning_reason_speak_confidently'},
  ];

  // Build
  @override
  Widget build(BuildContext context) {
    final dataController = Get.find<OnboardingDataController>();
    final flowController = Get.find<OnboardingFlowController>();
    
    // Obter nome do idioma
    final languageName = dataController.selectedLanguage.value.isNotEmpty
        ? _getLanguageName(dataController.selectedLanguage.value)
        : '';

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          OnboardingHeader(
            title: 'onboarding_learning_reason_title'.tr,
            bubbleText: 'onboarding_learning_reason_bubble'.tr.replaceAll('{lang}', languageName),
            progress: 33,
          ),
          _buildReasonList(context, dataController),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(dataController, flowController),
    );
  }

  // Widgets
  Widget _buildReasonList(BuildContext context, OnboardingDataController dataController) {
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
                label: dataController.learningReason.value.startsWith('Outro:')
                    ? dataController.learningReason.value.replaceFirst('Outro: ', '')
                    : 'onboarding_learning_reason_other'.tr,
                isSelected: dataController.learningReason.value.startsWith('Outro'),
                onTap: () => _showOtherModal(context, dataController),
              )),
            );
          }

          final reason = _reasons[index];

          return Container(
            color: AppTheme.white,
            padding: EdgeInsets.fromLTRB(24, index == 0 ? 8 : 0, 24, 12),
            child: Obx(() => OptionCard(
              iconAsset: reason['icon']!,
              label: reason['label']!.tr,
              isSelected: dataController.learningReason.value == reason['label'],
              onTap: () => dataController.setLearningReason(reason['label']!),
              isCircularIcon: false,
            )),
          );
        },
        childCount: _reasons.length + 1,
      ),
    );
  }

  Widget _buildBottomButton(OnboardingDataController dataController, OnboardingFlowController flowController) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() => AppButton(
        text: 'common_continue'.tr,
        onPressed: dataController.learningReason.value.isNotEmpty
            ? flowController.nav.goToPauseOne
            : null,
      )),
    );
  }

  // Handlers
  void _showOtherModal(BuildContext context, OnboardingDataController dataController) {
    final textController = TextEditingController();

    if (dataController.learningReason.value.startsWith('Outro:')) {
      textController.text = dataController.learningReason.value.replaceFirst('Outro: ', '');
    }

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          hasTopBarLayer: true,
          topBarTitle: Text('onboarding_learning_reason_other_modal_title'.tr, style: AppTheme.textLgBold.copyWith(color: AppTheme.black)),
          isTopBarLayerAlwaysVisible: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('onboarding_learning_reason_other_modal_label'.tr, style: AppTheme.textMdSemibold.copyWith(color: AppTheme.black)),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
                  decoration: InputDecoration(
                    hintText: 'onboarding_learning_reason_other_modal_hint'.tr,
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
                  text: 'onboarding_learning_reason_other_modal_confirm'.tr,
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      dataController.setLearningReason('Outro: $text');
                    } else {
                      dataController.setLearningReason('Outro');
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
}
