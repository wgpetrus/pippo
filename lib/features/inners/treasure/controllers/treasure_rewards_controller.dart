import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../gamification/controllers/gems_controller.dart';
import '../../gamification/controllers/xp_level_controller.dart';
import '../../../../shared/utils/error_handler.dart';
import 'treasure_challenges_controller.dart';

class TreasureRewardsController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final isClaimingReward = false.obs;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Constructor com DI
  TreasureRewardsController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  TreasureChallengesController? _challengesController;

  @override
  void onInit() {
    super.onInit();
    try {
      _challengesController = Get.find<TreasureChallengesController>();
    } catch (e) {
      _challengesController = null;
    }
  }

  Future<void> claimReward(String challengeId) async {
    isClaimingReward.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'error_unauthenticated'.tr;
        return;
      }

      if (_challengesController == null) {
        errorMessage.value = 'error_controller_unavailable'.tr;
        return;
      }

      final challengeData = _challengesController!.challenges.firstWhereOrNull(
        (c) => c['id'] == challengeId,
      );

      if (challengeData == null) {
        errorMessage.value = 'error_challenge_not_found'.tr;
        return;
      }

      if (!_isCompleted(challengeData)) {
        errorMessage.value = 'error_challenge_not_completed'.tr;
        return;
      }

      final isClaimed = challengeData['isClaimed'] as bool? ?? false;
      if (isClaimed) {
        errorMessage.value = 'error_reward_already_claimed'.tr;
        return;
      }

      if (_isExpired(challengeData)) {
        errorMessage.value = 'error_challenge_expired'.tr;
        return;
      }

      await _distributeReward(user.uid, challengeData);

      await _finalizeClaim(user.uid, challengeId, challengeData);

      Get.forceAppUpdate();
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'error_claim_reward'.tr;
    } finally {
      isClaimingReward.value = false;
    }
  }

  /// Carrega histórico de recompensas coletadas
  Future<void> loadRewardHistory() async {
    // TODO: Implementar quando necessário
    // Pode buscar desafios com isClaimed = true do Firestore
  }

  /// Calcula valor da recompensa de um desafio
  int calculateReward(Map<String, dynamic> challenge) {
    final rewardAmount = challenge['rewardAmount'] as int? ?? 0;
    return rewardAmount;
  }

  bool isClaimButtonEnabled(Map<String, dynamic> challenge) {
    return _canClaim(challenge) && !isClaimingReward.value;
  }

  bool shouldShowGlowAnimation(Map<String, dynamic> challenge) {
    final isClaimed = challenge['isClaimed'] as bool? ?? false;
    return _isCompleted(challenge) && !isClaimed && !_isExpired(challenge);
  }

  Future<void> _distributeReward(
      String userId, Map<String, dynamic> challengeData) async {
    final rewardType = challengeData['rewardType'] as String?;
    final rewardAmount = challengeData['rewardAmount'] as int?;

    if (rewardType == null || rewardAmount == null) {
      errorMessage.value = 'error_reward_invalid_data'.tr;
      return;
    }

    try {
      final activeCourseId = await _getActiveCourseId(userId);
      if (activeCourseId.isEmpty) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Nenhum curso ativo encontrado.',
        );
      }

      final xpHistoryDate = _formatDateForHistory(DateTime.now());

      await _firestore.runTransaction((transaction) async {
        final gamificationDocRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(activeCourseId)
            .collection('stats')
            .doc('gamification');
        
        final gamificationDoc = await transaction.get(gamificationDocRef);

        if (!gamificationDoc.exists) {
          transaction.set(gamificationDocRef, {
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        switch (rewardType) {
          case 'gems':
            transaction.update(gamificationDocRef, {
              'gems.gems': FieldValue.increment(rewardAmount),
              'gems.totalGemsEarned': FieldValue.increment(rewardAmount),
              'lastUpdated': FieldValue.serverTimestamp(),
            });
            break;

          case 'xp':
            transaction.update(gamificationDocRef, {
              'xp.totalXp': FieldValue.increment(rewardAmount),
              'xp.weeklyXP': FieldValue.increment(rewardAmount),
              'xp.todayXp': FieldValue.increment(rewardAmount),
              'lastUpdated': FieldValue.serverTimestamp(),
            });

            final dailyHistoryDocRef = _firestore
                .collection('users')
                .doc(userId)
                .collection('courses')
                .doc(activeCourseId)
                .collection('stats')
                .doc('dailyHistory');

            final dayDocRef = dailyHistoryDocRef
                .collection('days')
                .doc(xpHistoryDate);

            transaction.set(
              dailyHistoryDocRef,
              {'lastUpdated': FieldValue.serverTimestamp()},
              SetOptions(merge: true),
            );

            final dayDoc = await transaction.get(dayDocRef);
            if (dayDoc.exists) {
              transaction.update(dayDocRef, {
                'xp': FieldValue.increment(rewardAmount),
                'updatedAt': FieldValue.serverTimestamp(),
              });
            } else {
              transaction.set(dayDocRef, {
                'xp': rewardAmount,
                'date': xpHistoryDate,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
            break;

          case 'item':
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unimplemented',
              message: 'Recompensas de itens ainda não implementadas.',
            );

          default:
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'invalid-argument',
              message: 'Tipo de recompensa desconhecido: $rewardType',
            );
        }
      });

      try {
        switch (rewardType) {
          case 'gems':
            if (Get.isRegistered<GemsController>()) {
              final gemsController = Get.find<GemsController>();
              final oldGems = gemsController.gems.value;
              final oldTotal = gemsController.totalGemsEarned.value;

              gemsController.gems.value = oldGems + rewardAmount;
              gemsController.totalGemsEarned.value = oldTotal + rewardAmount;

              gemsController.gems.refresh();
              gemsController.totalGemsEarned.refresh();
            }
            break;

          case 'xp':
            if (Get.isRegistered<XpLevelController>()) {
              final xpController = Get.find<XpLevelController>();

              final oldTotalXp = xpController.totalXp.value;
              final oldWeeklyXp = xpController.weeklyXP.value;
              final oldTodayXp = xpController.todayXp.value;

              xpController.totalXp.value = oldTotalXp + rewardAmount;
              xpController.weeklyXP.value = oldWeeklyXp + rewardAmount;
              xpController.todayXp.value = oldTodayXp + rewardAmount;

              xpController.totalXp.refresh();
              xpController.weeklyXP.refresh();
              xpController.todayXp.refresh();
            }
            break;
        }
      } catch (e) {
        errorMessage.value = errorMessage.value;
      }
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      rethrow;
    }
  }

  Future<String> _getActiveCourseId(String userId) async {
    final coursesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (coursesSnapshot.docs.isEmpty) return '';
    return coursesSnapshot.docs.first.id;
  }

  String _formatDateForHistory(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Finaliza coleta de recompensa
  /// 
  /// Marca desafio como coletado no Firestore, remove da lista local
  /// e mostra animação de recompensa
  Future<void> _finalizeClaim(
      String userId, String challengeId, Map<String, dynamic> challengeData) async {
    // Marcar como coletado no Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('challenges')
        .doc(challengeId)
        .update({
      'isClaimed': true,
      'claimedAt': FieldValue.serverTimestamp(),
    });

    if (_challengesController != null) {
      _challengesController!.challenges.removeWhere((c) => c['id'] == challengeId);
    }

    // TODO: [Task 13.1] Mostrar animação de recompensa
    // _showRewardAnimation(challengeData);
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

  /// Verifica se um desafio pode ter recompensa coletada
  bool _canClaim(Map<String, dynamic> challenge) {
    final isClaimed = challenge['isClaimed'] as bool? ?? false;
    return _isCompleted(challenge) && !isClaimed && !_isExpired(challenge);
  }

  // Handlers

  /// Handler de erros do Firestore
  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
  }
}
