import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_data_controller.dart';
import '../../controllers/onboarding_flow_controller.dart';
import '../../widgets/onboarding_header.dart';

/// Tela de seleção de tempo de estudo diário
class StudyTimePage extends StatelessWidget {
  const StudyTimePage({super.key});

  // Dados
  static final _times = [
    'onboarding_study_time_5min'.tr,
    'onboarding_study_time_10min'.tr,
    'onboarding_study_time_15min'.tr,
    'onboarding_study_time_20min'.tr,
    'onboarding_study_time_30min'.tr,
    'onboarding_study_time_40min'.tr,
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
            title: 'onboarding_study_time_title'.tr,
            bubbleText: 'onboarding_study_time_bubble'.tr,
            progress: 44,
          ),
          _buildTimeList(dataController),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(dataController, flowController),
    );
  }

  // Widgets
  Widget _buildTimeList(OnboardingDataController dataController) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final time = _times[index];

          return Container(
            color: AppTheme.white,
            padding: EdgeInsets.fromLTRB(24, index == 0 ? 8 : 0, 24, 12),
            child: Obx(() => _buildTimeCard(
              label: time,
              isSelected: dataController.studyTime.value == time,
              onTap: () => dataController.setStudyTime(time),
            )),
          );
        },
        childCount: _times.length,
      ),
    );
  }

  Widget _buildTimeCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary100 : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.gray600,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [const BoxShadow(color: AppTheme.primary, offset: Offset(0, 4), blurRadius: 0)]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.textMdSemibold.copyWith(
                  color: isSelected ? AppTheme.primary : AppTheme.black,
                ),
              ),
            ),
            if (isSelected) _buildCheckbox(),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryDark,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.check, color: AppTheme.white, size: 14),
        ),
      ),
    );
  }

  Widget _buildBottomButton(OnboardingDataController dataController, OnboardingFlowController flowController) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() => AppButton(
        text: 'common_continue'.tr,
        onPressed: dataController.studyTime.value.isNotEmpty
            ? () => _onContinue(dataController, flowController)
            : null,
      )),
    );
  }

  // Métodos
  void _onContinue(OnboardingDataController dataController, OnboardingFlowController flowController) {
    if (dataController.isAddingCourse.value) {
      // Pula direto para conclusão (sem passar por cadastro)
      flowController.nav.goToConclusion();
    } else {
      // Fluxo normal do onboarding
      flowController.nav.goToPauseTwo();
    }
  }
}
