import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';

/// Conteúdo do popover de lição
class LessonPopoverContent extends StatelessWidget {
  final String title;
  final int currentLesson;
  final int totalLessons;
  final int xpReward;
  final bool isCompleted;
  final VoidCallback? onStartTap;

  const LessonPopoverContent({
    super.key,
    required this.title,
    required this.currentLesson,
    required this.totalLessons,
    this.xpReward = 25,
    this.isCompleted = false,
    this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            title,
            style: AppTheme.displayXsBold.copyWith(color: AppTheme.white),
          ),

          const SizedBox(height: 4),

          // Subtítulo
          Text(
            'home_lesson_popover_lesson_label'.tr.replaceAll('{current}', currentLesson.toString()).replaceAll('{total}', totalLessons.toString()),
            style: AppTheme.textMdMedium.copyWith(
              color: AppTheme.white80,
            ),
          ),

          const SizedBox(height: 20),

          // Botão
          _buildStartButton(),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildStartButton() {
    return GestureDetector(
      onTap: onStartTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.gold : AppTheme.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            'home_lesson_popover_start_button'.tr.replaceAll('{xp}', xpReward.toString()),
            style: AppTheme.textLgBold.copyWith(
              color: isCompleted ? AppTheme.white : AppTheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
