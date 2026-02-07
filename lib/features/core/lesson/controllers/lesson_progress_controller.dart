import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Controller para gerenciar progresso da lição (hearts, accuracy, time, stats)
class LessonProgressController extends GetxController {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Constructor com DI
  LessonProgressController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final hearts = 3.obs;
  final correctAnswers = 0.obs;
  final totalAnswers = 0.obs;
  final startTime = Rx<DateTime?>(null);
  final pauseTime = Rx<DateTime?>(null);
  final accumulatedTime = 0.obs; // Tempo acumulado em milissegundos
  final lessonFailed = false.obs; // Flag para indicar que a lição falhou

  double get progress => 0.0; // Será calculado pela view usando currentExerciseIndex

  double get accuracy => totalAnswers.value > 0
      ? (correctAnswers.value / totalAnswers.value) * 100
      : 0.0;

  bool get isPerfect => totalAnswers.value > 0 && correctAnswers.value == totalAnswers.value;


  void initializeLessonState() {
    hearts.value = 3;
    correctAnswers.value = 0;
    totalAnswers.value = 0;
    startTime.value = DateTime.now();
    pauseTime.value = null;
    accumulatedTime.value = 0;
    lessonFailed.value = false;
    print('🔄 Estado da lição RESETADO - Corretas: 0, Total: 0');
  }

  void loseHeart() {
    if (hearts.value > 0) {
      hearts.value--;
    }
  }

  void addCorrectAnswer() {
    correctAnswers.value++;
    totalAnswers.value++;
    print('✅ Resposta CORRETA registrada - Corretas: ${correctAnswers.value}, Total: ${totalAnswers.value}, Accuracy: ${accuracy.toStringAsFixed(1)}%');
  }

  void addWrongAnswer() {
    totalAnswers.value++;
    print('❌ Resposta ERRADA registrada - Corretas: ${correctAnswers.value}, Total: ${totalAnswers.value}, Accuracy: ${accuracy.toStringAsFixed(1)}%');
  }

  void startTimer() {
    startTime.value = DateTime.now();
    pauseTime.value = null;
  }

  void pauseTimer() {
    if (startTime.value == null) return;
    
    if (pauseTime.value != null) return;
    
    final now = DateTime.now();
    final elapsed = now.difference(startTime.value!).inMilliseconds;
    accumulatedTime.value += elapsed;
    pauseTime.value = now;

    startTime.value = null;
  }

  void resumeTimer() {
    if (pauseTime.value == null) return;
    
    startTime.value = DateTime.now();
    pauseTime.value = null;
  }

  int getElapsedTime() {
    return _calculateTimeSpent();
  }

  String getFormattedTime() {
    final seconds = _calculateTimeSpent();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String getAccuracyLabel() {
    if (isPerfect) return 'Perfeito!';
    if (accuracy >= 90.0) return 'Excelente';
    if (accuracy >= 70.0) return 'Muito Bom';
    if (accuracy >= 50.0) return 'Bom';
    return 'Continue Praticando';
  }

  Future<void> saveInProgressState(String courseId, String lessonId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuário não autenticado');
    }
    
    final progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('progress')
        .doc(lessonId);
    
    final progressData = {
      'lessonId': lessonId,
      'status': 'in_progress',
      'hearts': hearts.value,
      'correctAnswers': correctAnswers.value,
      'totalAnswers': totalAnswers.value,
      'accumulatedTime': accumulatedTime.value,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
    
    try {
      await progressRef.set(progressData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Erro ao salvar estado da lição: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao salvar estado da lição: $e');
    }
  }

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

      hearts.value = progressData['hearts'] as int? ?? 3;
      correctAnswers.value = progressData['correctAnswers'] as int? ?? 0;
      totalAnswers.value = progressData['totalAnswers'] as int? ?? 0;
      accumulatedTime.value = progressData['accumulatedTime'] as int? ?? 0;

      startTime.value = DateTime.now();
      pauseTime.value = null;
    } catch (e) {
      errorMessage.value = 'Não foi possível retomar a lição. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  int _calculateTimeSpentMilliseconds() {
    if (startTime.value == null) return accumulatedTime.value;
    
    if (pauseTime.value != null) {
      return accumulatedTime.value;
    }

    final now = DateTime.now();
    final currentSessionTime = now.difference(startTime.value!).inMilliseconds;
    
    return accumulatedTime.value + currentSessionTime;
  }

  /// CORREÇÃO: Usar truncate em vez de round para evitar acúmulo de erros
  /// Round pode causar acúmulo de erros ao longo do tempo (ex: 0.6s vira 1s)
  /// Truncate sempre arredonda para baixo, sendo mais preciso
  int _calculateTimeSpent() {
    final milliseconds = _calculateTimeSpentMilliseconds();
    return (milliseconds / 1000).truncate();
  }
}
