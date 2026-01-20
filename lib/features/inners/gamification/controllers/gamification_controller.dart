import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Controller de gamificação
/// 
/// Gerencia os sistemas de:
/// - Streak (dias consecutivos)
/// - Energy (energia para lições)
/// - XP e Levels (progressão)
/// - Gems (moeda virtual)
class GamificationController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados reativos - Gamification Stats
  final currentStreak = 0.obs;
  final longestStreak = 0.obs;
  final currentEnergy = 5.obs;
  final gems = 0.obs;
  final totalXp = 0.obs;
  final weeklyXp = 0.obs;
  final todayXp = 0.obs;
  final level = 1.obs;
  final xpToNextLevel = 100.obs;
  final totalGemsEarned = 0.obs;
  final totalGemsSpent = 0.obs;

  // Estados internos (não reativos)
  String _lastStreakDate = '';
  bool _streakFreezeAvailable = false;
  bool _streakFreezeUsedToday = false;
  List<int> _milestonesReached = [];
  DateTime _lastEnergyRegenAt = DateTime.now();
  DateTime? _unlimitedEnergyUntil;
  DateTime? _xpBoosterUntil;
  DateTime? _gemMultiplierUntil;
  String _lastWeeklyResetDate = '';
  String _lastDailyResetDate = '';

  // Computed properties
  /// Verifica se energia ilimitada está ativa
  bool get hasUnlimitedEnergy =>
      _unlimitedEnergyUntil != null &&
      DateTime.now().isBefore(_unlimitedEnergyUntil!);

  /// Verifica se XP booster está ativo
  bool get hasXpBooster =>
      _xpBoosterUntil != null && DateTime.now().isBefore(_xpBoosterUntil!);

  /// Verifica se gem multiplier está ativo
  bool get hasGemMultiplier =>
      _gemMultiplierUntil != null &&
      DateTime.now().isBefore(_gemMultiplierUntil!);

  /// Verifica se streak freeze está disponível para uso
  bool get streakFreezeAvailable => _streakFreezeAvailable;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  // Métodos públicos
  /// Carrega estatísticas do Firestore
  Future<void> loadStats() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Obter userId do Firebase Auth
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final doc = await _retryOperation(() => _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('gamification')
          .get());

      if (!doc.exists) {
        // Criar documento inicial com valores padrão
        await _createInitialStats(userId);
        return;
      }

      final data = doc.data()!;

      // Carregar streak
      final streakData = data['streak'] as Map<String, dynamic>? ?? {};
      currentStreak.value = streakData['currentStreak'] ?? 0;
      longestStreak.value = streakData['longestStreak'] ?? 0;
      _lastStreakDate = streakData['lastStreakDate'] ?? '';
      _streakFreezeAvailable = streakData['streakFreezeAvailable'] ?? false;
      _streakFreezeUsedToday = streakData['streakFreezeUsedToday'] ?? false;
      _milestonesReached =
          List<int>.from(streakData['milestonesReached'] ?? []);

      // Carregar energy
      final energyData = data['energy'] as Map<String, dynamic>? ?? {};
      currentEnergy.value = energyData['currentEnergy'] ?? 5;
      _lastEnergyRegenAt =
          _timestampToDateTime(energyData['lastEnergyRegenAt']);
      _unlimitedEnergyUntil =
          _timestampToDateTime(energyData['unlimitedEnergyUntil']);

      // Carregar XP
      final xpData = data['xp'] as Map<String, dynamic>? ?? {};
      totalXp.value = xpData['totalXp'] ?? 0;
      weeklyXp.value = xpData['weeklyXp'] ?? 0;
      todayXp.value = xpData['todayXp'] ?? 0;
      level.value = xpData['level'] ?? 1;
      xpToNextLevel.value = xpData['xpToNextLevel'] ?? 100;
      _xpBoosterUntil = _timestampToDateTime(xpData['xpBoosterUntil']);
      _lastWeeklyResetDate = xpData['lastWeeklyResetDate'] ?? '';
      _lastDailyResetDate = xpData['lastDailyResetDate'] ?? '';

      // Carregar gems
      final gemsData = data['gems'] as Map<String, dynamic>? ?? {};
      gems.value = gemsData['gems'] ?? 0;
      totalGemsEarned.value = gemsData['totalGemsEarned'] ?? 0;
      totalGemsSpent.value = gemsData['totalGemsSpent'] ?? 0;
      _gemMultiplierUntil =
          _timestampToDateTime(gemsData['gemMultiplierUntil']);

      // Calcular regeneração de energia após carregar
      _calculateEnergyRegeneration();
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar estatísticas. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Salva estatísticas no Firestore
  Future<void> _saveStats(String userId) async {
    await _retryOperation(() => _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification')
        .set({
          'streak': {
            'currentStreak': currentStreak.value,
            'longestStreak': longestStreak.value,
            'lastStreakDate': _lastStreakDate,
            'streakFreezeAvailable': _streakFreezeAvailable,
            'streakFreezeUsedToday': _streakFreezeUsedToday,
            'milestonesReached': _milestonesReached,
          },
          'energy': {
            'currentEnergy': currentEnergy.value,
            'maxEnergy': 5,
            'lastEnergyRegenAt': _dateTimeToTimestamp(_lastEnergyRegenAt),
            'unlimitedEnergyUntil': _unlimitedEnergyUntil != null
                ? _dateTimeToTimestamp(_unlimitedEnergyUntil!)
                : null,
          },
          'xp': {
            'totalXp': totalXp.value,
            'weeklyXp': weeklyXp.value,
            'todayXp': todayXp.value,
            'level': level.value,
            'xpToNextLevel': xpToNextLevel.value,
            'xpBoosterUntil': _xpBoosterUntil != null
                ? _dateTimeToTimestamp(_xpBoosterUntil!)
                : null,
            'lastWeeklyResetDate': _lastWeeklyResetDate,
            'lastDailyResetDate': _lastDailyResetDate,
          },
          'gems': {
            'gems': gems.value,
            'totalGemsEarned': totalGemsEarned.value,
            'totalGemsSpent': totalGemsSpent.value,
            'gemMultiplierUntil': _gemMultiplierUntil != null
                ? _dateTimeToTimestamp(_gemMultiplierUntil!)
                : null,
          },
          'lastUpdated': FieldValue.serverTimestamp(),
        }));
  }

  /// Cria estatísticas iniciais para novo usuário
  Future<void> _createInitialStats(String userId) async {
    await _retryOperation(() => _firestore
        .collection('users')
        .doc(userId)
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
          'energy': {
            'currentEnergy': 5,
            'maxEnergy': 5,
            'lastEnergyRegenAt': FieldValue.serverTimestamp(),
            'unlimitedEnergyUntil': null,
          },
          'xp': {
            'totalXp': 0,
            'weeklyXp': 0,
            'todayXp': 0,
            'level': 1,
            'xpToNextLevel': 100,
            'xpBoosterUntil': null,
            'lastWeeklyResetDate': '',
            'lastDailyResetDate': '',
          },
          'gems': {
            'gems': 0,
            'totalGemsEarned': 0,
            'totalGemsSpent': 0,
            'gemMultiplierUntil': null,
          },
          'lastUpdated': FieldValue.serverTimestamp(),
        }));

    // Recarregar após criar
    await loadStats();
  }

  /// Verifica se pode iniciar lição (tem energia suficiente)
  bool canStartLesson() {
    // Se tem energia ilimitada, sempre pode
    if (hasUnlimitedEnergy) return true;

    // Calcular regeneração antes de verificar
    _calculateEnergyRegeneration();

    // Precisa ter pelo menos 1 energia
    return currentEnergy.value > 0;
  }

  /// Retorna tempo até próxima energia
  String getNextEnergyTime() {
    if (hasUnlimitedEnergy) return 'Ilimitada';
    if (currentEnergy.value >= 5) return 'Completa';

    final now = DateTime.now();
    final minutesSinceRegen = now.difference(_lastEnergyRegenAt).inMinutes;
    final minutesUntilNext = 30 - (minutesSinceRegen % 30);

    return '$minutesUntilNext min';
  }

  /// Compra recarga de energia (100 gems)
  Future<void> purchaseEnergyRefill() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Validar gems suficientes
      if (gems.value < 100) {
        errorMessage.value = 'Você precisa de ${100 - gems.value} gemas a mais.';
        return;
      }

      // Obter userId
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Deduzir gems e adicionar energia
      gems.value -= 100;
      totalGemsSpent.value += 100;
      
      // Adicionar 5 energia (limitado ao máximo)
      final newEnergy = currentEnergy.value + 5;
      currentEnergy.value = newEnergy > 5 ? 5 : newEnergy;

      // Salvar no Firestore
      await _saveStats(userId);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } catch (e) {
      errorMessage.value = 'Erro ao comprar recarga de energia. Tente novamente.';
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } finally {
      isLoading.value = false;
    }
  }

  /// Compra streak freeze (200 gems)
  Future<void> purchaseStreakFreeze() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Validar gems suficientes
      if (gems.value < 200) {
        errorMessage.value = 'Você precisa de ${200 - gems.value} gemas a mais.';
        return;
      }

      // Verificar se já tem freeze disponível (idempotência)
      if (_streakFreezeAvailable) {
        errorMessage.value = 'Você já tem um streak freeze ativo.';
        return;
      }

      // Obter userId
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Deduzir gems e ativar freeze
      gems.value -= 200;
      totalGemsSpent.value += 200;
      _streakFreezeAvailable = true;

      // Salvar no Firestore
      await _saveStats(userId);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } catch (e) {
      errorMessage.value = 'Erro ao comprar streak freeze. Tente novamente.';
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } finally {
      isLoading.value = false;
    }
  }

  /// Compra XP booster (150 gems, 1 hora de duração)
  Future<void> purchaseXpBooster() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Validar gems suficientes
      if (gems.value < 150) {
        errorMessage.value = 'Você precisa de ${150 - gems.value} gemas a mais.';
        return;
      }

      // Verificar se já tem booster ativo (idempotência)
      if (hasXpBooster) {
        errorMessage.value = 'Você já tem um XP booster ativo.';
        return;
      }

      // Obter userId
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Deduzir gems e ativar booster
      gems.value -= 150;
      totalGemsSpent.value += 150;
      _xpBoosterUntil = DateTime.now().add(const Duration(hours: 1));

      // Salvar no Firestore
      await _saveStats(userId);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } catch (e) {
      errorMessage.value = 'Erro ao comprar XP booster. Tente novamente.';
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } finally {
      isLoading.value = false;
    }
  }

  /// Compra gem multiplier (200 gems, 1 hora de duração)
  Future<void> purchaseGemMultiplier() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Validar gems suficientes
      if (gems.value < 200) {
        errorMessage.value = 'Você precisa de ${200 - gems.value} gemas a mais.';
        return;
      }

      // Verificar se já tem multiplier ativo (idempotência)
      if (hasGemMultiplier) {
        errorMessage.value = 'Você já tem um gem multiplier ativo.';
        return;
      }

      // Obter userId
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Deduzir gems e ativar multiplier
      gems.value -= 200;
      totalGemsSpent.value += 200;
      _gemMultiplierUntil = DateTime.now().add(const Duration(hours: 1));

      // Salvar no Firestore
      await _saveStats(userId);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } catch (e) {
      errorMessage.value = 'Erro ao comprar gem multiplier. Tente novamente.';
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos privados - History
  /// Registra conclusão de lição no histórico
  Future<void> _recordLessonHistory({
    required String userId,
    required int xpEarned,
    required int gemsEarned,
  }) async {
    try {
      final today = _formatDateForStreak(DateTime.now());
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('gamification')
          .collection('history')
          .add({
        'type': 'lesson_completion',
        'date': today,
        'xpEarned': xpEarned,
        'gemsEarned': gemsEarned,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Não propagar erro - histórico é opcional
      debugPrint('Erro ao registrar histórico de lição: $e');
    }
  }

  /// Registra milestone de streak no histórico
  Future<void> _recordStreakMilestone({
    required String userId,
    required int milestone,
  }) async {
    try {
      final today = _formatDateForStreak(DateTime.now());
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('gamification')
          .collection('history')
          .add({
        'type': 'streak_milestone',
        'date': today,
        'milestone': milestone,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Não propagar erro - histórico é opcional
      debugPrint('Erro ao registrar milestone de streak: $e');
    }
  }

  /// Registra level up no histórico
  Future<void> _recordLevelUp({
    required String userId,
    required int newLevel,
  }) async {
    try {
      final today = _formatDateForStreak(DateTime.now());
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('gamification')
          .collection('history')
          .add({
        'type': 'level_up',
        'date': today,
        'newLevel': newLevel,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Não propagar erro - histórico é opcional
      debugPrint('Erro ao registrar level up: $e');
    }
  }

  /// Consulta histórico com filtro de data
  /// 
  /// Retorna eventos do histórico dentro do intervalo de datas especificado.
  /// Por padrão, limita aos últimos 365 dias.
  Future<List<Map<String, dynamic>>> queryHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Obter userId
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      // Calcular data de início (365 dias atrás se não especificado)
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 365));
      final end = endDate ?? DateTime.now();

      // Formatar datas para comparação
      final startDateStr = _formatDateForStreak(start);
      final endDateStr = _formatDateForStreak(end);

      // Consultar histórico com filtro de data
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('gamification')
          .collection('history')
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .orderBy('date', descending: true)
          .get();

      // Converter para lista de mapas
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Consulta histórico de lições completadas
  Future<List<Map<String, dynamic>>> queryLessonHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final history = await queryHistory(startDate: startDate, endDate: endDate);
    return history.where((event) => event['type'] == 'lesson_completion').toList();
  }

  /// Consulta histórico de milestones de streak
  Future<List<Map<String, dynamic>>> queryStreakMilestones({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final history = await queryHistory(startDate: startDate, endDate: endDate);
    return history.where((event) => event['type'] == 'streak_milestone').toList();
  }

  /// Consulta histórico de level ups
  Future<List<Map<String, dynamic>>> queryLevelUps({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final history = await queryHistory(startDate: startDate, endDate: endDate);
    return history.where((event) => event['type'] == 'level_up').toList();
  }

  // Métodos públicos - Lesson Flow
  /// Chamado quando o usuário inicia uma lição
  /// 
  /// Verifica se tem energia suficiente, calcula regeneração,
  /// consome 1 energia e salva no Firestore
  Future<void> onLessonStart() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Verificar se pode iniciar lição
      if (!canStartLesson()) {
        errorMessage.value = 'Energia insuficiente para iniciar a lição.';
        return;
      }

      // Obter userId
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Calcular regeneração de energia
      _calculateEnergyRegeneration();

      // Consumir 1 energia
      _consumeEnergy();

      // Salvar no Firestore
      await _saveStats(userId);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } catch (e) {
      errorMessage.value = 'Erro ao iniciar lição. Tente novamente.';
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } finally {
      isLoading.value = false;
    }
  }

  /// Chamado quando o usuário completa uma lição
  /// 
  /// Calcula recompensas totais (base + bônus), adiciona XP e gems,
  /// atualiza streak se primeira lição do dia, verifica milestones e level up,
  /// e salva tudo no Firestore em uma transação
  Future<void> onLessonComplete(int baseXp, int baseGems, bool isPerfect, {String lessonId = ''}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Obter userId
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // 1. Calcular recompensas totais (base + bônus)
      var totalXpReward = baseXp;
      var totalGemsReward = baseGems;

      // Bônus de lição perfeita (+5 XP)
      if (isPerfect) {
        totalXpReward += 5;
      }

      // Bônus de primeira lição do dia (+5 XP)
      final isFirstLesson = _isFirstLessonOfDay();
      if (isFirstLesson) {
        totalXpReward += 5;
      }

      // 2. Adicionar XP (com booster se ativo)
      _addXp(totalXpReward);

      // 3. Adicionar gems (com multiplier se ativo)
      _addGems(totalGemsReward);

      // 4. Atualizar streak se primeira lição do dia
      if (isFirstLesson) {
        _updateStreak();
        await _checkStreakMilestonesWithHistory(userId);
      }

      // 5. Verificar level up
      await _checkLevelUpWithHistory(userId);

      // 6. Integração com módulo de Challenges (se disponível)
      // TODO: [future] Integração com ChallengesController
      // if (Get.isRegistered<ChallengesController>()) {
      //   final challenges = Get.find<ChallengesController>();
      //   await challenges.updateProgress('lesson_completed');
      // }

      // 7. Salvar no Firestore
      await _saveStats(userId);

      // 8. Registrar no histórico
      await _recordLessonHistory(
        userId: userId,
        xpEarned: totalXpReward,
        gemsEarned: totalGemsReward,
      );
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } catch (e) {
      errorMessage.value = 'Erro ao completar lição. Tente novamente.';
      
      // Reverter mudanças em caso de erro
      await loadStats();
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos privados - Energy
  /// Calcula regeneração de energia baseado no tempo passado
  void _calculateEnergyRegeneration() {
    // Skip se energia ilimitada está ativa
    if (hasUnlimitedEnergy) return;

    // Skip se já está no máximo
    if (currentEnergy.value >= 5) return;

    final now = DateTime.now();
    final minutesPassed = now.difference(_lastEnergyRegenAt).inMinutes;

    // Calcular energia a adicionar: 1 energia a cada 30 minutos
    final energiesToAdd = minutesPassed ~/ 30;

    if (energiesToAdd == 0) return;

    // Calcular nova energia (limitado ao máximo)
    final newEnergy = min(currentEnergy.value + energiesToAdd, 5);

    // Atualizar timestamp pelo tempo de energia realmente regenerada
    final minutesConsumed = (newEnergy - currentEnergy.value) * 30;
    _lastEnergyRegenAt =
        _lastEnergyRegenAt.add(Duration(minutes: minutesConsumed));

    currentEnergy.value = newEnergy;
  }

  /// Consome 1 energia
  void _consumeEnergy() {
    if (hasUnlimitedEnergy) return;

    if (currentEnergy.value > 0) {
      currentEnergy.value--;
      _lastEnergyRegenAt = DateTime.now();
    }
  }

  // Métodos privados - XP e Levels
  /// Adiciona XP e atualiza totalXp, weeklyXp e todayXp atomicamente
  void _addXp(int baseXp) {
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
    weeklyXp.value += xpToAdd;
    todayXp.value += xpToAdd;
  }

  /// Verifica e aplica resets de XP (semanal e diário)
  void _checkXpResets() {
    final now = DateTime.now();
    final today = _formatDateForStreak(now);

    // Reset semanal (segunda-feira 00:00)
    if (_isMonday(now) && _lastWeeklyResetDate != today) {
      weeklyXp.value = 0;
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
  void _checkLevelUp() {
    // Processar todos os level ups que resultam do XP atual
    while (totalXp.value >= xpToNextLevel.value) {
      level.value++;
      xpToNextLevel.value = level.value * 100;

      // Premiar 10 gems por level up
      _addGems(10);
    }
  }

  /// Verifica level up e registra no histórico
  Future<void> _checkLevelUpWithHistory(String userId) async {
    // Processar todos os level ups que resultam do XP atual
    while (totalXp.value >= xpToNextLevel.value) {
      level.value++;
      xpToNextLevel.value = level.value * 100;

      // Premiar 10 gems por level up
      _addGems(10);

      // Registrar no histórico
      await _recordLevelUp(userId: userId, newLevel: level.value);
    }
  }

  /// Adiciona gems e atualiza gems e totalGemsEarned atomicamente
  void _addGems(int amount) {
    // Validar gems não negativas
    if (amount < 0) {
      throw Exception('Cannot add negative gems');
    }

    // Aplicar multiplicador se ativo (2×)
    final gemsToAdd = hasGemMultiplier ? amount * 2 : amount;

    // Atualizar gems e totalGemsEarned atomicamente
    gems.value += gemsToAdd;
    totalGemsEarned.value += gemsToAdd;
  }

  /// Verifica se é a primeira lição do dia
  bool _isFirstLessonOfDay() {
    final now = DateTime.now();
    final today = _formatDateForStreak(now);

    // Se não há lastStreakDate ou é diferente de hoje, é primeira lição
    return _lastStreakDate.isEmpty || _lastStreakDate != today;
  }

  // Métodos privados - Streak
  /// Atualiza streak baseado na última lição
  void _updateStreak() {
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

  /// Verifica e reseta streakFreezeUsedToday se é um novo dia
  void _checkDailyFreezeReset(String today) {
    // Se streakFreezeUsedToday está true e não é mais o mesmo dia, resetar
    if (_streakFreezeUsedToday && _lastStreakDate != today) {
      _streakFreezeUsedToday = false;
    }
  }

  /// Verifica e premia milestones de streak
  void _checkStreakMilestones() {
    // Milestones: 7, 14, 30, 100 dias
    // Recompensas: 5, 10, 25, 50 gems
    final milestones = {
      7: 5,
      14: 10,
      30: 25,
      100: 50,
    };

    for (final entry in milestones.entries) {
      final milestone = entry.key;
      final reward = entry.value;

      // Se atingiu o milestone e ainda não foi premiado
      if (currentStreak.value == milestone &&
          !_milestonesReached.contains(milestone)) {
        // Adicionar gems
        gems.value += reward;
        totalGemsEarned.value += reward;

        // Marcar milestone como alcançado
        _milestonesReached.add(milestone);
      }
    }
  }

  /// Verifica e premia milestones de streak com registro no histórico
  Future<void> _checkStreakMilestonesWithHistory(String userId) async {
    // Milestones: 7, 14, 30, 100 dias
    // Recompensas: 5, 10, 25, 50 gems
    final milestones = {
      7: 5,
      14: 10,
      30: 25,
      100: 50,
    };

    for (final entry in milestones.entries) {
      final milestone = entry.key;
      final reward = entry.value;

      // Se atingiu o milestone e ainda não foi premiado
      if (currentStreak.value == milestone &&
          !_milestonesReached.contains(milestone)) {
        // Adicionar gems
        gems.value += reward;
        totalGemsEarned.value += reward;

        // Marcar milestone como alcançado
        _milestonesReached.add(milestone);

        // Registrar no histórico
        await _recordStreakMilestone(userId: userId, milestone: milestone);
      }
    }
  }

  // Métodos privados - Helpers
  /// Converte Timestamp do Firestore para DateTime
  DateTime _timestampToDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  /// Converte DateTime para Timestamp do Firestore
  Timestamp _dateTimeToTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
  }

  /// Formata data para streak (YYYY-MM-DD)
  String _formatDateForStreak(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Verifica se duas datas são do mesmo dia
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Métodos privados - Error Handling
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

        // Exponential backoff: 1s, 2s, 4s
        await Future.delayed(Duration(seconds: pow(2, attempts - 1).toInt()));
      }
    }

    throw Exception('Operation failed after $maxAttempts attempts');
  }

  // Test Helpers (apenas para testes)
  /// Expõe _calculateEnergyRegeneration para testes
  void calculateEnergyRegenerationPublic() {
    _calculateEnergyRegeneration();
  }

  /// Expõe _consumeEnergy para testes
  void consumeEnergyPublic() {
    _consumeEnergy();
  }

  /// Define lastEnergyRegenAt para testes
  void setLastEnergyRegenAt(DateTime date) {
    _lastEnergyRegenAt = date;
  }

  /// Define unlimitedEnergyUntil para testes
  void setUnlimitedEnergyUntil(DateTime? date) {
    _unlimitedEnergyUntil = date;
  }

  /// Obtém lastEnergyRegenAt para testes
  DateTime getLastEnergyRegenAt() {
    return _lastEnergyRegenAt;
  }

  /// Expõe _updateStreak para testes
  void updateStreakPublic() {
    _updateStreak();
  }

  /// Define lastStreakDate para testes
  void setLastStreakDate(String date) {
    _lastStreakDate = date;
  }

  /// Obtém lastStreakDate para testes
  String getLastStreakDate() {
    return _lastStreakDate;
  }

  /// Define streakFreezeAvailable para testes
  void setStreakFreezeAvailable(bool value) {
    _streakFreezeAvailable = value;
  }

  /// Obtém streakFreezeAvailable para testes
  bool getStreakFreezeAvailable() {
    return _streakFreezeAvailable;
  }

  /// Define streakFreezeUsedToday para testes
  void setStreakFreezeUsedToday(bool value) {
    _streakFreezeUsedToday = value;
  }

  /// Obtém streakFreezeUsedToday para testes
  bool getStreakFreezeUsedToday() {
    return _streakFreezeUsedToday;
  }

  /// Expõe _checkStreakMilestones para testes
  void checkStreakMilestonesPublic() {
    _checkStreakMilestones();
  }

  /// Define milestonesReached para testes
  void setMilestonesReached(List<int> milestones) {
    _milestonesReached = milestones;
  }

  /// Obtém milestonesReached para testes
  List<int> getMilestonesReached() {
    return _milestonesReached;
  }

  /// Expõe _addXp para testes
  void addXpPublic(int baseXp) {
    _addXp(baseXp);
  }

  /// Expõe _checkXpResets para testes
  void checkXpResetsPublic() {
    _checkXpResets();
  }

  /// Expõe _checkLevelUp para testes
  void checkLevelUpPublic() {
    _checkLevelUp();
  }

  /// Expõe _isFirstLessonOfDay para testes
  bool isFirstLessonOfDayPublic() {
    return _isFirstLessonOfDay();
  }

  /// Define xpBoosterUntil para testes
  void setXpBoosterUntil(DateTime? date) {
    _xpBoosterUntil = date;
  }

  /// Obtém xpBoosterUntil para testes
  DateTime? getXpBoosterUntil() {
    return _xpBoosterUntil;
  }

  /// Define lastWeeklyResetDate para testes
  void setLastWeeklyResetDate(String date) {
    _lastWeeklyResetDate = date;
  }

  /// Obtém lastWeeklyResetDate para testes
  String getLastWeeklyResetDate() {
    return _lastWeeklyResetDate;
  }

  /// Define lastDailyResetDate para testes
  void setLastDailyResetDate(String date) {
    _lastDailyResetDate = date;
  }

  /// Obtém lastDailyResetDate para testes
  String getLastDailyResetDate() {
    return _lastDailyResetDate;
  }

  /// Define gemMultiplierUntil para testes
  void setGemMultiplierUntil(DateTime? date) {
    _gemMultiplierUntil = date;
  }

  /// Obtém gemMultiplierUntil para testes
  DateTime? getGemMultiplierUntil() {
    return _gemMultiplierUntil;
  }

  /// Expõe _formatDateForStreak para testes
  String formatDateForStreakPublic(DateTime date) {
    return _formatDateForStreak(date);
  }
}
