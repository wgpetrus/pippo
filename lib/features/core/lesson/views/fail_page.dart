import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/lesson_controller.dart';

/// Página de falha da lição (quando perde todos os corações)
class FailPage extends StatelessWidget {
  const FailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final controller = Get.find<LessonController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.spacing16),
          child: Column(
            children: [
              SizedBox(height: r.spacing32),

              // Título
              Text(
                'Lição Falhou',
                style: AppTheme.displayMdBold.copyWith(color: AppTheme.red),
              ),

              const Spacer(),

              // Mascote triste
              Image.asset(
                AppAssets.lessonMascotError,
                width: r.wp(70),
                height: r.wp(70),
                fit: BoxFit.contain,
              ),

              SizedBox(height: r.spacing32),

              // Mensagem sobre corações
              Container(
                padding: EdgeInsets.all(r.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.red100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.red, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Você perdeu todos os corações!',
                      style: AppTheme.textLgBold.copyWith(color: AppTheme.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacing8),
                    Text(
                      'Não se preocupe, você pode tentar novamente. Continue praticando para melhorar!',
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Botão Tentar Novamente
              AppButton(
                text: 'Tentar Novamente',
                onPressed: () {
                  // Reseta o estado da lição
                  controller.onClose();
                  
                  // Volta para a tela de seções (2 vezes: FailPage -> LessonExerciseContainer -> SectionsPage)
                  Get.back();
                  Get.back();
                },
              ),

              SizedBox(height: r.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}
