import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';
import 'gems_controller.dart';

class StreakController extends GetxController {
  // Dependency Injection com valores padrão (backward compatible)
  StreakController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final currentStreak = 0.obs;
  final longestStreak = 0.obs;

  String _lastStreakDate = '';
  bool _streakFreezeAvailable = false;
  bool _streakFreezeUsedToday = false;
  List<int> _milestonesReached = [];

  GemsController? _gemsController;

  bool get streakFreezeAvailable => _streakFreezeAvailable;

  @override
  void onInit() {
    super.onInit();
    try {
      _gemsController = Get.find<GemsController>();
    } catch (e) {
      _gemsController = null;
    }
    
    // Carregar dados ao inicializar
    loadStreak();
  }

  @override
  void onClose() {
    // Resetar estados
    isLoading.value = false;
    errorMessage.value = '';
    currentStreak.value = 0;
    longestStreak.value = 0;

    super.onClose();
  }

  Future<void> loadStreak() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      String? courseId;

      // Tentar 3 vezes com delay para dar tempo do Firestore indexar
      for (int attempt = 1; attempt <= 3; attempt++) {
        final coursesSnapshot = await _retryOperation(
          () => _firestore
              .collection('users')
              .doc(userId)
              .collection('courses')
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get()
              .timeout(const Duration(seconds: 30)),
        );

        if (coursesSnapshot.docs.isNotEmpty) {
          courseId = coursesSnapshot.docs.first.id;
          break;
        }

        // Se não encontrou e não é a última tentativa, aguardar
        if (attempt < 3) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }

      // Se ainda não encontrou curso ativo, buscar qualquer curso
      if (courseId == null) {
        final allCoursesSnapshot = await _retryOperation(
          () => _firestore
              .collection('users')
              .doc(userId)
              .collection('courses')
              .limit(1)
              .get()
              .timeout(const Duration(seconds: 30)),
        );

        if (allCoursesSnapshot.docs.isNotEmpty) {
          courseId = allCoursesSnapshot.docs.first.id;
          
          // Marcar este curso como ativo
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('courses')
              .doc(courseId)
              .update({'isActive': true});
        } else {
          if (kDebugMode) {
            debugPrint('⚠️ Nenhum curso encontrado para o usuário');
          }
          return;
        }
      }

      final doc = await _retryOperation(
        () => _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(courseId)
            .collection('stats')
            .doc('gamification')
            .get()
            .timeout(const Duration(seconds: 30)),
      );

      if (!doc.exists) {
        await _createInitialStreak(userId, courseId);
        return;
      }

      final data = doc.data()!;
      final streakData = data['streak'] as Map<String, dynamic>? ?? {};

      currentStreak.value = streakData['currentStreak'] ?? 0;
      longestStreak.value = streakData['longestStreak'] ?? 0;
      _lastStreakDate = streakData['lastStreakDate'] ?? '';
      _streakFreezeAvailable = streakData['streakFreezeAvailable'] ?? false;
      _streakFreezeUsedToday = streakData['streakFreezeUsedToday'] ?? false;
      _milestonesReached = List<int>.from(
        streakData['milestonesReached'] ?? [],
      );
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar streak. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = _formatDateForStreak(now);

    _checkDailyFreezeReset(today);

    if (_lastStreakDate.isEmpty) {
      currentStreak.value = 1;
      longestStreak.value = 1;
      _lastStreakDate = today;
      return;
    }

    if (_lastStreakDate == today) {
      return;
    }

    final lastDateTime = DateTime.parse(_lastStreakDate);
    final daysDifference = now.difference(lastDateTime).inDays;

    if (daysDifference == 1) {
      currentStreak.value++;
      longestStreak.value = max(currentStreak.value, longestStreak.value);
      _lastStreakDate = today;
      return;
    }

    if (daysDifference == 2 && _streakFreezeAvailable) {
      _lastStreakDate = today;
      _streakFreezeAvailable = false;
      _streakFreezeUsedToday = true;
      return;
    }

