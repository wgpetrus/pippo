import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../inners/gamification/controllers/energy_controller.dart';
import '../../../../shared/mocks/lesson_mocks.dart';
import 'lesson_progress_controller.dart';

/// Controller para gerenciar o fluxo de lições
class LessonFlowController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  // Dependências
  late final EnergyController _energyController;

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
    } catch (e) {
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
  Future<void> startLessonFromActiveCourse(String lessonId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Buscar curso ativo do usuário
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (coursesSnapshot.docs.isEmpty) {
        debugPrint('⚠️ Nenhum curso ativo encontrado, usando mock_course_id');
        // Usar courseId mockado como fallback
        await startLesson('mock_course_id', lessonId);
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;
      debugPrint('✅ Curso ativo encontrado: $courseId');
      
      await startLesson(courseId, lessonId);
    } catch (e) {
      debugPrint('❌ Erro ao buscar curso ativo: $e');
      errorMessage.value = 'Não foi possível carregar o curso. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Inicia uma lição seguindo a ordem CRÍTICA de operações
  /// 
  /// Ordem obrigatória:
  /// 1. Validar lição desbloqueada
  /// 2. Validar energia disponível (ou ilimitada ativa)
  /// 3. Consumir energia (operação atômica via EnergyController)
  /// 4. Inicializar estado da lição (hearts=3, counters=0, startTime)
  /// 5. Carregar exercícios do Firestore
  /// 6. Navegar para primeiro exercício
  /// 
  /// Em caso de erro: exibe mensagem, NÃO consome energia
  /// Previne múltiplos inícios simultâneos
  Future<void> startLesson(String courseId, String lessonId) async {
    // Prevenir múltiplos inícios simultâneos (concurrency prevention)
    if (_isLessonStarting) {
      errorMessage.value = 'Uma lição já está sendo iniciada. Aguarde.';
      return;
    }

    _isLessonStarting = true;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Step 1: Validar lição desbloqueada
      final lessonIdInt = int.tryParse(lessonId);
      if (lessonIdInt == null) {
        errorMessage.value = 'ID de lição inválido.';
        return;
      }

      final isUnlocked = await _isLessonUnlocked(courseId, lessonIdInt);
      if (!isUnlocked) {
        errorMessage.value = 'Complete a lição anterior para desbloquear esta.';
        return;
      }

      // Step 2: Validar energia disponível (ou ilimitada ativa)
      if (!_energyController.canStartLesson()) {
        errorMessage.value = 'Você não tem energia suficiente. Aguarde a regeneração ou compre mais energia.';
        return;
      }

      // Step 3: Consumir energia (operação atômica via EnergyController)
      // Delega para EnergyController que gerencia energia corretamente
      await _energyController.consumeEnergy(1);
      
      // Verificar se houve erro ao consumir energia
      if (_energyController.errorMessage.value.isNotEmpty) {
        errorMessage.value = _energyController.errorMessage.value;
        return;
      }

      // Step 4: Inicializar estado da lição
      // Obter LessonProgressController e inicializar estado
      final progressController = Get.find<LessonProgressController>();
      progressController.initializeLessonState();
      
      currentExerciseIndex.value = 0;

      // Step 5: Carregar exercícios do Firestore
      try {
        await _loadLessonData(courseId, lessonId);
      } catch (e) {
        // Erro ao carregar dados - energia já foi consumida, mas não há como refundar
        // Apenas exibe erro
        errorMessage.value = 'Não foi possível carregar os exercícios. Tente novamente.';
        _resetLessonState();
        return;
      }

      // Validar que todos os exercícios têm dados válidos
      if (!_validateExerciseData()) {
        errorMessage.value = 'Dados dos exercícios inválidos. Tente novamente.';
        _resetLessonState();
        return;
      }

      // Step 6: Navegar para primeiro exercício
      // A navegação será feita pela view após sucesso
      // Controller apenas sinaliza que está pronto via isLoading = false
      
    } catch (e) {
      // Em caso de erro inesperado, exibe mensagem
      errorMessage.value = 'Não foi possível carregar a lição. Tente novamente.';
      
      // Reset estados em caso de erro
      _resetLessonState();
    } finally {
      _isLessonStarting = false;
      isLoading.value = false;
    }
  }

  /// Avança para o próximo exercício
  void nextExercise() {
    debugPrint('➡️ nextExercise() INICIADO');
    debugPrint('  📊 CurrentExerciseIndex: ${currentExerciseIndex.value}');
    debugPrint('  📚 Total Exercises: ${currentExercises.length}');
    
    if (currentExerciseIndex.value < currentExercises.length) {
      currentExerciseIndex.value++;
      debugPrint('  ✅ Avançado para exercício ${currentExerciseIndex.value}');
    }
    
    debugPrint('✅ nextExercise() CONCLUÍDO');
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
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    try {
      debugPrint('🔍 Carregando lição: courseId=$courseId, lessonId=$lessonId');
      
      // Tentar carregar dados da lição do Firestore
      final lessonDoc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .get();

      if (!lessonDoc.exists) {
        debugPrint('⚠️ Lição não encontrada no Firestore, usando dados mockados');
        
        // Usar dados mockados
        final mockLesson = LessonMocks.getLesson(courseId, lessonId);
        if (mockLesson == null) {
          debugPrint('❌ Lição não encontrada nem no Firestore nem nos mocks');
          throw Exception('Lição não encontrada');
        }

        debugPrint('✅ Lição mockada encontrada: ${mockLesson['title']}');

        // Extrair exercícios dos mocks
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
        
        debugPrint('✅ ${currentExercises.length} exercícios mockados carregados com sucesso');
        return;
      }

      debugPrint('✅ Lição encontrada no Firestore: ${lessonDoc.data()}');

      currentLesson.value = {
        'id': lessonDoc.id,
        'courseId': courseId,
        ...lessonDoc.data()!,
      };

      // Carregar exercícios da lição do Firestore
      debugPrint('🔍 Carregando exercícios da lição do Firestore...');
      final exercisesSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('exercises')
          .orderBy('order')
          .get();

      debugPrint('📊 Exercícios encontrados no Firestore: ${exercisesSnapshot.docs.length}');

      if (exercisesSnapshot.docs.isEmpty) {
        debugPrint('❌ Nenhum exercício encontrado no Firestore para esta lição');
        throw Exception('Nenhum exercício encontrado');
      }

      currentExercises.value = exercisesSnapshot.docs
          .map((doc) {
            debugPrint('  - Exercício ${doc.id}: ${doc.data()}');
            return {
              'id': doc.id,
              ...doc.data(),
            };
          })
          .toList();
      
      debugPrint('✅ ${currentExercises.length} exercícios carregados com sucesso do Firestore');
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} - ${e.message}');
      
      // Tentar usar mocks como fallback
      debugPrint('⚠️ Tentando usar dados mockados como fallback...');
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
        debugPrint('✅ Usando dados mockados como fallback');
        return;
      }
      
      throw Exception('Erro ao carregar lição: ${e.message}');
    } catch (e) {
      debugPrint('❌ Erro genérico: $e');
      throw Exception('Erro ao carregar lição: $e');
    }
  }
  
  /// Verifica se a lição está desbloqueada
  /// Lição 1 sempre desbloqueada, outras requerem lição anterior completa
  Future<bool> _isLessonUnlocked(String courseId, int lessonId) async {
    try {
      // Lição 1 sempre desbloqueada
      if (lessonId == 1) return true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

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
