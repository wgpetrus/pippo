// Packages externos
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Imports locais
import 'package:pippo/features/core/lesson/controllers/lesson_controller.dart';
import 'package:pippo/features/inners/gamification/controllers/gamification_controller.dart';

import '../../../../helpers/firebase_test_helper.dart';

/// Testes unitários para LessonController
/// Foco em exemplos específicos e edge cases
/// 
/// **Valida: Requisitos 1.3 (caso de 0 energia)**
void main() {
  // Variáveis de teste
  late LessonController controller;
  late _MockGamificationController mockGamification;
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;

  setUpAll(() async {
    await FirebaseTestHelper.setupFirebase();
  });

  setUp(() async {
    Get.testMode = true;

    mockAuth = FirebaseTestHelper.createMockAuth();
    mockFirestore = FirebaseTestHelper.createMockFirestore();

    // Configurar mock do GamificationController
    mockGamification = _MockGamificationController();
    Get.put<GamificationController>(mockGamification);

    // Popular dados básicos
    await FirebaseTestHelper.populateGamificationData(
      mockFirestore,
      'test-user-id',
      currentEnergy: 0, // 0 energia para testes
    );

    controller = LessonController();
  });

  tearDown(() {
    Get.reset();
  });

  group('LessonController - Caso de 0 Energia', () {
    test('mostra mensagem de erro quando energia é 0', () async {
      // Configuração: Sem energia disponível
      mockGamification.hasEnergyValue = false;
      mockGamification.hasUnlimitedValue = false;

      // Tentar iniciar lição
      await controller.startLesson('course_1', '1');

      // Verificar: Mensagem de erro é exibida
      expect(
        controller.errorMessage.value,
        isNotEmpty,
        reason: 'Deve mostrar mensagem de erro quando energia é 0',
      );

      expect(
        controller.errorMessage.value,
        contains('energia suficiente'),
        reason: 'Mensagem de erro deve mencionar energia insuficiente',
      );
    });

    test('não inicia lição quando energia é 0', () async {
      // Configuração: Sem energia disponível
      mockGamification.hasEnergyValue = false;
      mockGamification.hasUnlimitedValue = false;

      // Tentar iniciar lição
      await controller.startLesson('course_1', '1');

      // Verificar: Lição não iniciou
      expect(
        controller.currentLesson.value,
        isNull,
        reason: 'Lição atual deve permanecer null',
      );

      expect(
        controller.currentExercises.isEmpty,
        isTrue,
        reason: 'Exercícios devem permanecer vazios',
      );

      expect(
        controller.startTime.value,
        isNull,
        reason: 'Tempo de início deve permanecer null',
      );
    });

    test('não consome energia quando energia é 0', () async {
      // Configuração: Sem energia disponível
      mockGamification.hasEnergyValue = false;
      mockGamification.hasUnlimitedValue = false;
      mockGamification.energyConsumed = false;

      // Tentar iniciar lição
      await controller.startLesson('course_1', '1');

      // Verificar: Energia NÃO foi consumida
      expect(
        mockGamification.energyConsumed,
        isFalse,
        reason: 'Não deve consumir energia quando não há disponível',
      );
    });

    test('não inicializa estado da lição quando energia é 0', () async {
      // Configuração: Sem energia disponível
      mockGamification.hasEnergyValue = false;
      mockGamification.hasUnlimitedValue = false;

      // Definir valores não-padrão para verificar que não mudam
      controller.hearts.value = 999;
      controller.correctAnswers.value = 999;
      controller.totalAnswers.value = 999;

      // Tentar iniciar lição
      await controller.startLesson('course_1', '1');

      // Verificar: Estado NÃO foi inicializado (valores inalterados)
      expect(
        controller.hearts.value,
        equals(999),
        reason: 'Corações não devem ser resetados quando lição falha ao iniciar',
      );

      expect(
        controller.correctAnswers.value,
        equals(999),
        reason: 'Respostas corretas não devem ser resetadas',
      );

      expect(
        controller.totalAnswers.value,
        equals(999),
        reason: 'Total de respostas não deve ser resetado',
      );
    });

    test('isLoading retorna false após falha ao iniciar', () async {
      // Configuração: Sem energia disponível
      mockGamification.hasEnergyValue = false;
      mockGamification.hasUnlimitedValue = false;

      // Tentar iniciar lição
      await controller.startLesson('course_1', '1');

      // Verificar: isLoading é false
      expect(
        controller.isLoading.value,
        isFalse,
        reason: 'isLoading deve ser false após falha ao iniciar',
      );
    });

    test(
        'permite iniciar lição quando energia ilimitada está ativa apesar de 0 energia',
        () async {
      // Configuração: 0 energia mas ilimitada ativa
      mockGamification.hasEnergyValue = false; // 0 energia
      mockGamification.hasUnlimitedValue = true; // Mas ilimitada ativa
      mockGamification.energyConsumed = false;

      // Tentar iniciar lição (falhará no Firestore mas deve passar verificação de energia)
      await controller.startLesson('course_1', '1');

      // Verificar: NÃO mostrou erro de energia
      // (mostrará erro diferente sobre dados faltando no Firestore)
      expect(
        controller.errorMessage.value,
        isNot(contains('energia suficiente')),
        reason: 'Não deve mostrar erro de energia quando ilimitada está ativa',
      );

      // Verificar: Energia NÃO foi consumida (ilimitada ativa)
      expect(
        mockGamification.energyConsumed,
        isFalse,
        reason: 'Não deve consumir energia quando ilimitada está ativa',
      );
    });
  });
}

// Mock do GamificationController
class _MockGamificationController extends GetxController
    implements GamificationController {
  bool hasEnergyValue = true;
  bool hasUnlimitedValue = false;
  bool energyConsumed = false;

  final currentEnergy = 5.obs;

  @override
  bool get hasUnlimitedEnergy => hasUnlimitedValue;

  @override
  bool canStartLesson() => hasEnergyValue || hasUnlimitedValue;

  @override
  Future<void> onLessonStart() async {
    energyConsumed = true;
    if (currentEnergy.value > 0) {
      currentEnergy.value--;
    }
  }

  @override
  Future<void> onLessonComplete(int baseXp, int baseGems, bool isPerfect,
      {String lessonId = ''}) async {
    // Implementação mock
  }

  // Stub para outros métodos necessários
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
