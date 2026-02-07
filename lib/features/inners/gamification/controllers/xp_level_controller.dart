import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';
import 'gems_controller.dart';

class XpLevelController extends GetxController {
  // Dependency Injection com valores padrão (backward compatible)
  XpLevelController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final totalXp = 0.obs;
  final weeklyXP = 0.obs;
  final todayXp = 0.obs;
  final level = 1.obs;
  final xpToNextLevel = 100.obs;

  DateTime? _xpBoosterUntil;
  String _lastWeeklyResetDate = '';
  String _lastDailyResetDate = '';

  GemsController? _gemsController;

  bool get hasXpBooster =>
      _xpBoosterUntil != null && DateTime.now().isBefore(_xpBoosterUntil!);

  DateTime? get xpBoosterUntil => _xpBoosterUntil;

  String getXpBoosterTimeRemaining() {
    if (_xpBoosterUntil == null) return '';

    final now = DateTime.now();
    if (now.isAfter(_xpBoosterUntil!)) return '';

    final diff = _xpBoosterUntil!.difference(now);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}min restantes';
    } else {
      return '${diff.inHours}h restantes';
    }
  }

  @override
  void onInit() {
    super.onInit();
    try {
      _gemsController = Get.find<GemsController>();
    } catch (e) {
      _gemsController = null;
    }
    
    // Carregar dados ao inicializar
    loadXpAndLevel();
  }

  Future<void> loadXpAndLevel() async {
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
        await _createInitialXp(userId, courseId);
        return;
      }

      final data = doc.data()!;
      final xpData = data['xp'] as Map<String, dynamic>? ?? {};

      totalXp.value = xpData['totalXp'] ?? 0;
      weeklyXP.value = xpData['weeklyXP'] ?? 0;
      todayXp.value = xpData['todayXp'] ?? 0;
      level.value = xpData['level'] ?? 1;
      xpToNextLevel.value = xpData['xpToNextLevel'] ?? 100;
      _xpBoosterUntil = _timestampToDateTime(xpData['xpBoosterUntil']);
      _lastWeeklyResetDate = xpData['lastWeeklyResetDate'] ?? '';
      _lastDailyResetDate = xpData['lastDailyResetDate'] ?? '';
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar XP. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    if (amount < 0) {
      throw Exception('Cannot add negative XP');
    }

    _checkXpResets();

    final multiplier = hasXpBooster ? 2 : 1;
    final xpGained = amount * multiplier;

    totalXp.value += xpGained;
    weeklyXP.value += xpGained;
    todayXp.value += xpGained;

    await _saveXpToHistory(xpGained);

    await _checkLevelUp();

    final userId = _auth.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      await _saveXp(userId);
    }
  }

  Future<void> activateXpBooster(int minutes) async {
    _xpBoosterUntil = DateTime.now().add(Duration(minutes: minutes));

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveXp(userId);
    }
  }

  Future<void> resetWeeklyXp() async {
    weeklyXP.value = 0;
    _lastWeeklyResetDate = _formatDateForStreak(DateTime.now());

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveXp(userId);
    }
  }

  Future<void> resetDailyXp() async {
    todayXp.value = 0;
    _lastDailyResetDate = _formatDateForStreak(DateTime.now());

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveXp(userId);
    }
  }

  Future<void> _createInitialXp(String userId, String courseId) async {
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
      final xpData = data['xp'] as Map<String, dynamic>? ?? {};
      
      // Se tem dados de XP, carregar
      if (xpData.isNotEmpty) {
        totalXp.value = xpData['totalXp'] ?? 0;
        weeklyXP.value = xpData['weeklyXP'] ?? 0;
        todayXp.value = xpData['todayXp'] ?? 0;
        level.value = xpData['level'] ?? 1;
        xpToNextLevel.value = xpData['xpToNextLevel'] ?? 100;
        _xpBoosterUntil = _timestampToDateTime(xpData['xpBoosterUntil']);
        _lastWeeklyResetDate = xpData['lastWeeklyResetDate'] ?? '';
        _lastDailyResetDate = xpData['lastDailyResetDate'] ?? '';
        
        if (kDebugMode) {
          debugPrint('✅ XP carregado do Firestore: ${totalXp.value} XP, Level ${level.value}');
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
            'xp': {
              'totalXp': 0,
              'weeklyXP': 0,
              'todayXp': 0,
              'level': 1,
              'xpToNextLevel': 100,
              'xpBoosterUntil': null,
              'lastWeeklyResetDate': '',
              'lastDailyResetDate': '',
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 30)),
    );

    if (kDebugMode) {
      debugPrint('🆕 XP inicial criado no Firestore');
    }
    
    await loadXpAndLevel();
  }

  Future<void> _saveXp(String userId) async {
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
            'xp': {
              'totalXp': totalXp.value,
              'weeklyXP': weeklyXP.value,
              'todayXp': todayXp.value,
              'level': level.value,
              'xpToNextLevel': xpToNextLevel.value,
              'xpBoosterUntil': _xpBoosterUntil != null
                  ? _dateTimeToTimestamp(_xpBoosterUntil!)
                  : null,
              'lastWeeklyResetDate': _lastWeeklyResetDate,
              'lastDailyResetDate': _lastDailyResetDate,
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 30)),
    );
  }

  Future<void> _saveXpToHistory(int xpGained) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      return;
    }

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
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('stats')
        .doc('dailyHistory')
        .set({
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    final dayRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('stats')
        .doc('dailyHistory')
        .collection('days')
        .doc(dateStr);

    final dayDoc = await dayRef.get();

    if (dayDoc.exists) {
      await dayRef.update({
        'xp': FieldValue.increment(xpGained),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await dayRef.set({
        'xp': xpGained,
        'date': dateStr,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _checkXpResets() {
    final now = DateTime.now();
    final today = _formatDateForStreak(now);

    if (_isMonday(now) && _lastWeeklyResetDate != today) {
      weeklyXP.value = 0;
      _lastWeeklyResetDate = today;
    }

    if (_lastDailyResetDate != today) {
      todayXp.value = 0;
      _lastDailyResetDate = today;
    }
  }

  bool _isMonday(DateTime date) {
    return date.weekday == DateTime.monday;
  }

  Future<void> _checkLevelUp() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    while (totalXp.value >= _calculateXpToNextLevel(level.value)) {
      level.value++;
      xpToNextLevel.value = _calculateXpToNextLevel(level.value);

      if (_gemsController != null) {
        _gemsController!.addGems(10);
      }

      await _recordLevelUp(userId: userId, newLevel: level.value);
    }
  }

  int _calculateXpToNextLevel(int currentLevel) {
    return currentLevel * 100;
  }

  Future<void> _recordLevelUp({
    required String userId,
    required int newLevel,
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
            'type': 'level_up',
            'date': today,
            'newLevel': newLevel,
            'timestamp': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 30));
    } catch (e) {
    }
  }

  String _formatDateForStreak(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Timestamp _dateTimeToTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
  }

  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
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
  void addXpPublic(int baseXp) {
    addXp(baseXp);
  }

  @visibleForTesting
  void checkXpResetsPublic() {
    _checkXpResets();
  }

  @visibleForTesting
  void checkLevelUpPublic() {
    _checkLevelUp();
  }

  @visibleForTesting
  void setXpBoosterUntil(DateTime? date) {
    _xpBoosterUntil = date;
  }

  @visibleForTesting
  DateTime? getXpBoosterUntil() {
    return _xpBoosterUntil;
  }

  @visibleForTesting
  void setLastWeeklyResetDate(String date) {
    _lastWeeklyResetDate = date;
  }

  @visibleForTesting
  String getLastWeeklyResetDate() {
    return _lastWeeklyResetDate;
  }

  @visibleForTesting
  void setLastDailyResetDate(String date) {
    _lastDailyResetDate = date;
  }

  @visibleForTesting
  String getLastDailyResetDate() {
    return _lastDailyResetDate;
  }
}
