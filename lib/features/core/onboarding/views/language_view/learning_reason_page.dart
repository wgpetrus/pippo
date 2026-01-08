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
    {'icon': AppAssets.motivIcon1, 'label': 'I want to explore the world.'},
    {'icon': AppAssets.motivIcon2, 'label': 'I need it for work or study.'},
    {'icon': AppAssets.motivIcon3, 'label': 'I want to connect with people.'},
    {'icon': AppAssets.motivIcon4, 'label': 'I love learning new things.'},
    {'icon': AppAssets.motivIcon5, 'label': 'I want to enjoy movies, music, and books.'},
    {'icon': AppAssets.motivIcon6, 'label': 'I want to speak without fear.'},
  ];

  // Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          OnboardingHeader(
            title: 'Learning Reason',
            bubbleText: 'Why Do You Want to Learn ${controller.selectedLanguage.value}?',
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
                label: controller.learningReason.value.startsWith('Other:')
                    ? controller.learningReason.value.replaceFirst('Other: ', '')
                    : 'Other',
                isSelected: controller.learningReason.value.startsWith('Other'),
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
        text: 'Continue',
        onPressed: controller.learningReason.value.isNotEmpty
            ? controller.nav.goToPauseOne
            : null,
      )),
    );
  }

  // Handlers
  void _showOtherModal(BuildContext context, OnboardingController controller) {
    final textController = TextEditingController();

    if (controller.learningReason.value.startsWith('Other:')) {
      textController.text = controller.learningReason.value.replaceFirst('Other: ', '');
    }

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          hasTopBarLayer: true,
          topBarTitle: Text('Other Reason', style: AppTheme.textLgBold.copyWith(color: AppTheme.black)),
          isTopBarLayerAlwaysVisible: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tell us your reason', style: AppTheme.textMdSemibold.copyWith(color: AppTheme.black)),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
                  decoration: InputDecoration(
                    hintText: 'Write your reason here...',
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
                  text: 'Confirm',
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      controller.learningReason.value = 'Other: $text';
                    } else {
                      controller.learningReason.value = 'Other';
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
}
