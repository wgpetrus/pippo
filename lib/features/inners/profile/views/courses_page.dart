import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/language_helper.dart';
import '../../../../shared/utils/app_dialog.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/profile_courses_controller.dart';
import '../widgets/course_item.dart';

/// Página de cursos/idiomas do usuário
class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late final ProfileCoursesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileCoursesController>();
    _controller.loadUserCourses();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(title: 'courses_title'.tr),
      body: SafeArea(
        child: Obx(() {
          // Mostrar loading
          if (_controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          // Mostrar erro
          if (_controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(r.spacing24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _controller.errorMessage.value,
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacing16),
                    AppButton(
                      text: 'courses_try_again'.tr,
                      onPressed: () => _controller.loadUserCourses(),
                    ),
                  ],
                ),
              ),
            );
          }

          // Mostrar lista de cursos
          if (_controller.userCourses.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(r.spacing24),
                child: Text(
                  'courses_no_courses'.tr,
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray700),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(r.spacing24),
            itemCount: _controller.userCourses.length,
            separatorBuilder: (_, __) => SizedBox(height: r.spacing12),
            itemBuilder: (context, index) {
              final course = _controller.userCourses[index];
              final courseId = course['id'] as String;
              final languageCode = course['language'] as String? ?? 'en';
              final languageName = course['languageName'] as String? ?? 'Unknown';
              final isPrimary = course['isPrimary'] as bool? ?? false;

              return CourseItem(
                flagAsset: _getFlagAsset(languageCode),
                name: languageName,
                isPrimary: isPrimary,
                onSetPrimary: isPrimary ? null : () => _setPrimaryCourse(courseId),
                onDelete: () => _deleteCourse(courseId, languageName),
              );
            },
          );
        }),
      ),
    );
  }

  /// Mapeia código de idioma para asset de bandeira
  String _getFlagAsset(String languageCode) {
    return LanguageHelper.getLanguageFlag(languageCode.toLowerCase());
  }

  /// Define curso como principal
  void _setPrimaryCourse(String courseId) {
    _controller.setPrimaryCourse(courseId);
  }

  /// Exclui curso com confirmação
  Future<void> _deleteCourse(String courseId, String courseName) async {
    final confirm = await AppDialog.confirm(
      context: context,
      title: 'courses_delete_title'.tr,
      message: '${'courses_delete_message_prefix'.tr} $courseName.',
      confirmText: 'courses_delete_confirm'.tr,
      cancelText: 'courses_delete_cancel'.tr,
      confirmColor: AppTheme.red,
    );

    if (confirm == true) {
      _controller.removeCourse(courseId);
    }
  }
}
