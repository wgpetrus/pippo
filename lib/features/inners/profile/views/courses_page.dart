import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/app_dialog.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/profile_controller.dart';
import '../widgets/course_item.dart';

/// Página de cursos/idiomas do usuário
class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    _controller.loadUserCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Cursos'),
      body: Obx(() {
        // Mostrar loading
        if (_controller.isLoadingCourses.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        // Mostrar erro
        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _controller.errorMessage.value,
                    style: AppTheme.textMdRegular.copyWith(color: AppTheme.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Tentar Novamente',
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
              padding: const EdgeInsets.all(24),
              child: Text(
                'Você ainda não tem cursos ativos.',
                style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray700),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: _controller.userCourses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final course = _controller.userCourses[index];
            final courseId = course['id'] as String;
            final languageCode = course['language'] as String? ?? 'en'; // Mudado de 'languageCode' para 'language'
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
    );
  }

  /// Mapeia código de idioma para asset de bandeira
  String _getFlagAsset(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
        return AppAssets.flagUsa;
      case 'es':
        return AppAssets.flagSpain;
      case 'de':
        return AppAssets.flagGermany;
      case 'fr':
        return AppAssets.flagFrance;
      case 'ar':
        return AppAssets.flagSaudi;
      case 'ja':
        return AppAssets.flagJapan;
      case 'zh':
        return AppAssets.flagChina;
      case 'pt':
        return AppAssets.flagBrazil;
      default:
        return AppAssets.flagUsa;
    }
  }

  /// Define curso como principal
  void _setPrimaryCourse(String courseId) {
    _controller.setPrimaryCourse(courseId);
  }

  /// Exclui curso com confirmação
  Future<void> _deleteCourse(String courseId, String courseName) async {
    final confirm = await AppDialog.confirm(
      context: context,
      title: 'Dizer Adeus a Este Curso?',
      message: 'Você perderá todo o progresso de $courseName.',
      confirmText: 'Remover',
      cancelText: 'Cancelar',
      confirmColor: AppTheme.red,
    );

    if (confirm == true) {
      _controller.removeCourse(courseId);
    }
  }
}
