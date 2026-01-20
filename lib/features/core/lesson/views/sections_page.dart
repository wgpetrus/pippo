import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_controller.dart';
import '../widgets/low_energy_modal.dart';
import '../widgets/section_card.dart';
import 'image_exercise_page.dart';

/// Página de seções de um curso (navegação interna via Get.to)
class SectionsPage extends StatelessWidget {
  final String courseName;

  const SectionsPage({
    super.key,
    required this.courseName,
  });

  // Métodos

  void _startLesson(BuildContext context) {
    final lessonController = Get.find<LessonController>();
    final gamificationController = Get.find<GamificationController>();

    // Verifica se tem energia suficiente
    if (!lessonController.canStartLesson()) {
      // Mostra modal de energia baixa
      LowEnergyModal.show(
        context,
        currentEnergy: gamificationController.currentEnergy.value,
      );
      return;
    }

    // Inicia a lição (5 exercícios mockados)
    lessonController.startLesson(totalExercises: 5).then((_) {
      if (lessonController.errorMessage.value.isEmpty) {
        // Navega para o primeiro exercício
        Get.to(() => const ImageExercisePage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(title: courseName),
      body: ListView(
        padding: EdgeInsets.all(r.spacing16),
        children: [
          // Em progresso
          SectionCard(
            title: 'Seção 1',
            status: SectionStatus.inProgress,
            currentProgress: 4,
            totalProgress: 5,
            onTap: () => _startLesson(context),
          ),

          SizedBox(height: r.spacing16),

          // Completa
          SectionCard(
            title: 'Seção 2',
            status: SectionStatus.completed,
            currentProgress: 5,
            totalProgress: 5,
            onTap: () => _startLesson(context),
          ),

          SizedBox(height: r.spacing16),

          // Não iniciada
          SectionCard(
            title: 'Seção 3',
            status: SectionStatus.notStarted,
            onTap: () => _startLesson(context),
          ),

          SizedBox(height: r.spacing16),

          // Bloqueada
          const SectionCard(
            title: 'Seção 4',
            status: SectionStatus.locked,
          ),

          SizedBox(height: r.spacing16),

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
