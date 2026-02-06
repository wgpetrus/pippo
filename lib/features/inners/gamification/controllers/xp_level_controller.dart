import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'gems_controller.dart';

/// Controller de XP e níveis
///
/// Gerencia:
/// - XP total, semanal e diário
/// - Níveis e progressão
/// - XP booster temporário
class XpLevelController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados reativos - XP e Levels
  final totalXp = 0.obs;
  final weeklyXP = 0.obs;
  final todayXp = 0.obs;
  final level = 1.obs;
  final xpToNextLevel = 100.obs;

  // Estados internos (não reativos)
  DateTime? _xpBoosterUntil;
  String _lastWeeklyResetDate = '';
  String _lastDailyResetDate = '';

  // Dependency
  late final GemsController _gemsController;

  // Computed properties
  /// Verifica se XP booster está ativo
  bool get hasXpBooster =>
      _xpBoosterUntil != null && DateTime.now().isBefore(_xpBoosterUntil!);

  /// Retorna o tempo de expiração do XP booster (null se não ativo)
  DateTime? get xpBoosterUntil => _xpBoosterUntil;

  /// Retorna tempo restante do XP booster formatado
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
  /// Carrega XP e level do Firestore (do curso ativo)
  Future<void> loadXpAndLevel() async {
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

  /// Adiciona XP e atualiza totalXp, weeklyXP e todayXp atomicamente
  Future<void> addXp(int baseXp) async {
    // Validar XP não negativo
    if (baseXp < 0) {
      throw Exception('Cannot add negative XP');
    }

    // Verificar e aplicar resets antes de adicionar
    _checkXpResets();

    // Aplicar booster se ativo (2×)
    final xpToAdd = hasXpBooster ? baseXp * 2 : baseXp;

    // Atualizar todos os três contadores atomicamente
    totalXp.value += xpToAdd;
    weeklyXP.value += xpToAdd;
    todayXp.value += xpToAdd;

    // Salvar XP no histórico diário para o gráfico de progresso
    await _saveXpToHistory(xpToAdd);

    // Verificar level up
    await _checkLevelUp();

    // Salvar no Firestore
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveXp(userId);
    }
  }

  /// Ativa XP booster por X minutos
  Future<void> activateXpBooster(int minutes) async {
    _xpBoosterUntil = DateTime.now().add(Duration(minutes: minutes));

    // Salvar no Firestore
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveXp(userId);
    }
  }

  /// Reseta XP semanal (chamado toda segunda-feira)
  Future<void> resetWeeklyXp() async {
    weeklyXP.value = 0;
    _lastWeeklyResetDate = _formatDateForStreak(DateTime.now());

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveXp(userId);
    }
  }

  /// Reseta XP diário (chamado toda meia-noite)
  Future<void> resetDailyXp() async {
    todayXp.value = 0;
    _lastDailyResetDate = _formatDateForStreak(DateTime.now());

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveXp(userId);
    }
  }

  // Métodos privados
  /// Cria XP inicial para novo curso
  Future<void> _createInitialXp(String userId, String courseId) async {
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

    await loadXpAndLevel();
  }

  /// Salva XP no Firestore (no curso ativo)
  Future<void> _saveXp(String userId) async {
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

    // 2. Salvar XP no curso ativo
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

  /// Salva XP ganho no histórico diário para o gráfico de progresso semanal
  Future<void> _saveXpToHistory(int xpGained) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        debugPrint('⚠️ _saveXpToHistory: userId é null ou vazio');
        return;
      }

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
        debugPrint('⚠️ _saveXpToHistory: Nenhum curso ativo encontrado');
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // 2. Garantir que o documento dailyHistory existe
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

      // 3. Salvar no documento do dia (subcoleção)
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
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao salvar XP no histórico: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Verifica e aplica resets de XP (semanal e diário)
  void _checkXpResets() {
    final now = DateTime.now();
    final today = _formatDateForStreak(now);

    // Reset semanal (segunda-feira 00:00)
    if (_isMonday(now) && _lastWeeklyResetDate != today) {
      weeklyXP.value = 0;
      _lastWeeklyResetDate = today;
    }

    // Reset diário (meia-noite)
    if (_lastDailyResetDate != today) {
      todayXp.value = 0;
      _lastDailyResetDate = today;
    }
  }

  /// Verifica se é segunda-feira
  bool _isMonday(DateTime date) {
    return date.weekday == DateTime.monday;
  }

  /// Verifica level up e processa múltiplos níveis sequencialmente
  Future<void> _checkLevelUp() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Processar todos os level ups que resultam do XP atual
    while (totalXp.value >= xpToNextLevel.value) {
      level.value++;
      xpToNextLevel.value = _calculateXpToNextLevel(level.value);

      // Premiar 10 gems por level up via GemsController
      try {
        _gemsController.addGems(10);
      } catch (e) {
        debugPrint('Erro ao adicionar gems de level up: $e');
      }

      // Registrar no histórico
      await _recordLevelUp(userId: userId, newLevel: level.value);
    }
  }

  /// Calcula XP necessário para próximo nível
  int _calculateXpToNextLevel(int currentLevel) {
    return currentLevel * 100;
  }

  /// Registra level up no histórico (do curso ativo)
  Future<void> _recordLevelUp({
    required String userId,
    required int newLevel,
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
        debugPrint('⚠️ Nenhum curso ativo para registrar level up');
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;
      final today = _formatDateForStreak(DateTime.now());

      // 2. Salvar level up no curso ativo
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
      debugPrint('Erro ao registrar level up: $e');
    }
  }

  /// Formata data para streak (YYYY-MM-DD)
  String _formatDateForStreak(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Converte Timestamp do Firestore para DateTime
  DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  /// Converte DateTime para Timestamp do Firestore
  Timestamp _dateTimeToTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
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
  void addXpPublic(int baseXp) {
    addXp(baseXp);
  }

  void checkXpResetsPublic() {
    _checkXpResets();
  }

  void checkLevelUpPublic() {
    _checkLevelUp();
  }

  void setXpBoosterUntil(DateTime? date) {
    _xpBoosterUntil = date;
  }

  DateTime? getXpBoosterUntil() {
    return _xpBoosterUntil;
  }

  void setLastWeeklyResetDate(String date) {
    _lastWeeklyResetDate = date;
  }

  String getLastWeeklyResetDate() {
    return _lastWeeklyResetDate;
  }

  void setLastDailyResetDate(String date) {
    _lastDailyResetDate = date;
  }

  String getLastDailyResetDate() {
    return _lastDailyResetDate;
  }
}
