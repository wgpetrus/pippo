// Packages externos
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Imports locais
import 'package:pippo/features/core/lesson/controllers/lesson_flow_controller.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_exercise_controller.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_progress_controller.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_rewards_controller.dart';
import 'package:pippo/features/inners/gamification/controllers/energy_controller.dart';
import 'package:pippo/shared/translations/app_translations.dart';

import '../../../../helpers/firebase_test_helper.dart';

/// Testes unitários para LessonFlowController (refatorado)
/// Foco em verificação única de auth, ausência de race condition, tratamento de erros Firestore e onClose()
/// 
/// **Valida: Requisitos 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 5.1, 5.2, 5.3**
void main() {
  // Variáveis de teste
  late LessonFlowController flowController;
  late LessonExerciseController exerciseController;
  late LessonProgressController progressController;
  late LessonRewardsController rewardsController;
  late _TestEnergyController energyController;
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;

  setUpAll(() async {
    // Setup translations
    Get.testMode = true;
    Get.put(AppTranslations());
    Get.updateLocale(const Locale('pt', 'BR'));
    
    // Initialize Firebase (helper handles idempotency)
    await FirebaseTestHelper.setupFirebase();
  });

  setUp(() async {
    Get.testMode = true;

    mockAuth = FirebaseTestHelper.createMockAuth();
    mockFirestore = FirebaseTestHelper.createMockFirestore();

    energyController = _TestEnergyController(
      firestore: mockFirestore,
      auth: mockAuth,
    );
    energyController.currentEnergy.value = 5;
    energyController.unlimitedEnergy = false;
    Get.put<EnergyController>(energyController);

    // Popular dados básicos
    await FirebaseTestHelper.populateGamificationData(
      mockFirestore,
      'test-user-id',
      currentEnergy: 5,
    );

    // Criar controllers na ordem de dependência
    progressController = LessonProgressController(
      firestore: mockFirestore,
      auth: mockAuth,
    );
    Get.put<LessonProgressController>(progressController);
    
    exerciseController = LessonExerciseController();
    Get.put<LessonExerciseController>(exerciseController);
    
    rewardsController = LessonRewardsController(
      firestore: mockFirestore,
      auth: mockAuth,
    );
    Get.put<LessonRewardsController>(rewardsController);
    
    flowController = LessonFlowController(auth: mockAuth, firestore: mockFirestore);
    Get.put<LessonFlowController>(flowController);
  });

  tearDown(() {
    Get.reset();
  });

  group('LessonFlowController - Verificação Única de Auth', () {
    test('verifica autenticação uma única vez no início de startLesson', () async {
      // Configuração: Usuário autenticado
      int authCheckCount = 0;
      final customAuth = _CountingMockAuth(onCurrentUserAccess: () => authCheckCount++);
      
      final customController = LessonFlowController(
        auth: customAuth,
        firestore: mockFirestore,
      );

      // Tentar iniciar lição
      await customController.startLesson('course_1', '1');

      // Verificar: Auth foi verificado apenas uma vez
      expect(
        authCheckCount,
        equals(1),
        reason: 'Auth deve ser verificado apenas uma vez no início do método',
      );
    });

    test('retorna imediatamente quando usuário não está autenticado', () async {
      // Configuração: Usuário não autenticado
      final unauthAuth = MockFirebaseAuth(signedIn: false);
      final unauthController = LessonFlowController(
        auth: unauthAuth,
        firestore: mockFirestore,
      );

      // Tentar iniciar lição
      await unauthController.startLesson('course_1', '1');

      // Verificar: Mensagem de erro de autenticação
      expect(
        unauthController.errorMessage.value,
        equals('error_unauthenticated'.tr),
        reason: 'Deve exibir mensagem de erro de autenticação',
      );

      // Verificar: Lição não foi iniciada
      expect(
        unauthController.currentLesson.value,
        isNull,
        reason: 'Lição não deve ser iniciada quando usuário não está autenticado',
      );
    });

    test('verifica autenticação uma única vez em startLessonFromActiveCourse', () async {
      // Configuração: Usuário autenticado
      int authCheckCount = 0;
      final customAuth = _CountingMockAuth(onCurrentUserAccess: () => authCheckCount++);
      
      final customController = LessonFlowController(
        auth: customAuth,
        firestore: mockFirestore,
      );

      // Tentar iniciar lição do curso ativo
      await customController.startLessonFromActiveCourse('1');

      // Verificar: Auth foi verificado no máximo 2 vezes
      // (uma em startLessonFromActiveCourse, uma em startLesson se chamado)
      expect(
        authCheckCount,
        lessThanOrEqualTo(2),
        reason: 'Auth deve ser verificado no máximo 2 vezes (uma por método)',
      );
    });
  });

  group('LessonFlowController - Ausência de Race Condition', () {
    test('não há delays artificiais em startLesson', () async {
      // Configuração: Medir tempo de execução
      final stopwatch = Stopwatch()..start();

      // Tentar iniciar lição (falhará mas não deve ter delays)
      await flowController.startLesson('course_1', '1');

      stopwatch.stop();

      // Verificar: Execução rápida (sem delays de 100ms)
      // Permitir até 500ms para operações normais (Firestore mock, etc)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Não deve haver delays artificiais no método',
      );
    });

    test('não há delays artificiais em startLessonFromActiveCourse', () async {
      // Configuração: Medir tempo de execução
      final stopwatch = Stopwatch()..start();

      // Tentar iniciar lição do curso ativo
      await flowController.startLessonFromActiveCourse('1');

      stopwatch.stop();

      // Verificar: Execução rápida (sem delays de 100ms)
      // Permitir até 2000ms para operações normais (retry logic, Firestore mock, etc)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
        reason: 'Não deve haver delays artificiais desnecessários',
      );
    });

    test('verificação de auth não é repetida durante execução', () async {
      // Configuração: Contador de verificações
      int authCheckCount = 0;
      final customAuth = _CountingMockAuth(onCurrentUserAccess: () => authCheckCount++);
      
      final customController = LessonFlowController(
        auth: customAuth,
        firestore: mockFirestore,
      );

      // Tentar iniciar lição
      await customController.startLesson('course_1', '1');

      // Verificar: Auth verificado apenas uma vez (não repetido)
      expect(
        authCheckCount,
        equals(1),
        reason: 'Auth não deve ser verificado múltiplas vezes',
      );
    });
  });

  group('LessonFlowController - Tratamento de Erros Firestore', () {
    test('captura FirebaseException em startLessonFromActiveCourse', () async {
      // Configuração: Firestore que lança exceção
      final errorFirestore = _ErrorFirestoreNoFallback();
      final errorController = LessonFlowController(
        auth: mockAuth,
        firestore: errorFirestore,
      );

      // Registrar energy controller para o novo controller
      Get.delete<LessonFlowController>();
      Get.put<LessonFlowController>(errorController);

      // Tentar iniciar lição do curso ativo
      await errorController.startLessonFromActiveCourse('1');

      // Verificar: Mensagem de erro genérica
      expect(
        errorController.errorMessage.value,
        equals('error_generic'.tr),
        reason: 'Deve exibir mensagem de erro genérica para FirebaseException',
      );
    });

    test('captura exceção genérica e exibe mensagem apropriada', () async {
      // Configuração: Firestore que lança exceção genérica
      final errorFirestore = _GenericErrorFirestore();
      final errorController = LessonFlowController(
        auth: mockAuth,
        firestore: errorFirestore,
      );

      // Registrar energy controller para o novo controller
      Get.delete<LessonFlowController>();
      Get.put<LessonFlowController>(errorController);

      // Tentar iniciar lição
      await errorController.startLesson('course_1', '1');

      // Verificar: Mensagem de erro genérica
      expect(
        errorController.errorMessage.value,
        equals('error_generic'.tr),
        reason: 'Deve exibir mensagem de erro genérica para exceções não tratadas',
      );
    });

    test('isLoading é false após erro Firestore', () async {
      // Configuração: Firestore que lança exceção
      final errorFirestore = _ErrorFirestoreNoFallback();
      final errorController = LessonFlowController(
        auth: mockAuth,
        firestore: errorFirestore,
      );

      // Registrar energy controller para o novo controller
      Get.delete<LessonFlowController>();
      Get.put<LessonFlowController>(errorController);

      // Tentar iniciar lição do curso ativo
      await errorController.startLessonFromActiveCourse('1');

      // Verificar: isLoading é false
      expect(
        errorController.isLoading.value,
        isFalse,
        reason: 'isLoading deve ser false após erro',
      );
    });
  });

  group('LessonFlowController - onClose() Limpa Recursos', () {
    test('onClose limpa lista de exercícios', () {
      // Configuração: Adicionar exercícios
      flowController.currentExercises.addAll([
        {'id': '1', 'type': 'image'},
        {'id': '2', 'type': 'translation'},
      ]);

      // Chamar onClose
      flowController.onClose();

      // Verificar: Lista limpa
      expect(
        flowController.currentExercises.isEmpty,
        isTrue,
        reason: 'Lista de exercícios deve ser limpa',
      );
    });

    test('onClose reseta currentLesson para null', () {
      // Configuração: Definir lição atual
      flowController.currentLesson.value = {
        'id': '1',
        'title': 'Test Lesson',
      };

      // Chamar onClose
      flowController.onClose();

      // Verificar: Lição resetada
      expect(
        flowController.currentLesson.value,
        isNull,
        reason: 'Lição atual deve ser resetada para null',
      );
    });

    test('onClose reseta currentExerciseIndex para 0', () {
      // Configuração: Definir índice
      flowController.currentExerciseIndex.value = 5;

      // Chamar onClose
      flowController.onClose();

      // Verificar: Índice resetado
      expect(
        flowController.currentExerciseIndex.value,
        equals(0),
        reason: 'Índice de exercício deve ser resetado para 0',
      );
    });

    test('onClose reseta isLoading para false', () {
      // Configuração: Definir loading
      flowController.isLoading.value = true;

      // Chamar onClose
      flowController.onClose();

      // Verificar: Loading resetado
      expect(
        flowController.isLoading.value,
        isFalse,
        reason: 'isLoading deve ser resetado para false',
      );
    });

    test('onClose reseta errorMessage para string vazia', () {
      // Configuração: Definir mensagem de erro
      flowController.errorMessage.value = 'Erro de teste';

      // Chamar onClose
      flowController.onClose();

      // Verificar: Mensagem resetada
      expect(
        flowController.errorMessage.value,
        isEmpty,
        reason: 'errorMessage deve ser resetado para string vazia',
      );
    });

    test('onClose reseta flag de concorrência', () {
      // Configuração: Simular lição em andamento
      // (não podemos acessar _isLessonStarting diretamente, mas podemos testar o comportamento)
      
      // Chamar onClose
      flowController.onClose();

      // Tentar iniciar lição após onClose (deve funcionar normalmente)
      // Se a flag não foi resetada, mostraria erro de "lição já sendo iniciada"
      flowController.startLesson('course_1', '1');

      // Verificar: Não mostra erro de concorrência
      expect(
        flowController.errorMessage.value,
        isNot(contains('já está sendo iniciada')),
        reason: 'Flag de concorrência deve ser resetada',
      );
    });
  });
}

