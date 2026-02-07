import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../inners/gamification/controllers/xp_level_controller.dart';
import '../../../inners/gamification/controllers/gems_controller.dart';
import '../../../inners/home/controllers/home_stats_controller.dart';
import '../../../inners/treasure/controllers/treasure_challenges_controller.dart';
import 'lesson_flow_controller.dart';
import 'lesson_progress_controller.dart';

/// Controller para gerenciar recompensas (XP, gems, achievements)
class LessonRewardsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  late final XpLevelController _xpLevelController;
  late final GemsController _gemsController;
  late final LessonProgressController _progressController;
  late final LessonFlowController _flowController;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final calculatedXp = 0.obs;
  final calculatedGems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _xpLevelController = Get.find<XpLevelController>();
      _gemsController = Get.find<GemsController>();
      _progressController = Get.find<LessonProgressController>();
      _flowController = Get.find<LessonFlowController>();
    } catch (e) {
      errorMessage.value = 'Erro ao inicializar dependências.';
    }
  }

  Future<void> calculateRewards() async {
    final totalXp = await _calculateTotalXP();
    final totalGems = _calculateTotalGems();
    
    calculatedXp.value = totalXp;
    calculatedGems.value = totalGems;
  }

  Future<void> applyRewards() async {
    isLoading.value = true;
    errorMessage.value = '';

    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        final totalXp = await _calculateTotalXP();
        final totalGems = _calculateTotalGems();
        
        calculatedXp.value = totalXp;
        calculatedGems.value = totalGems;
        
        await _xpLevelController.addXp(totalXp);
        
        _gemsController.addGems(totalGems);
        
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          await _gemsController.loadGems(); // Reload to ensure sync
        }

        final isFirstToday = await _isFirstLessonToday();
        if (isFirstToday) {
          await _updateStreak();
        }
        
        final courseId = _flowController.currentLesson.value?['courseId'] as String? ?? '';
        final lessonId = _flowController.currentLesson.value?['id'] as String? ?? '';
        
        if (courseId.isEmpty || lessonId.isEmpty) {
          throw Exception('CourseId ou LessonId não pode ser vazio');
        }
        
        await _updateLessonProgress(courseId, lessonId, totalXp, totalGems);
        
        final timeSpent = _progressController.getElapsedTime();
        await _updateDailyHistory(totalXp, totalGems, timeSpent);
        
        await _updateChallenges();
        
        try {
          if (Get.isRegistered<TreasureChallengesController>()) {
            final challengesController = Get.find<TreasureChallengesController>();
            
            await challengesController.updateChallengeProgress('lessons', 1);
            await challengesController.updateChallengeProgress(
              'correct_exercises', 
              _progressController.correctAnswers.value,
            );
          }
        } catch (_) {
        }
        
        await _unlockNextLesson(courseId, lessonId);
        
        try {
          final homeStatsController = Get.find<HomeStatsController>();
          await homeStatsController.reloadProgress();
        } catch (_) {
        }
        break;
        
      } on FirebaseException catch (_) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          errorMessage.value = 'Não foi possível salvar seu progresso. Tentaremos novamente automaticamente.';
        } else {
          final delayMs = 500 * retryCount;
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      } catch (_) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          errorMessage.value = 'Não foi possível salvar seu progresso. Tentaremos novamente automaticamente.';
        } else {
          final delayMs = 500 * retryCount;
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
    }
    
    isLoading.value = false;
  }

  // Métodos privados - Cálculo de recompensas
  
  /// Calcula XP total seguindo ordem CRÍTICA:
  /// 1. Base: lesson.xpReward * (accuracy / 100) - proporcional ao desempenho
  /// 2. Perfect bonus: +5 se isPerfect (todas corretas)
  /// 3. First today bonus: +5 se _isFirstLessonToday()
  /// 4. XP Booster: multiplica por 2 se ativo e não expirado
  Future<int> _calculateTotalXP() async {
    final baseXp = _flowController.currentLesson.value?['xpReward'] as int? ?? 10;
    final accuracy = _progressController.accuracy;
    
    print('📊 CÁLCULO DE XP:');
    print('   Base XP: $baseXp');
    print('   Accuracy: ${accuracy.toStringAsFixed(1)}%');
    print('   Corretas: ${_progressController.correctAnswers.value}');
    print('   Total: ${_progressController.totalAnswers.value}');
    print('   isPerfect: ${_progressController.isPerfect}');
    
    // Step 1: Base XP proporcional ao desempenho (accuracy)
    // Se acertar 50%, recebe 50% do XP base
    // Se acertar 100%, recebe 100% do XP base
    // Se acertar 0%, recebe 0 XP (sem garantia mínima)
    int totalXp = (baseXp * (accuracy / 100)).round();
    print('   XP Base Calculado: $totalXp');
    
    // Step 2: Perfect bonus (+5 se todas as respostas corretas)
    if (_progressController.isPerfect) {
      totalXp += 5;
      print('   + Perfect Bonus: +5 XP');
    }
    
    // Step 3: First today bonus (+5 se primeira lição hoje)
    final isFirstToday = await _isFirstLessonToday();
    if (isFirstToday) {
      totalXp += 5;
      print('   + First Today Bonus: +5 XP');
    }
    
    // Step 4: XP Booster (multiplica por 2 se ativo)
    final hasXpBooster = _xpLevelController.hasXpBooster;
    if (hasXpBooster) {
      totalXp *= 2;
      print('   × XP Booster: ×2');
    }
    
    print('   🎯 XP FINAL: $totalXp');
    
    return totalXp;
  }
  
  /// Calcula gems totais seguindo ordem CRÍTICA:
  /// 1. Base: lesson.gemsReward * (accuracy / 100) - proporcional ao desempenho
  /// 2. Gem Multiplier: multiplica por 2 se ativo e não expirado
  int _calculateTotalGems() {
    final baseGems = _flowController.currentLesson.value?['gemsReward'] as int? ?? 1;
    final accuracy = _progressController.accuracy;
    
    // Step 1: Base gems proporcional ao desempenho (accuracy)
    // Se acertar 50%, recebe 50% das gems base
    // Se acertar 100%, recebe 100% das gems base
    // Se acertar 0%, recebe 0 gems (sem garantia mínima)
    int totalGems = (baseGems * (accuracy / 100)).round();
    
    // Step 2: Gem Multiplier (multiplica por 2 se ativo)
    final hasGemMultiplier = _gemsController.hasGemMultiplier;
    if (hasGemMultiplier) {
      totalGems *= 2;
    }
    
    return totalGems;
  }
  
  /// Verifica se esta é a primeira lição completada hoje
  /// Usa timezone do usuário para determinar "hoje"
  Future<bool> _isFirstLessonToday() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;
      
      final todayDate = _getTodayDateString();
      
      // Verifica se já existe histórico para hoje
      final historyDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(todayDate)
          .get();
      
      if (!historyDoc.exists) return true;
      
      final lessonsCompleted = historyDoc.data()?['lessonsCompleted'] as int? ?? 0;
      return lessonsCompleted == 0;
    } catch (e) {
      return false;
    }
  }
  
  /// Retorna a data de hoje no formato YYYY-MM-DD (timezone do usuário)
  String _getTodayDateString() {
    try {
      final now = DateTime.now();
      return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    } catch (e) {
      final now = DateTime.now().toUtc();
      return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
  }

  // Métodos privados - Distribuição de recompensas
  
  /// Distribui XP para todos os três contadores atomicamente usando Firestore transaction
  Future<void> _distributeXP(int xpAmount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    // Buscar curso ativo
    final coursesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (coursesSnapshot.docs.isEmpty) {
      throw Exception('Nenhum curso ativo encontrado');
    }

    final courseId = coursesSnapshot.docs.first.id;
    
    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('stats')
        .doc('gamification');
    
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        if (!snapshot.exists) {
          throw Exception('Dados do usuário não encontrados');
        }
        
        final data = snapshot.data()!;
        final xpData = data['xp'] as Map<String, dynamic>? ?? {};
        
        final currentTotalXp = xpData['totalXp'] as int? ?? 0;
        final currentWeeklyXp = xpData['weeklyXp'] as int? ?? 0;
        final currentTodayXp = xpData['todayXp'] as int? ?? 0;
        
        transaction.update(statsRef, {
          'xp.totalXp': currentTotalXp + xpAmount,
          'xp.weeklyXp': currentWeeklyXp + xpAmount,
          'xp.todayXp': currentTodayXp + xpAmount,
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Erro ao distribuir XP: ${e.message}');
    }
  }
  
  /// Adiciona gems ao totalGems do usuário (operação atômica)
  Future<void> _addGems(int gemsAmount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    // Buscar curso ativo
    final coursesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (coursesSnapshot.docs.isEmpty) {
      throw Exception('Nenhum curso ativo encontrado');
    }

    final courseId = coursesSnapshot.docs.first.id;
    
    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('stats')
        .doc('gamification');
    
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        if (!snapshot.exists) {
          throw Exception('Dados do usuário não encontrados');
        }
        
        final data = snapshot.data()!;
        final gemsData = data['gems'] as Map<String, dynamic>? ?? {};
        
        final currentGems = gemsData['gems'] as int? ?? 0;
        final totalGemsEarned = gemsData['totalGemsEarned'] as int? ?? 0;
        
        transaction.update(statsRef, {
          'gems.gems': currentGems + gemsAmount,
          'gems.totalGemsEarned': totalGemsEarned + gemsAmount,
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Erro ao adicionar gems: ${e.message}');
    }
  }
  
  /// Verifica se o usuário deve subir de nível e executa o level up
  Future<bool> _checkAndLevelUp() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    // Buscar curso ativo
    final coursesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (coursesSnapshot.docs.isEmpty) {
      throw Exception('Nenhum curso ativo encontrado');
    }

    final courseId = coursesSnapshot.docs.first.id;
    
    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('stats')
        .doc('gamification');
    
    try {
      bool leveledUp = false;
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        if (!snapshot.exists) {
          throw Exception('Dados do usuário não encontrados');
        }
        
        final data = snapshot.data()!;
        final xpData = data['xp'] as Map<String, dynamic>? ?? {};
        
        final currentTotalXp = xpData['totalXp'] as int? ?? 0;
        final currentLevel = xpData['level'] as int? ?? 1;
        
        final xpForNextLevel = calculateXPForNextLevel(currentLevel);
        
        if (currentTotalXp >= xpForNextLevel) {
          final newLevel = currentLevel + 1;
          final newXpForNextLevel = calculateXPForNextLevel(newLevel);
          
          transaction.update(statsRef, {
            'xp.level': newLevel,
            'xp.xpToNextLevel': newXpForNextLevel,
          });
          
          leveledUp = true;
        }
      });
      
      return leveledUp;
    } on FirebaseException catch (e) {
      throw Exception('Erro ao verificar level up: ${e.message}');
    }
  }
  
  /// Calcula XP necessário para o próximo nível
  int calculateXPForNextLevel(int currentLevel) {
    return currentLevel * 100;
  }
  
  /// Atualiza o streak do usuário baseado na última data de streak
  Future<void> _updateStreak() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    // Buscar curso ativo
    final coursesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (coursesSnapshot.docs.isEmpty) {
      throw Exception('Nenhum curso ativo encontrado');
    }

    final courseId = coursesSnapshot.docs.first.id;
    
    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('stats')
        .doc('gamification');
    
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        if (!snapshot.exists) {
          throw Exception('Dados do usuário não encontrados');
        }
        
        final data = snapshot.data()!;
        final streakData = data['streak'] as Map<String, dynamic>? ?? {};
        
        final currentStreak = streakData['currentStreak'] as int? ?? 0;
        final longestStreak = streakData['longestStreak'] as int? ?? 0;
        final lastStreakDate = streakData['lastStreakDate'] as String? ?? '';
        
        final todayDate = _getTodayDateString();
        
        int newCurrentStreak;
        
        if (lastStreakDate == todayDate) {
          newCurrentStreak = currentStreak;
        } else if (_isYesterday(lastStreakDate, todayDate)) {
          newCurrentStreak = currentStreak + 1;
        } else {
          newCurrentStreak = 1;
        }
        
        final newLongestStreak = newCurrentStreak > longestStreak 
            ? newCurrentStreak 
            : longestStreak;
        
        transaction.update(statsRef, {
          'streak.currentStreak': newCurrentStreak,
          'streak.longestStreak': newLongestStreak,
          'streak.lastStreakDate': todayDate,
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar streak: ${e.message}');
    }
  }
  
  /// Verifica se uma data é ontem comparada com hoje
  bool _isYesterday(String lastStreakDate, String todayDate) {
    if (lastStreakDate.isEmpty) return false;
    
    try {
      final lastParts = lastStreakDate.split('-');
      final todayParts = todayDate.split('-');
      
      if (lastParts.length != 3 || todayParts.length != 3) return false;
      
      final lastDate = DateTime(
        int.parse(lastParts[0]),
        int.parse(lastParts[1]),
        int.parse(lastParts[2]),
      );
      
      final today = DateTime(
        int.parse(todayParts[0]),
        int.parse(todayParts[1]),
        int.parse(todayParts[2]),
      );
      
      final difference = today.difference(lastDate).inDays;
      
      return difference == 1;
    } catch (e) {
      return false;
    }
  }

  // Métodos privados - Persistência de progresso
  
  /// Salva o progresso da lição no Firestore
  Future<void> _updateLessonProgress(
    String courseId,
    String lessonId,
    int xpEarned,
    int gemsEarned,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    final timeSpent = _progressController.getElapsedTime();
    final mistakes = _progressController.totalAnswers.value - _progressController.correctAnswers.value;
    
    final accuracy = _progressController.totalAnswers.value > 0
        ? ((_progressController.correctAnswers.value / _progressController.totalAnswers.value) * 100).round()
        : 0;
    
    final progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('progress')
        .doc(lessonId);
    
    try {
      await progressRef.set({
        'lessonId': lessonId,
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'accuracy': accuracy,
        'xpEarned': xpEarned,
        'gemsEarned': gemsEarned,
        'timeSpent': timeSpent,
        'mistakes': mistakes,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Erro ao salvar progresso: ${e.message}');
    }
  }
  
  /// Atualiza o histórico diário do usuário
  Future<void> _updateDailyHistory(int xp, int gems, int timeSpent) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    // Obter courseId do curso ativo
    final courseId = _flowController.currentLesson.value?['courseId'] as String? ?? '';
    if (courseId.isEmpty) throw Exception('CourseId não pode ser vazio');
    
    final todayDate = _getTodayDateString();
    
    try {
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
          .doc(todayDate);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(dayRef);
        
        if (!snapshot.exists) {
          transaction.set(dayRef, {
            'date': todayDate,
            'xp': xp,
            'lessonsCompleted': 1,
            'gemsEarned': gems,
            'timeSpent': timeSpent,
            'exercisesCorrect': _progressController.correctAnswers.value,
            'exercisesTotal': _progressController.totalAnswers.value,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          final data = snapshot.data()!;
          
          transaction.update(dayRef, {
            'xp': (data['xp'] as int? ?? 0) + xp,
            'lessonsCompleted': (data['lessonsCompleted'] as int? ?? 0) + 1,
            'gemsEarned': (data['gemsEarned'] as int? ?? 0) + gems,
            'timeSpent': (data['timeSpent'] as int? ?? 0) + timeSpent,
            'exercisesCorrect': (data['exercisesCorrect'] as int? ?? 0) + _progressController.correctAnswers.value,
            'exercisesTotal': (data['exercisesTotal'] as int? ?? 0) + _progressController.totalAnswers.value,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar histórico: ${e.message}');
    }
  }
  
  /// Atualiza todos os desafios ativos do usuário
  Future<void> _updateChallenges() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    try {
      final challengesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .where('status', isEqualTo: 'active')
          .get();
      
      if (challengesSnapshot.docs.isEmpty) return;
      
      final batch = _firestore.batch();
      
      for (final doc in challengesSnapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String?;
        final goal = data['goal'] as int? ?? 0;
        final progress = data['progress'] as int? ?? 0;
        
        int newProgress = progress;
        
        switch (type) {
          case 'lessons_completed':
            newProgress = progress + 1;
            break;
          case 'xp_earned':
            final xp = await _calculateTotalXP();
            newProgress = progress + xp;
            break;
          case 'perfect_lessons':
            if (_progressController.isPerfect) newProgress = progress + 1;
            break;
          default:
            continue;
        }
        
        final isCompleted = newProgress >= goal;
        
        batch.update(doc.reference, {
          'progress': newProgress,
          'status': isCompleted ? 'completed' : 'active',
          if (isCompleted) 'completedAt': FieldValue.serverTimestamp(),
        });
        
        if (isCompleted && !data.containsKey('completedAt')) {
          final rewardXp = data['rewardXp'] as int? ?? 0;
          final rewardGems = data['rewardGems'] as int? ?? 0;
          
          if (rewardXp > 0) await _distributeXP(rewardXp);
          if (rewardGems > 0) await _addGems(rewardGems);
        }
      }
      
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar desafios: ${e.message}');
    }
  }
  
  /// Desbloqueia a próxima lição (lessonId + 1)
  Future<void> _unlockNextLesson(String courseId, String lessonId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    try {
      final lessonIdInt = int.tryParse(lessonId);
      if (lessonIdInt == null) return;
      
      final nextLessonId = lessonIdInt + 1;
      
      final nextLessonDoc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(nextLessonId.toString())
          .get();
      
      if (!nextLessonDoc.exists) return;
      
      final progressRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .doc(nextLessonId.toString());
      
      await progressRef.set({
        'lessonId': nextLessonId.toString(),
        'status': 'not_started',
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Erro ao desbloquear próxima lição: ${e.message}');
    }
  }
}
