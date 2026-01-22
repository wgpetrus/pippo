import 'package:get/get.dart';

import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_controller.dart';

/// Binding para injeção de dependência do LessonController
/// 
/// Registra o LessonController com Get.lazyPut() para lazy initialization.
/// O controller é criado apenas quando primeiro acessado via Get.find().
/// 
/// Dependências:
/// - GamificationController (registrado globalmente em main.dart)
/// 
/// Disposição:
/// - GetX gerencia automaticamente a disposição do controller
/// - Chamado quando a rota é removida do stack
class LessonBinding extends Bindings {
  @override
  void dependencies() {
    // Garantir que GamificationController está registrado
    if (!Get.isRegistered<GamificationController>()) {
      Get.put(GamificationController(), permanent: true);
    }

    // Registrar LessonController com lazy initialization
    // Será criado apenas quando primeiro acessado
    Get.lazyPut<LessonController>(
      () => LessonController(),
      tag: null,
    );
  }
}

