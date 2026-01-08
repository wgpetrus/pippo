import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';
import '../../widgets/onboarding_header.dart';

/// Tela de seleção de tempo de estudo diário
class StudyTimePage extends StatelessWidget {
  const StudyTimePage({super.key});

  // Dados
  static const _times = [
    '5 min / day',
    '10 min / day',
    '15 min / day',
    '20 min / day',
    '30 min / day',
    '40 min / day',
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
            title: 'Study Time',
            bubbleText: 'Choose Your Daily Learning Time Goal',
            progress: 44,
          ),
          _buildTimeList(controller),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(controller),
    );
  }

  // Widgets
  Widget _buildTimeList(OnboardingController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final time = _times[index];

          return Container(
            color: AppTheme.white,
            padding: EdgeInsets.fromLTRB(24, index == 0 ? 8 : 0, 24, 12),
            child: Obx(() => _buildTimeCard(
              label: time,
              isSelected: controller.studyTime.value == time,
              onTap: () => controller.studyTime.value = time,
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

  Widget _buildBottomButton(OnboardingController controller) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() => AppButton(
        text: 'Continue',
        onPressed: controller.studyTime.value.isNotEmpty
            ? controller.nav.goToPauseTwo
            : null,
      )),
    );
  }
}
