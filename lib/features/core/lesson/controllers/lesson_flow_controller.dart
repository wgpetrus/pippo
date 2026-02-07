import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../inners/gamification/controllers/energy_controller.dart';
import '../../../../shared/mocks/lesson_mocks.dart';
import 'lesson_progress_controller.dart';

/// Controller para gerenciar o fluxo de lições
class LessonFlowController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  // Dependências
  EnergyController? _energyController;

  LessonFlowController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados da lição (lesson data)
  final currentLesson = Rx<Map<String, dynamic>?>(null);
  final currentExercises = <Map<String, dynamic>>[].obs;
  final currentExerciseIndex = 0.obs;

  // Concurrency prevention
  bool _isLessonStarting = false;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    try {
      _energyController = Get.find<EnergyController>();
    } catch (_) {
      errorMessage.value = 'Erro ao inicializar sistema de energia.';
    }
  }

  @override
  void onClose() {
    // Reset dos estados da lição ao fechar o controller
    _resetLessonState();
    
    // Reset da flag de concorrência
    _isLessonStarting = false;
    
    super.onClose();
  }

  // Métodos públicos
  
  /// Inicia uma lição do curso ativo do usuário
  /// Busca automaticamente o courseId do curso ativo no Firestore
  /// Implementa retry logic e fallback para lidar com timing do Firestore
  Future<void> startLessonFromActiveCourse(String lessonId) async {
    print('🚀 startLessonFromActiveCourse: Iniciando...');
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // VERIFICAR AUTENTICAÇÃO PRIMEIRO (CRÍTICO)
      // Aguardar um pouco para garantir que Firebase Auth está pronto
      await Future.delayed(const Duration(milliseconds: 100));
      
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ startLessonFromActiveCourse: Firebase Auth currentUser é null');
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final userId = user.uid;
      if (userId.isEmpty) {
        print('❌ startLessonFromActiveCourse: userId está vazio');
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      print('✅ startLessonFromActiveCourse: Usuário autenticado - userId: $userId');

      String? courseId;

      // Tentar 3 vezes com delay para dar tempo do Firestore indexar
      print('🔍 Buscando curso ativo...');
      for (int attempt = 1; attempt <= 3; attempt++) {
        print('  Tentativa $attempt/3...');
        final coursesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();

        if (coursesSnapshot.docs.isNotEmpty) {
          courseId = coursesSnapshot.docs.first.id;
          print('✅ Curso ativo encontrado: $courseId');
          break;
        }

        // Se não encontrou e não é a última tentativa, aguardar
        if (attempt < 3) {
          print('  ⏳ Aguardando ${500 * attempt}ms antes da próxima tentativa...');
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }

      // Se ainda não encontrou curso ativo, buscar qualquer curso
      if (courseId == null) {
        print('⚠️ Nenhum curso ativo encontrado, buscando qualquer curso...');
        final allCoursesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .limit(1)
            .get();

        if (allCoursesSnapshot.docs.isNotEmpty) {
          courseId = allCoursesSnapshot.docs.first.id;
          print('📚 Curso encontrado: $courseId, marcando como ativo...');
          
          // Marcar este curso como ativo
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('courses')
              .doc(courseId)
              .update({'isActive': true});
          
          print('✅ Curso marcado como ativo');
        } else {
          // Nenhum curso encontrado, usar mock
          print('⚠️ Nenhum curso encontrado, usando mock');
          await startLesson('mock_course_id', lessonId);
          return;
        }
      }

      print('🎯 Iniciando lição $lessonId do curso $courseId');
      await startLesson(courseId, lessonId);
    } catch (e) {
      print('❌ startLessonFromActiveCourse: Erro - $e');
      errorMessage.value = 'Não foi possível carregar o curso. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startLesson(String courseId, String lessonId) async {
    if (_isLessonStarting) {
      errorMessage.value = 'Uma lição já está sendo iniciada. Aguarde.';
      return;
    }

    _isLessonStarting = true;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // VERIFICAR AUTENTICAÇÃO PRIMEIRO (CRÍTICO)
      // Aguardar um pouco para garantir que Firebase Auth está pronto
      await Future.delayed(const Duration(milliseconds: 100));
      
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ startLesson: Firebase Auth currentUser é null');
        errorMessage.value = 'Usuário não autenticado. Por favor, faça login novamente.';
        return;
      }

      final userId = user.uid;
      if (userId.isEmpty) {
        print('❌ startLesson: userId está vazio');
        errorMessage.value = 'Usuário não autenticado. Por favor, faça login novamente.';
        return;
      }

      print('✅ startLesson: Usuário autenticado - userId: $userId');

      final lessonIdInt = int.tryParse(lessonId);
      if (lessonIdInt == null) {
        errorMessage.value = 'ID de lição inválido.';
        return;
      }

      print('🔓 Verificando se lição $lessonIdInt está desbloqueada...');
      final isUnlocked = await _isLessonUnlocked(courseId, lessonIdInt);
      if (!isUnlocked) {
        errorMessage.value = 'Complete a lição anterior para desbloquear esta.';
        return;
      }
      print('✅ Lição desbloqueada');

      if (_energyController == null) {
        errorMessage.value = 'Erro ao inicializar sistema de energia.';
        return;
      }

      if (!_energyController!.canStartLesson()) {
        errorMessage.value = 'Você não tem energia suficiente. Aguarde a regeneração ou compre mais energia.';
        return;
      }

      print('⚡ Consumindo energia...');
      await _energyController!.consumeEnergy(1);

      if (_energyController!.errorMessage.value.isNotEmpty) {
        errorMessage.value = _energyController!.errorMessage.value;
        return;
      }

      final progressController = Get.find<LessonProgressController>();
      progressController.initializeLessonState();

      currentExerciseIndex.value = 0;

      try {
        await _loadLessonData(courseId, lessonId);
      } catch (e) {
        errorMessage.value = 'Não foi possível carregar os exercícios. Tente novamente.';
        _resetLessonState();
        return;
      }

      if (!_validateExerciseData()) {
        errorMessage.value = 'Dados dos exercícios inválidos. Tente novamente.';
        _resetLessonState();
        return;
      }
    } catch (e) {
      errorMessage.value = 'Não foi possível carregar a lição. Tente novamente.';
      _resetLessonState();
    } finally {
      // CORREÇÃO: Sempre resetar flag, mesmo em caso de erro
      _isLessonStarting = false;
      isLoading.value = false;
    }
  }

  void nextExercise() {
    if (currentExerciseIndex.value < currentExercises.length) {
      currentExerciseIndex.value++;
    }
  }

  /// Sai da lição sem completar
  void exitLesson() {
    _resetLessonState();
  }

  // Métodos privados
  
  /// Reseta os estados da lição
  void _resetLessonState() {
    currentLesson.value = null;
    currentExercises.clear();
    currentExerciseIndex.value = 0;
  }

  /// Valida que todos os exercícios têm dados válidos
  /// Retorna true se todos os exercícios são válidos, false caso contrário
  bool _validateExerciseData() {
    if (currentExercises.isEmpty) return false;
    
    for (final exercise in currentExercises) {
      final type = exercise['type'] as String?;
      final order = exercise['order'] as int?;
      
      // Validar tipo de exercício
      if (type == null || !['image', 'translation', 'word_order', 'match'].contains(type)) {
        return false;
      }
      
      // Validar ordem
      if (order == null || order < 0) {
        return false;
      }
      
      // Validar dados específicos por tipo
      switch (type) {
        case 'image':
          final options = exercise['options'] as List?;
          if (options == null || options.length != 4) return false;
          if (!options.any((opt) => opt['isCorrect'] == true)) return false;
          break;
          
        case 'translation':
          final options = exercise['options'] as List?;
          if (options == null || options.length != 4) return false;
          if (!options.any((opt) => opt['isCorrect'] == true)) return false;
          break;
          
        case 'word_order':
          final correctOrder = exercise['correctOrder'] as List?;
          if (correctOrder == null || correctOrder.isEmpty) return false;
          break;
          
        case 'match':
          final pairs = exercise['pairs'] as List?;
          if (pairs == null || pairs.length != 4) return false;
          break;
      }
    }
    
    return true;
  }
  
  /// Carrega dados da lição e exercícios do Firestore com validação
  /// Se não encontrar no Firestore, usa dados mockados
  /// Lança exceção se dados não forem encontrados ou inválidos
  Future<void> _loadLessonData(String courseId, String lessonId) async {
    print('📚 _loadLessonData: Iniciando carregamento...');
    
    // VERIFICAR AUTENTICAÇÃO PRIMEIRO (CRÍTICO)
    // Aguardar um pouco para garantir que Firebase Auth está pronto
    await Future.delayed(const Duration(milliseconds: 100));
    
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ _loadLessonData: Firebase Auth currentUser é null');
      throw Exception('Usuário não autenticado');
    }

    final userId = user.uid;
    if (userId.isEmpty) {
      print('❌ _loadLessonData: userId está vazio');
      throw Exception('Usuário não autenticado');
    }

    print('✅ _loadLessonData: Usuário autenticado - userId: $userId');

    try {
      final lessonDoc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .get();

      if (!lessonDoc.exists) {
        final mockLesson = LessonMocks.getLesson(courseId, lessonId);
        if (mockLesson == null) {
          throw Exception('Lição não encontrada');
        }

        final mockExercises = mockLesson['exercises'] as List<Map<String, dynamic>>;
        
        currentLesson.value = {
          'id': mockLesson['id'],
          'courseId': mockLesson['courseId'],
          'title': mockLesson['title'],
          'description': mockLesson['description'],
          'xpReward': mockLesson['xpReward'],
          'gemsReward': mockLesson['gemsReward'],
          'isLocked': mockLesson['isLocked'],
        };

        currentExercises.value = mockExercises;
        print('📚 _loadLessonData: ${mockExercises.length} exercícios carregados do mock');
        print('📋 Exercícios: ${mockExercises.map((e) => e['type']).toList()}');
        return;
      }

      currentLesson.value = {
        'id': lessonDoc.id,
        'courseId': courseId,
        ...lessonDoc.data()!,
      };

      final exercisesSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('exercises')
          .orderBy('order')
          .get();

      if (exercisesSnapshot.docs.isEmpty) {
        throw Exception('Nenhum exercício encontrado');
      }

      currentExercises.value = exercisesSnapshot.docs
          .map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          })
          .toList();
    } on FirebaseException catch (e) {
      final mockLesson = LessonMocks.getLesson(courseId, lessonId);
      if (mockLesson != null) {
        final mockExercises = mockLesson['exercises'] as List<Map<String, dynamic>>;
        
        currentLesson.value = {
          'id': mockLesson['id'],
          'courseId': mockLesson['courseId'],
          'title': mockLesson['title'],
          'description': mockLesson['description'],
          'xpReward': mockLesson['xpReward'],
          'gemsReward': mockLesson['gemsReward'],
          'isLocked': mockLesson['isLocked'],
        };

        currentExercises.value = mockExercises;
        print('📚 _loadLessonData (fallback): ${mockExercises.length} exercícios carregados do mock');
        print('📋 Exercícios: ${mockExercises.map((e) => e['type']).toList()}');
        return;
      }

      throw Exception('Erro ao carregar lição: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao carregar lição: $e');
    }
  }
  
  /// Verifica se a lição está desbloqueada
  /// Lição 1 sempre desbloqueada, outras requerem lição anterior completa
  Future<bool> _isLessonUnlocked(String courseId, int lessonId) async {
    try {
      // Lição 1 sempre desbloqueada
      if (lessonId == 1) return true;

      // VERIFICAR AUTENTICAÇÃO PRIMEIRO (CRÍTICO)
      // Aguardar um pouco para garantir que Firebase Auth está pronto
      await Future.delayed(const Duration(milliseconds: 100));
      
      final user = _auth.currentUser;
      if (user == null) return false;

      final userId = user.uid;
      if (userId.isEmpty) return false;

      // Verifica se lição anterior (lessonId - 1) está completa
      final previousLessonId = lessonId - 1;
      final progressDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .doc(previousLessonId.toString())
          .get();

      if (!progressDoc.exists) return false;

      final status = progressDoc.data()?['status'] as String?;
      return status == 'completed';
    } catch (e) {
      return false;
    }
  }
}
