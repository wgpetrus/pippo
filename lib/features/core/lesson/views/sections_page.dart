import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../widgets/section_card.dart';
import 'image_exercise_page.dart';

/// Página de seções de um curso (navegação interna via Get.to)
class SectionsPage extends StatelessWidget {
  final String courseName;

  const SectionsPage({
    super.key,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(title: courseName),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Em progresso
          SectionCard(
            title: 'Seção 1',
            status: SectionStatus.inProgress,
            currentProgress: 4,
            totalProgress: 5,
            onTap: () => Get.to(() => const ImageExercisePage()),
          ),

          const SizedBox(height: 16),

          // Completa
          SectionCard(
            title: 'Seção 2',
            status: SectionStatus.completed,
            currentProgress: 5,
            totalProgress: 5,
            onTap: () => Get.to(() => const ImageExercisePage()),
          ),

          const SizedBox(height: 16),

          // Não iniciada
          SectionCard(
            title: 'Seção 3',
            status: SectionStatus.notStarted,
            onTap: () => Get.to(() => const ImageExercisePage()),
          ),

          const SizedBox(height: 16),

          // Bloqueada
          const SectionCard(
            title: 'Seção 4',
            status: SectionStatus.locked,
          ),

          const SizedBox(height: 16),

          // Bloqueada
          const SectionCard(
            title: 'Seção 5',
            status: SectionStatus.locked,
          ),
        ],
      ),
    );
  }
}
