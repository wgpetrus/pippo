import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Controller para gerenciar progresso da lição (hearts, accuracy, time, stats)
class LessonProgressController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados de execução (execution states)
  final hearts = 3.obs;
  final correctAnswers = 0.obs;
  final totalAnswers = 0.obs;
  final startTime = Rx<DateTime?>(null);
  final pauseTime = Rx<DateTime?>(null);
  final accumulatedTime = 0.obs; // Tempo acumulado em milissegundos
  final lessonFailed = false.obs; // Flag para indicar que a lição falhou

  // Getters
  double get progress => 0.0; // Será calculado pela view usando currentExerciseIndex

  double get accuracy => totalAnswers.value > 0
      ? (correctAnswers.value / totalAnswers.value) * 100
      : 0.0;

  bool get isPerfect => totalAnswers.value > 0 && accuracy == 100.0;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    // Não inicializar startTime aqui - será inicializado quando a lição começar
  }

  // Métodos públicos
  
  /// Inicializa o estado da lição quando ela realmente começa
  void initializeLessonState() {
    hearts.value = 3;
    correctAnswers.value = 0;
    totalAnswers.value = 0;
    startTime.value = DateTime.now();
    pauseTime.value = null;
    accumulatedTime.value = 0;
    lessonFailed.value = false;
  }
  
  /// Perde um coração
  void loseHeart() {
    if (hearts.value > 0) {
      hearts.value--;
    }
  }

  /// Adiciona uma resposta correta
  void addCorrectAnswer() {
    correctAnswers.value++;
    totalAnswers.value++;
  }

  /// Adiciona uma resposta errada
  void addWrongAnswer() {
    totalAnswers.value++;
  }

  /// Inicia o timer da lição
  void startTimer() {
    startTime.value = DateTime.now();
    pauseTime.value = null;
  }

  /// Pausa o timer da lição
  void pauseTimer() {
    if (startTime.value == null) return;
    
    // Se já está pausado, não fazer nada
    if (pauseTime.value != null) return;
    
    final now = DateTime.now();
    final elapsed = now.difference(startTime.value!).inMilliseconds;
    accumulatedTime.value += elapsed;
    pauseTime.value = now;
    
    // Resetar startTime para null para parar completamente o timer
    startTime.value = null;
  }

  /// Retoma o timer da lição
  void resumeTimer() {
    if (pauseTime.value == null) return;
    
    startTime.value = DateTime.now();
    pauseTime.value = null;
  }

  /// Retorna o tempo gasto em segundos
  int getElapsedTime() {
    return _calculateTimeSpent();
  }

  /// Retorna o tempo formatado como string (MM:SS)
  /// Para exibição na UI
  String getFormattedTime() {
    final seconds = _calculateTimeSpent();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Retorna o label de avaliação baseado na accuracy
  /// 
  /// Faixas:
  /// - 100%: Perfeito!
  /// - 90-99%: Excelente
  /// - 70-89%: Muito Bom
  /// - 50-69%: Bom
  /// - <50%: Continue Praticando
  String getAccuracyLabel() {
    if (accuracy == 100.0) return 'Perfeito!';
    if (accuracy >= 90.0) return 'Excelente';
    if (accuracy >= 70.0) return 'Muito Bom';
    if (accuracy >= 50.0) return 'Bom';
    return 'Continue Praticando';
  }

  /// Salva o estado atual da lição como in_progress
  /// Permite retomar a lição mais tarde sem consumir energia adicional
  Future<void> saveInProgressState(String courseId, String lessonId) async {
    debugPrint('💾 saveInProgressState() INICIADO');
    debugPrint('  📚 CourseId: $courseId');
    debugPrint('  📖 LessonId: $lessonId');
    
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('  ❌ Usuário não autenticado!');
      throw Exception('Usuário não autenticado');
    }
    
    debugPrint('  👤 UserId: $userId');
    
    final progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('progress')
        .doc(lessonId);
    
    debugPrint('  📍 Path: users/$userId/courses/$courseId/progress/$lessonId');
    
    final progressData = {
      'lessonId': lessonId,
      'status': 'in_progress',
      'hearts': hearts.value,
      'correctAnswers': correctAnswers.value,
      'totalAnswers': totalAnswers.value,
      'accumulatedTime': accumulatedTime.value,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
    
    debugPrint('  📦 Dados a salvar: $progressData');
    
    try {
      await progressRef.set(progressData, SetOptions(merge: true));
      debugPrint('  ✅ Progresso salvo com sucesso no Firestore!');
    } on FirebaseException catch (e) {
      debugPrint('  ❌ FirebaseException: ${e.code} - ${e.message}');
      throw Exception('Erro ao salvar estado da lição: ${e.message}');
    } catch (e) {
      debugPrint('  ❌ Exception: $e');
      debugPrint('  Stack trace: ${StackTrace.current}');
      throw Exception('Erro ao salvar estado da lição: $e');
    }
  }

  /// Retoma uma lição em progresso sem consumir energia adicional
  /// 
  /// Carrega progresso da lição do Firestore e restaura:
  /// - hearts, correctAnswers, totalAnswers
  /// - accumulatedTime
  /// 
  /// NÃO consome energia adicional
  /// Continua do exercício salvo
  Future<void> resumeLesson(String courseId, String lessonId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Carregar progresso salvo do Firestore
      final progressDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .doc(lessonId)
          .get();

      if (!progressDoc.exists) {
        errorMessage.value = 'Progresso da lição não encontrado.';
        return;
      }

      final progressData = progressDoc.data()!;
      final status = progressData['status'] as String?;

      // Verificar se lição está em progresso
      if (status != 'in_progress') {
        errorMessage.value = 'Esta lição não está em progresso.';
        return;
      }

      // Restaurar estado da lição do progresso salvo
      hearts.value = progressData['hearts'] as int? ?? 3;
      correctAnswers.value = progressData['correctAnswers'] as int? ?? 0;
      totalAnswers.value = progressData['totalAnswers'] as int? ?? 0;
      accumulatedTime.value = progressData['accumulatedTime'] as int? ?? 0;

      // Reiniciar startTime para continuar rastreamento de tempo
      startTime.value = DateTime.now();
      pauseTime.value = null;

      // NÃO consome energia adicional - apenas restaura estado

    } catch (e) {
      errorMessage.value = 'Não foi possível retomar a lição. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos privados
  
  /// Calcula o tempo gasto na lição em milissegundos
  /// Inclui apenas tempo ativo (exclui tempo de pausa)
  /// Acumula tempo através de sessões de resume
  /// 
  /// Retorna tempo total em milissegundos
  int _calculateTimeSpentMilliseconds() {
    // Se não há startTime, retorna apenas tempo acumulado (lição pausada ou não iniciada)
    if (startTime.value == null) return accumulatedTime.value;
    
    // Se está pausado, retorna apenas tempo acumulado
    if (pauseTime.value != null) {
      return accumulatedTime.value;
    }
    
    // Se está ativo, adiciona tempo desde último start ao tempo acumulado
    final now = DateTime.now();
    final currentSessionTime = now.difference(startTime.value!).inMilliseconds;
    
    return accumulatedTime.value + currentSessionTime;
  }
  
  /// Calcula o tempo gasto na lição em segundos
  /// Converte de milissegundos para segundos para armazenamento
  int _calculateTimeSpent() {
    final milliseconds = _calculateTimeSpentMilliseconds();
    return (milliseconds / 1000).round();
  }
}
