import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../widgets/confirm_delete_modal.dart';
import '../widgets/course_item.dart';

/// Página de cursos/idiomas do usuário
class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  // Lista de cursos (mock)
  final List<Map<String, String>> _courses = [
    {'flag': AppAssets.flagUsa, 'name': 'Spanish'},
    {'flag': AppAssets.flagGermany, 'name': 'German'},
    {'flag': AppAssets.flagSpain, 'name': 'Spanish'},
    {'flag': AppAssets.flagFrance, 'name': 'French'},
    {'flag': AppAssets.flagSaudi, 'name': 'Arabic'},
    {'flag': AppAssets.flagJapan, 'name': 'Japanese'},
    {'flag': AppAssets.flagChina, 'name': 'Chinese'},
    {'flag': AppAssets.flagBrazil, 'name': 'Portuguese'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Cursos'),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final course = _courses[index];
          return CourseItem(
            flagAsset: course['flag']!,
            name: course['name']!,
            onDelete: () => _deleteCourse(index),
          );
        },
      ),
    );
  }

  void _deleteCourse(int index) {
    ConfirmDeleteModal.show(
      context,
      title: 'Dizer Adeus a Este Curso?',
      description: "Excluir este curso significa que você perderá seu progresso, sequência e recompensas.",
      confirmText: 'Excluir',
      onConfirm: () => setState(() => _courses.removeAt(index)),
    );
  }
}
