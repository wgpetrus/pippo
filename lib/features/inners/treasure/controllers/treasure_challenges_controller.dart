import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';

class TreasureChallengesController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final challenges = <Map<String, dynamic>>[].obs;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Constructor com DI
  TreasureChallengesController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadChallenges();
  }

  Future<void> loadChallenges() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      await _fetchChallengesFromFirestore(user.uid);

      await removeExpiredChallenges();
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value =
          'Erro ao carregar desafios. Verifique sua conexão e tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateChallengeProgress(String challengeType, int amount) async {
    try {
      if (amount < 0) {
        errorMessage.value = 'O progresso não pode ser negativo.';
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      final matchingChallenges = challenges.where((challenge) {
        final cType = challenge['challengeType'] as String?;
        final isClaimed = challenge['isClaimed'] as bool? ?? false;
        
        return cType == challengeType && 
               !isClaimed && 
               !_isExpired(challenge);
      }).toList();

      for (final challenge in matchingChallenges) {
        final challengeId = challenge['id'] as String?;
        if (challengeId == null) continue;

        final currentProgress = challenge['progress'] as int? ?? 0;
        final goal = challenge['goal'] as int? ?? 0;
        final newProgress = currentProgress + amount;

        final docRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('challenges')
            .doc(challengeId);

        await docRef.update({
          'progress': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (newProgress >= goal && !_isCompleted(challenge)) {
          await docRef.update({
            'isCompleted': true,
            'completedAt': FieldValue.serverTimestamp(),
          });

          challenge['progress'] = newProgress;
          challenge['isCompleted'] = true;
          challenge['completedAt'] = Timestamp.now();
        } else {
          challenge['progress'] = newProgress;
        }
      }

      challenges.refresh();
    } on FirebaseException catch (e) {
      // Silenciosamente falhar para não interromper fluxo principal
      // Erros de progresso não devem bloquear ações do usuário
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      // Silenciosamente falhar para não interromper fluxo principal
      errorMessage.value = 'Erro ao atualizar progresso do desafio.';
    }
  }

  /// Verifica se um desafio está completado
  Future<void> checkChallengeCompletion(String challengeId) async {
    try {
      // Buscar desafio na lista local
      final challengeData = challenges.firstWhereOrNull(
        (c) => c['id'] == challengeId,
      );

      if (challengeData == null) {
        errorMessage.value = 'Desafio não encontrado.';
        return;
      }

      // Verificar se está completado
      if (_isCompleted(challengeData)) {
      } else {
      }
    } catch (e) {
      errorMessage.value = 'Erro ao verificar conclusão do desafio.';
    }
  }

  /// Remove desafios expirados da lista local e do Firestore
  Future<void> removeExpiredChallenges() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Identificar desafios expirados
      final expiredChallenges =
          challenges.where((challenge) => _isExpired(challenge)).toList();

      // Remover do Firestore
      for (final challenge in expiredChallenges) {
        final challengeId = challenge['id'] as String?;
        if (challengeId != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('challenges')
              .doc(challengeId)
              .delete();
        }
      }

      // Remover da lista local
      challenges.removeWhere((challenge) => _isExpired(challenge));
    } catch (e) {
      // Silenciosamente falhar para não interromper o fluxo
      // A remoção será tentada novamente na próxima carga
    }
  }

  // Métodos de determinação de estado (para UI)

  bool isInProgress(Map<String, dynamic> challenge) {
    final isClaimed = challenge['isClaimed'] as bool? ?? false;
    return !_isCompleted(challenge) && !isClaimed && !_isExpired(challenge);
  }

  bool isCompletedState(Map<String, dynamic> challenge) {
    final isClaimed = challenge['isClaimed'] as bool? ?? false;
    return _isCompleted(challenge) && !isClaimed && !_isExpired(challenge);
  }

  double getProgressPercentage(Map<String, dynamic> challenge) {
    return _getProgressPercentage(challenge);
  }

  // Validação de estrutura de desafios

  String? validateChallengeStructure(Map<String, dynamic> challenge) {
    final requiredFields = [
      'title',
      'description',
      'goal',
      'progress',
      'rewardType',
      'rewardAmount',
      'expirationDate',
      'iconPath',
      'type',
    ];

    for (final field in requiredFields) {
      if (!challenge.containsKey(field) || challenge[field] == null) {
        return 'Todos os campos obrigatórios devem ser preenchidos.';
      }
    }

    final goal = challenge['goal'];
    if (goal is! int || goal <= 0) {
      return 'O objetivo deve ser um número positivo.';
    }

    final rewardAmount = challenge['rewardAmount'];
    if (rewardAmount is! int || rewardAmount <= 0) {
      return 'A recompensa deve ser um valor positivo.';
    }

    final rewardType = challenge['rewardType'];
    if (rewardType is! String ||
        !['gems', 'xp', 'item'].contains(rewardType)) {
      return 'Tipo de recompensa inválido.';
    }

    final progress = challenge['progress'];
    if (progress is! int || progress != 0) {
      return 'O progresso inicial deve ser zero.';
    }

    return null;
  }

  bool hasRequiredFields(Map<String, dynamic> challenge) {
    final requiredFields = [
      'title',
      'description',
      'goal',
      'progress',
      'rewardType',
      'rewardAmount',
      'expirationDate',
      'iconPath',
      'type',
    ];

    for (final field in requiredFields) {
      if (!challenge.containsKey(field) || challenge[field] == null) {
        return false;
      }
    }

    return true;
  }

  bool isValidGoal(Map<String, dynamic> challenge) {
    final goal = challenge['goal'];
    return goal is int && goal > 0;
  }

  bool isValidRewardAmount(Map<String, dynamic> challenge) {
    final rewardAmount = challenge['rewardAmount'];
    return rewardAmount is int && rewardAmount > 0;
  }

  /// Valida se reward type é válido
  bool isValidRewardType(Map<String, dynamic> challenge) {
    final rewardType = challenge['rewardType'];
    return rewardType is String && ['gems', 'xp', 'item'].contains(rewardType);
  }

  bool hasZeroInitialProgress(Map<String, dynamic> challenge) {
    final progress = challenge['progress'];
    return progress is int && progress == 0;
  }

  // Geração de desafios (opcional)

  Future<void> deleteAllChallenges() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('challenges')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      challenges.clear();
    } catch (e) {
      errorMessage.value = errorMessage.value;
    }
  }

  Future<void> generateDailyChallenges() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final dailyTemplates = [
        {
          'title': 'Complete 3 lições',
          'description': 'Termine 3 lições hoje para ganhar gems',
          'goal': 3,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'iconPath': 'assets/images/icons/icons-treasure-page/livro.png',
          'type': 'daily',
          'challengeType': 'lessons',
        },
        {
          'title': 'Ganhe 100 XP',
          'description': 'Acumule 100 XP hoje',
          'goal': 100,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 30,
          'iconPath': 'assets/images/icons/icons-treasure-page/xp-coin.png',
          'type': 'daily',
          'challengeType': 'xp',
        },
        {
          'title': 'Acerte 10 exercícios',
          'description': 'Complete 10 exercícios corretamente',
          'goal': 10,
          'progress': 0,
          'rewardType': 'xp',
          'rewardAmount': 50,
          'iconPath': 'assets/images/icons/icons-treasure-page/alvo.png',
          'type': 'daily',
          'challengeType': 'correct_exercises',
        },
      ];

      final expiration = calculateExpiration('daily');

      for (final template in dailyTemplates) {
        final challengeData = {
          ...template,
          'expirationDate': Timestamp.fromDate(expiration),
          'isClaimed': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('challenges')
            .add(challengeData);
      }

      await loadChallenges();
    } catch (e) {
      errorMessage.value = errorMessage.value;
    }
  }

  Future<void> generateWeeklyChallenges() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final weeklyTemplates = [
        {
          'title': 'Complete 15 lições esta semana',
          'description': 'Termine 15 lições até domingo para ganhar gems',
          'goal': 15,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 200,
          'iconPath': 'assets/images/icons/icons-treasure-page/bau-gemado.png',
          'type': 'weekly',
          'challengeType': 'lessons',
        },
        {
          'title': 'Mantenha streak de 7 dias',
          'description': 'Estude todos os dias da semana',
          'goal': 7,
          'progress': 0,
          'rewardType': 'xp',
          'rewardAmount': 300,
          'iconPath': 'assets/images/icons/icons-appbar-home/fire_appbar.png',
          'type': 'weekly',
          'challengeType': 'streak',
        },
        {
          'title': 'Ganhe 500 XP esta semana',
          'description': 'Acumule 500 XP até domingo',
          'goal': 500,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 150,
          'iconPath': 'assets/images/icons/icons-treasure-page/xp-coin.png',
          'type': 'weekly',
          'challengeType': 'xp',
        },
      ];

      final expiration = calculateExpiration('weekly');

      for (final template in weeklyTemplates) {
        final challengeData = {
          ...template,
          'expirationDate': Timestamp.fromDate(expiration),
          'isClaimed': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('challenges')
            .add(challengeData);
      }

      await loadChallenges();
    } catch (e) {
      errorMessage.value = errorMessage.value;
    }
  }

  // Métodos auxiliares (helpers)

  DateTime calculateExpiration(String type, {DateTime? customDate}) {
    final now = DateTime.now();

    switch (type) {
      case 'daily':
        return DateTime(now.year, now.month, now.day, 23, 59, 59);

      case 'weekly':
        final daysUntilSunday = DateTime.sunday - now.weekday;
        final nextSunday = daysUntilSunday == 0
            ? now
            : now.add(Duration(days: daysUntilSunday));
        return DateTime(
            nextSunday.year, nextSunday.month, nextSunday.day, 23, 59, 59);

      case 'special':
        return customDate ?? now.add(const Duration(days: 7));

      default:
        return now.add(const Duration(days: 1));
    }
  }

  // Métodos privados

  Future<void> _fetchChallengesFromFirestore(String userId,
      {int retryCount = 0}) async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .get()
          .timeout(const Duration(seconds: 30));

      final challengesList = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      challengesList.sort((a, b) {
        final aType = a['type'] as String? ?? '';
        final bType = b['type'] as String? ?? '';
        final typeCompare = aType.compareTo(bType);
        if (typeCompare != 0) return typeCompare;

        final aExpiration = (a['expirationDate'] as Timestamp?)?.toDate();
        final bExpiration = (b['expirationDate'] as Timestamp?)?.toDate();

        if (aExpiration == null && bExpiration == null) return 0;
        if (aExpiration == null) return 1;
        if (bExpiration == null) return -1;

        return aExpiration.compareTo(bExpiration);
      });

      challenges.value = challengesList;
    } on TimeoutException {
      // Retry em caso de timeout
      if (retryCount < maxRetries) {
        await Future.delayed(retryDelay);
        return _fetchChallengesFromFirestore(userId,
            retryCount: retryCount + 1);
      }
      rethrow;
    } on FirebaseException catch (e) {
      // Retry em caso de erro de rede ou indisponibilidade
      if ((e.code == 'unavailable' || e.code == 'deadline-exceeded') &&
          retryCount < maxRetries) {
        await Future.delayed(retryDelay);
        return _fetchChallengesFromFirestore(userId,
            retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  /// Verifica se um desafio está expirado
  bool _isExpired(Map<String, dynamic> challenge) {
    final expirationDate =
        (challenge['expirationDate'] as Timestamp?)?.toDate();
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate);
  }

  /// Verifica se um desafio está completo (progresso >= objetivo)
  bool _isCompleted(Map<String, dynamic> challenge) {
    final progress = challenge['progress'] as int? ?? 0;
    final goal = challenge['goal'] as int? ?? 0;
    return progress >= goal;
  }

  /// Calcula porcentagem de progresso de um desafio (0.0 a 1.0)
  double _getProgressPercentage(Map<String, dynamic> challenge) {
    final progress = challenge['progress'] as int? ?? 0;
    final goal = challenge['goal'] as int? ?? 1;
    return (progress / goal).clamp(0.0, 1.0);
  }

  // Handlers

  /// Handler de erros do Firestore
  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
  }
}
