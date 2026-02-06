import 'package:get/get.dart';

import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_flow_controller.dart';
import '../controllers/lesson_exercise_controller.dart';
import '../controllers/lesson_progress_controller.dart';
import '../controllers/lesson_rewards_controller.dart';

/// Binding para injeção de dependência dos Lesson Controllers
/// 
/// Registra os controllers com Get.lazyPut() para lazy initialization.
/// Os controllers são criados apenas quando primeiro acessados via Get.find().
/// 
/// Dependências:
/// - GamificationController (registrado globalmente em main.dart)
/// 
/// Ordem de registro:
/// 1. LessonProgressController (sem dependências de lesson)
/// 2. LessonFlowController (depende de GamificationController)
/// 3. LessonExerciseController (depende de LessonFlowController)
/// 4. LessonRewardsController (depende de todos os anteriores)
/// 
/// Disposição:
/// - GetX gerencia automaticamente a disposição dos controllers
/// - Chamado quando a rota é removida do stack
class LessonBinding extends Bindings {
  @override
  void dependencies() {
    // Garantir que GamificationController está registrado
    if (!Get.isRegistered<GamificationController>()) {
      Get.put(GamificationController(), permanent: true);
    }

    // Registrar controllers na ordem de dependências
    Get.lazyPut<LessonProgressController>(
      () => LessonProgressController(),
    );
    
    Get.lazyPut<LessonFlowController>(
      () => LessonFlowController(),
    );
    
    Get.lazyPut<LessonExerciseController>(
      () => LessonExerciseController(),
    );
    
    Get.lazyPut<LessonRewardsController>(
      () => LessonRewardsController(),
    );
  }
}

