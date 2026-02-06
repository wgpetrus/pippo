import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'gems_controller.dart';

/// Controller de streak (dias consecutivos)
///
/// Gerencia:
/// - Streak atual e mais longo
/// - Streak freeze (proteção)
/// - Milestones de streak
class StreakController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados reativos - Streak
  final currentStreak = 0.obs;
  final longestStreak = 0.obs;

  // Estados internos (não reativos)
  String _lastStreakDate = '';
  bool _streakFreezeAvailable = false;
  bool _streakFreezeUsedToday = false;
  List<int> _milestonesReached = [];

  // Dependency
  late final GemsController _gemsController;

  // Computed properties
  /// Verifica se streak freeze está disponível para uso
  bool get streakFreezeAvailable => _streakFreezeAvailable;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    try {
      _gemsController = Get.find<GemsController>();
    } catch (e) {
      debugPrint('GemsController não encontrado: $e');
    }
  }

  // Métodos públicos
  /// Carrega streak do Firestore (do curso ativo)
  Future<void> loadStreak() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // 1. Buscar curso ativo
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

      if (coursesSnapshot.docs.isEmpty) {
        errorMessage.value = 'Nenhum curso ativo encontrado.';
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;

      // 2. Buscar stats do curso ativo
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
        // Criar documento inicial
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
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar streak. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza streak baseado na última lição
  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = _formatDateForStreak(now);

    // Resetar streakFreezeUsedToday se é um novo dia
    _checkDailyFreezeReset(today);

    // Primeiro caso: primeira lição ever
    if (_lastStreakDate.isEmpty) {
      currentStreak.value = 1;
      longestStreak.value = 1;
      _lastStreakDate = today;
      return;
    }

    // Segundo caso: já completou hoje
    if (_lastStreakDate == today) {
      return;
    }

    // Calcular diferença de dias
    final lastDateTime = DateTime.parse(_lastStreakDate);
    final daysDifference = now.difference(lastDateTime).inDays;

    // Terceiro caso: dia consecutivo
    if (daysDifference == 1) {
      currentStreak.value++;
      longestStreak.value = max(currentStreak.value, longestStreak.value);
      _lastStreakDate = today;
      return;
    }

    // Quarto caso: perdeu um dia mas tem freeze
    if (daysDifference == 2 && _streakFreezeAvailable) {
      _lastStreakDate = today;
      _streakFreezeAvailable = false;
      _streakFreezeUsedToday = true;
      return;
    }

    // Quinto caso: streak quebrado - reset
    currentStreak.value = 1;
    _lastStreakDate = today;
  }

  /// Usa streak freeze para proteger streak
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

    // Salvar no Firestore
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveStreak(userId);
    }
  }

  /// Verifica e premia milestones de streak
  Future<void> checkStreakMilestone() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Milestones: 7, 14, 30, 100 dias
    // Recompensas: 5, 10, 25, 50 gems
    final milestones = {7: 5, 14: 10, 30: 25, 100: 50};

    for (final entry in milestones.entries) {
      final milestone = entry.key;
      final reward = entry.value;

      // Se atingiu o milestone e ainda não foi premiado
      if (currentStreak.value == milestone &&
          !_milestonesReached.contains(milestone)) {
        // Adicionar gems via GemsController
        try {
          _gemsController.addGems(reward);
        } catch (e) {
          debugPrint('Erro ao adicionar gems de milestone: $e');
        }

        // Marcar milestone como alcançado
        _milestonesReached.add(milestone);

        // Registrar no histórico
        await _recordStreakMilestone(userId: userId, milestone: milestone);
      }
    }
  }

  // Métodos privados
  /// Cria streak inicial para novo curso
  Future<void> _createInitialStreak(String userId, String courseId) async {
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

    await loadStreak();
  }

  /// Salva streak no Firestore (no curso ativo)
  Future<void> _saveStreak(String userId) async {
    // 1. Buscar curso ativo
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

    // 2. Salvar streak no curso ativo
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

  /// Verifica e reseta streakFreezeUsedToday se é um novo dia
  void _checkDailyFreezeReset(String today) {
    if (_streakFreezeUsedToday && _lastStreakDate != today) {
      _streakFreezeUsedToday = false;
    }
  }

  /// Registra milestone de streak no histórico (do curso ativo)
  Future<void> _recordStreakMilestone({
    required String userId,
    required int milestone,
  }) async {
    try {
      // 1. Buscar curso ativo
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 30));

      if (coursesSnapshot.docs.isEmpty) {
        debugPrint('⚠️ Nenhum curso ativo para registrar milestone');
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;
      final today = _formatDateForStreak(DateTime.now());

      // 2. Salvar milestone no curso ativo
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
      debugPrint('Erro ao registrar milestone de streak: $e');
    }
  }

  /// Formata data para streak (YYYY-MM-DD)
  String _formatDateForStreak(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Handler de erros do Firestore
  String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
      case 'unavailable':
        return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
      case 'deadline-exceeded':
        return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
      case 'resource-exhausted':
        return 'Muitas requisições. Aguarde alguns minutos e tente novamente.';
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'not-found':
        return 'Dados não encontrados.';
      case 'already-exists':
        return 'Recurso já existe.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }

  /// Retry logic com exponential backoff
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

  // Test Helpers
  void updateStreakPublic() {
    updateStreak();
  }

  void setLastStreakDate(String date) {
    _lastStreakDate = date;
  }

  String getLastStreakDate() {
    return _lastStreakDate;
  }

  void setStreakFreezeAvailable(bool value) {
    _streakFreezeAvailable = value;
  }

  bool getStreakFreezeAvailable() {
    return _streakFreezeAvailable;
  }

  void setStreakFreezeUsedToday(bool value) {
    _streakFreezeUsedToday = value;
  }

  bool getStreakFreezeUsedToday() {
    return _streakFreezeUsedToday;
  }

  void checkStreakMilestonesPublic() {
    checkStreakMilestone();
  }

  void setMilestonesReached(List<int> milestones) {
    _milestonesReached = milestones;
  }

  List<int> getMilestonesReached() {
    return _milestonesReached;
  }

  String formatDateForStreakPublic(DateTime date) {
    return _formatDateForStreak(date);
  }
}