    currentStreak.value = 1;
    _lastStreakDate = today;
  }

  Future<void> useStreakFreeze() async {
    if (!_streakFreezeAvailable) {
      errorMessage.value = 'Você não tem streak freeze disponível.';
      return;
    }

    if (_streakFreezeUsedToday) {
      errorMessage.value = 'Você já usou o streak freeze hoje.';
      return;
    }

    _streakFreezeAvailable = false;
    _streakFreezeUsedToday = true;

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveStreak(userId);
    }
  }

  Future<void> checkStreakMilestone() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final milestones = {7: 5, 14: 10, 30: 25, 100: 50};

    for (final entry in milestones.entries) {
      final milestone = entry.key;
      final reward = entry.value;

      if (currentStreak.value == milestone &&
          !_milestonesReached.contains(milestone)) {
        if (_gemsController != null) {
          _gemsController!.addGems(reward);
        }

        _milestonesReached.add(milestone);

        await _recordStreakMilestone(userId: userId, milestone: milestone);
      }
    }
  }

  Future<void> _createInitialStreak(String userId, String courseId) async {
    // CORREÇÃO: Verificar se documento já existe antes de criar
    // Isso evita sobrescrever dados existentes ao reiniciar o app
    final doc = await _retryOperation(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .get()
          .timeout(const Duration(seconds: 30)),
    );
    
    // Se já existe, apenas carregar (não sobrescrever)
    if (doc.exists) {
      final data = doc.data()!;
      final streakData = data['streak'] as Map<String, dynamic>? ?? {};
      
      // Se tem dados de streak, carregar
      if (streakData.isNotEmpty) {
        currentStreak.value = streakData['currentStreak'] ?? 0;
        longestStreak.value = streakData['longestStreak'] ?? 0;
        _lastStreakDate = streakData['lastStreakDate'] ?? '';
        _streakFreezeAvailable = streakData['streakFreezeAvailable'] ?? false;
        _streakFreezeUsedToday = streakData['streakFreezeUsedToday'] ?? false;
        _milestonesReached = List<int>.from(
          streakData['milestonesReached'] ?? [],
        );
        
        if (kDebugMode) {
          debugPrint('✅ Streak carregado do Firestore: ${currentStreak.value} dias');
        }
        return;
      }
    }
    
    // Se não existe ou está vazio, criar valores iniciais
    await _retryOperation(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .set({
            'streak': {
              'currentStreak': 0,
              'longestStreak': 0,
              'lastStreakDate': '',
              'streakFreezeAvailable': false,
              'streakFreezeUsedToday': false,
              'milestonesReached': [],
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 30)),
    );

    if (kDebugMode) {
      debugPrint('🆕 Streak inicial criado no Firestore');
    }
    
    await loadStreak();
  }

  Future<void> _saveStreak(String userId) async {
    final coursesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 30));

    if (coursesSnapshot.docs.isEmpty) {
      throw Exception('Nenhum curso ativo encontrado.');
    }

    final courseId = coursesSnapshot.docs.first.id;

    await _retryOperation(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .update({
            'streak': {
              'currentStreak': currentStreak.value,
              'longestStreak': longestStreak.value,
              'lastStreakDate': _lastStreakDate,
              'streakFreezeAvailable': _streakFreezeAvailable,
              'streakFreezeUsedToday': _streakFreezeUsedToday,
              'milestonesReached': _milestonesReached,
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 30)),
    );
  }

  void _checkDailyFreezeReset(String today) {
    if (_streakFreezeUsedToday && _lastStreakDate != today) {
      _streakFreezeUsedToday = false;
    }
  }

  Future<void> _recordStreakMilestone({
    required String userId,
    required int milestone,
  }) async {
    try {
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 30));

      if (coursesSnapshot.docs.isEmpty) {
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;
      final today = _formatDateForStreak(DateTime.now());

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .collection('history')
          .add({
            'type': 'streak_milestone',
            'date': today,
            'milestone': milestone,
            'timestamp': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 30));
    } catch (e) {
    }
  }

  String _formatDateForStreak(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<T> _retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) rethrow;

        await Future.delayed(Duration(seconds: pow(2, attempts - 1).toInt()));
      }
    }

    throw Exception('Operation failed after $maxAttempts attempts');
  }

  @visibleForTesting
  void updateStreakPublic() {
    updateStreak();
  }

  @visibleForTesting
  void setLastStreakDate(String date) {
    _lastStreakDate = date;
  }

  @visibleForTesting
  String getLastStreakDate() {
    return _lastStreakDate;
  }

  @visibleForTesting
  void setStreakFreezeAvailable(bool value) {
    _streakFreezeAvailable = value;
  }

  @visibleForTesting
  bool getStreakFreezeAvailable() {
    return _streakFreezeAvailable;
  }

  @visibleForTesting
  void setStreakFreezeUsedToday(bool value) {
    _streakFreezeUsedToday = value;
  }

  @visibleForTesting
  bool getStreakFreezeUsedToday() {
    return _streakFreezeUsedToday;
  }

  @visibleForTesting
  void checkStreakMilestonesPublic() {
    checkStreakMilestone();
  }

  @visibleForTesting
  void setMilestonesReached(List<int> milestones) {
    _milestonesReached = milestones;
  }

  @visibleForTesting
  List<int> getMilestonesReached() {
    return _milestonesReached;
  }

  @visibleForTesting
  String formatDateForStreakPublic(DateTime date) {
    return _formatDateForStreak(date);
  }
}
