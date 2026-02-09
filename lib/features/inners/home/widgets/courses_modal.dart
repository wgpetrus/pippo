import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';

/// Dados de um curso
class CourseData {
  final String flagAsset;
  final String name;
  final bool isSelected;

  const CourseData({
    required this.flagAsset,
    required this.name,
    this.isSelected = false,
  });
}

/// Modal de seleção de cursos
class CoursesModal extends StatelessWidget {
  final List<CourseData> courses;
  final String selectedCourseName;
  final int currentLevel;
  final int maxLevel;
  final VoidCallback? onAddCourse;
  final ValueChanged<CourseData>? onCourseSelected;

  const CoursesModal({
    super.key,
    required this.courses,
    required this.selectedCourseName,
    this.currentLevel = 0,
    this.maxLevel = 15,
    this.onAddCourse,
    this.onCourseSelected,
  });

  // Build
  @override
  Widget build(BuildContext context) {
    // Padding responsivo - menor em telas pequenas
    final padding = ResponsiveUtils.isShortScreen
        ? EdgeInsets.all(ResponsiveUtils.width(16, min: 12, max: 20))
        : EdgeInsets.all(ResponsiveUtils.width(20, min: 16, max: 24));

    return Container(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('home_courses_modal_title'.tr, style: AppTheme.textLgBold),
          const SizedBox(height: 16),
          _buildCoursesList(),
          const SizedBox(height: 24),
          _buildLevelProgress(),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildCoursesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...courses.map((course) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildCourseItem(course),
          )),
          _buildAddCourseItem(),
        ],
      ),
    );
  }

  Widget _buildCourseItem(CourseData course) {
    return GestureDetector(
      onTap: () => onCourseSelected?.call(course),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              border: Border.all(
                color: course.isSelected ? AppTheme.primary : AppTheme.gray600,
                width: course.isSelected ? 2 : 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(course.flagAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            course.name,
            style: AppTheme.textSmBold.copyWith(
              color: course.isSelected ? AppTheme.primary : AppTheme.gray300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCourseItem() {
    return GestureDetector(
      onTap: onAddCourse,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: AppTheme.gray600, width: 1.5),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.plus,
                color: AppTheme.gray400,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'home_courses_modal_add_course'.tr,
            style: AppTheme.textSmMedium.copyWith(color: AppTheme.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    final progress = currentLevel / maxLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'home_courses_modal_level_label'.tr.replaceAll('{language}', selectedCourseName),
          style: AppTheme.textMdBold,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              currentLevel.toString(),
              style: AppTheme.textSmBold.copyWith(color: AppTheme.gray300),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.gray600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primary],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              maxLevel.toString(),
              style: AppTheme.textSmBold.copyWith(color: AppTheme.gray300),
            ),
          ],
        ),
      ],
    );
  }

  // Métodos estáticos
  static Future<void> show(
    BuildContext context, {
    required List<CourseData> courses,
    required String selectedCourseName,
    int currentLevel = 0,
    int maxLevel = 15,
    VoidCallback? onAddCourse,
    ValueChanged<CourseData>? onCourseSelected,
  }) async {
    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: CoursesModal(
            courses: courses,
            selectedCourseName: selectedCourseName,
            currentLevel: currentLevel,
            maxLevel: maxLevel,
            onAddCourse: () {
              Navigator.of(context).pop();
              onAddCourse?.call();
            },
            onCourseSelected: (course) {
              Navigator.of(context).pop();
              onCourseSelected?.call(course);
            },
          ),
        ),
      ],
    );
  }
}