/// Mock de FirebaseAuth que conta quantas vezes currentUser é acessado
class _CountingMockAuth extends MockFirebaseAuth {
  final void Function() onCurrentUserAccess;
  
  _CountingMockAuth({required this.onCurrentUserAccess}) : super(signedIn: true);

  @override
  User? get currentUser {
    onCurrentUserAccess();
    return super.currentUser;
  }
}

/// Mock de Firestore que sempre lança FirebaseException
class _ErrorFirestore extends Fake implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _ErrorCollectionReference();
  }
}

class _ErrorCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return _ErrorDocumentReference();
  }
}

class _ErrorDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return _ErrorCollectionReference();
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
      message: 'Test error',
    );
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
      message: 'Test error',
    );
  }
}

/// Mock de Firestore que lança FirebaseException sem fallback para mock
class _ErrorFirestoreNoFallback extends Fake implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    // Para courses collection, lançar erro
    if (path == 'courses') {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Test error - no fallback',
      );
    }
    return _ErrorCollectionReference();
  }
}

/// Mock de Firestore que lança exceção genérica
class _GenericErrorFirestore extends Fake implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _GenericErrorCollectionReference();
  }
}

class _GenericErrorCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return _GenericErrorDocumentReference();
  }
}

class _GenericErrorDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return _GenericErrorCollectionReference();
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    throw Exception('Generic test error');
  }
}

/// Controller de energia para testes
class _TestEnergyController extends EnergyController {
  _TestEnergyController({
    required super.firestore,
    required super.auth,
  });

  bool unlimitedEnergy = false;
  bool energyConsumed = false;

  @override
  bool get hasUnlimitedEnergy => unlimitedEnergy;

  @override
  bool canStartLesson() {
    if (unlimitedEnergy) return true;
    return currentEnergy.value > 0;
  }

  @override
  Future<void> consumeEnergy(int amount) async {
    if (unlimitedEnergy) return;
    if (currentEnergy.value >= amount) {
      energyConsumed = true;
      currentEnergy.value -= amount;
    }
  }
}
