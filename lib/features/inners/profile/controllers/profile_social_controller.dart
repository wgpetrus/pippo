import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';
import '../../../../shared/utils/language_helper.dart';

/// ProfileSocialController - Manages social features
class ProfileSocialController extends GetxController {
  // Firebase Instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Social States
  final following = <Map<String, dynamic>>[].obs;
  final followers = <Map<String, dynamic>>[].obs;
  final followingCount = 0.obs;
  final followersCount = 0.obs;
  final viewedUserId = ''.obs;
  final viewedUserData = <String, dynamic>{}.obs;
  final isFollowingViewedUser = false.obs;

  // Weekly Progress States
  final weeklyProgress = <Map<String, dynamic>>[].obs;
  final viewedUserWeeklyProgress = <Map<String, dynamic>>[].obs;
  final isLoadingProgress = false.obs;

  // Métodos públicos

  /// Carrega o perfil de outro usuário
  Future<void> loadUserProfile(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    viewedUserId.value = userId;

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null || currentUserId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Carregar documento do usuário
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        errorMessage.value = 'Usuário não encontrado.';
        return;
      }

      final userData = Map<String, dynamic>.from(
        userDoc.data() as Map<String, dynamic>,
      );

      // Carregar stats
      final statsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('gamification')
          .get();

      if (statsDoc.exists) {
        final stats = statsDoc.data() as Map<String, dynamic>;

        // Suportar estrutura nova (aninhada) e antiga (flat)
        if (stats['xp'] is Map) {
          final xpData = stats['xp'] as Map<String, dynamic>?;
          final streakData = stats['streak'] as Map<String, dynamic>?;
          userData['totalXp'] = xpData?['totalXp'] ?? 0;
          userData['level'] = xpData?['level'] ?? 1;
          userData['currentStreak'] = streakData?['currentStreak'] ?? 0;
          userData['longestStreak'] = streakData?['longestStreak'] ?? 0;
        } else {
          userData['totalXp'] = stats['xp'] ?? 0;
          userData['level'] = stats['level'] ?? 1;
          userData['currentStreak'] = stats['streak'] ?? 0;
          userData['longestStreak'] = stats['longestStreak'] ?? 0;
        }
      } else {
        userData['totalXp'] = 0;
        userData['currentStreak'] = 0;
        userData['longestStreak'] = 0;
        userData['level'] = 1;
      }

      // Carregar contadores de following/followers
      final followingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .count()
          .get();

      final followersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .count()
          .get();

      userData['followingCount'] = followingSnapshot.count ?? 0;
      userData['followersCount'] = followersSnapshot.count ?? 0;

      // Contar cursos ativos
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .count()
          .get();

      userData['coursesCount'] = coursesSnapshot.count ?? 0;

      final activeCourseSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (activeCourseSnapshot.docs.isNotEmpty) {
        final courseData = activeCourseSnapshot.docs.first.data();
        final languageCode = courseData['language'] as String;
        userData['primaryCourseLanguage'] = languageCode;
        userData['primaryCourseFlag'] = _getLanguageFlag(languageCode);
      } else {
        final primaryCourseSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .where('isPrimary', isEqualTo: true)
            .limit(1)
            .get();

        if (primaryCourseSnapshot.docs.isNotEmpty) {
          final courseData = primaryCourseSnapshot.docs.first.data();
          final languageCode = courseData['language'] as String;
          userData['primaryCourseLanguage'] = languageCode;
          userData['primaryCourseFlag'] = _getLanguageFlag(languageCode);
        } else {
          userData['primaryCourseFlag'] = null;
        }
      }

      viewedUserData.value = userData;

      // Verificar se o usuário atual segue este usuário
      await _checkIfFollowing(currentUserId, userId);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar perfil. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Segue outro usuário com operações atômicas
  Future<void> followUser(String targetUserId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null || currentUserId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      if (currentUserId == targetUserId) {
        errorMessage.value = 'Você não pode seguir a si mesmo.';
        return;
      }

      final batch = _firestore.batch();

      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);

      batch.set(followingRef, {
        'userId': targetUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      final followerRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId);

      batch.set(followerRef, {
        'userId': currentUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Atualizar estados locais
      isFollowingViewedUser.value = true;
      followingCount.value++;

      if (viewedUserId.value == targetUserId && viewedUserData.isNotEmpty) {
        final currentFollowers = viewedUserData['followersCount'] ?? 0;
        viewedUserData['followersCount'] = currentFollowers + 1;
        viewedUserData.refresh();
      }

      Get.snackbar(
        'Sucesso',
        'Você está seguindo este usuário!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao seguir usuário. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Para de seguir um usuário com operações atômicas
  Future<void> unfollowUser(String targetUserId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null || currentUserId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final batch = _firestore.batch();

      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);

      batch.delete(followingRef);

      final followerRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId);

      batch.delete(followerRef);

      await batch.commit();

      // Atualizar estados locais
      isFollowingViewedUser.value = false;
      followingCount.value--;

      if (viewedUserId.value == targetUserId && viewedUserData.isNotEmpty) {
        final currentFollowers = viewedUserData['followersCount'] ?? 0;
        viewedUserData['followersCount'] = (currentFollowers - 1)
            .clamp(0, double.infinity)
            .toInt();
        viewedUserData.refresh();
      }

      Get.snackbar(
        'Sucesso',
        'Você deixou de seguir este usuário.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao deixar de seguir. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega lista de usuários que o usuário atual segue
  Future<void> loadFollowing() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      errorMessage.value = 'Usuário não autenticado.';
      return;
    }

    final list = await _loadFollowList(userId, 'following');
    following.value = list;
    followingCount.value = list.length;
  }

  /// Carrega lista de usuários que seguem o usuário atual
  Future<void> loadFollowers() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      errorMessage.value = 'Usuário não autenticado.';
      return;
    }

    final list = await _loadFollowList(userId, 'followers');
    followers.value = list;
    followersCount.value = list.length;
  }

  /// Carrega lista de usuários que um usuário específico segue
  Future<void> loadUserFollowing(String userId) async {
    final list = await _loadFollowList(userId, 'following');
    following.value = list;
  }

  /// Carrega lista de usuários que seguem um usuário específico
  Future<void> loadUserFollowers(String userId) async {
    final list = await _loadFollowList(userId, 'followers');
    followers.value = list;
  }

  /// Verifica se o usuário atual está seguindo um usuário específico
  bool isUserFollowed(String targetUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      return false;
    }
    return following.any((user) => user['userId'] == targetUserId);
  }

  /// Carrega progresso semanal do usuário atual
  Future<void> loadWeeklyProgress() async {
    isLoadingProgress.value = true;

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      // Buscar curso ativo
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (coursesSnapshot.docs.isEmpty) {
        // Sem curso ativo, retornar dados zerados
        weeklyProgress.value = _getEmptyWeeklyProgress();
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      final progressList = <Map<String, dynamic>>[];

      for (var i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        // Caminho correto: users/{userId}/courses/{courseId}/stats/dailyHistory/days/{dateStr}
        final dayDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(courseId)
            .collection('stats')
            .doc('dailyHistory')
            .collection('days')
            .doc(dateStr)
            .get();

        final xp = dayDoc.exists ? (dayDoc.data()?['xp'] ?? 0) : 0;

        progressList.add({
          'day': _getDayAbbreviation(date.weekday),
          'xp': xp,
          'date': dateStr,
        });
      }

      weeklyProgress.value = progressList;
    } catch (e) {
      // Em caso de erro, retornar dados zerados
      weeklyProgress.value = _getEmptyWeeklyProgress();
    } finally {
      isLoadingProgress.value = false;
    }
  }

  /// Carrega progresso semanal de outro usuário
  Future<void> loadUserWeeklyProgress(String userId) async {
    isLoadingProgress.value = true;

    try {
      // Buscar curso ativo do usuário visualizado
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (coursesSnapshot.docs.isEmpty) {
        // Sem curso ativo, retornar dados zerados
        viewedUserWeeklyProgress.value = _getEmptyWeeklyProgress();
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      final progressList = <Map<String, dynamic>>[];

      for (var i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        // Caminho correto: users/{userId}/courses/{courseId}/stats/dailyHistory/days/{dateStr}
        final dayDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(courseId)
            .collection('stats')
            .doc('dailyHistory')
            .collection('days')
            .doc(dateStr)
            .get();

        final xp = dayDoc.exists ? (dayDoc.data()?['xp'] ?? 0) : 0;

        progressList.add({
          'day': _getDayAbbreviation(date.weekday),
          'xp': xp,
          'date': dateStr,
        });
      }

      viewedUserWeeklyProgress.value = progressList;
    } catch (e) {
      // Em caso de erro, retornar dados zerados
      viewedUserWeeklyProgress.value = _getEmptyWeeklyProgress();
    } finally {
      isLoadingProgress.value = false;
    }
  }

  // Métodos privados

  /// Helper para carregar lista de following/followers
  Future<List<Map<String, dynamic>>> _loadFollowList(
    String userId,
    String collectionName,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .get();

      final list = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final targetUserId = doc.data()['userId'] as String;

        final userDoc = await _firestore
            .collection('users')
            .doc(targetUserId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          userData['userId'] = targetUserId;

          final statsDoc = await _firestore
              .collection('users')
              .doc(targetUserId)
              .collection('stats')
              .doc('gamification')
              .get();

          if (statsDoc.exists) {
            final stats = statsDoc.data() as Map<String, dynamic>;
            final xpData = stats['xp'] as Map<String, dynamic>?;
            userData['totalXp'] = xpData?['totalXp'] ?? 0;
          } else {
            userData['totalXp'] = 0;
          }

          list.add(userData);
        }
      }

      return list;
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      return [];
    } catch (e) {
      errorMessage.value = 'Erro ao carregar lista. Tente novamente.';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifica se o usuário atual está seguindo outro usuário
  Future<void> _checkIfFollowing(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      final followingDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();

      isFollowingViewedUser.value = followingDoc.exists;
    } catch (e) {
      isFollowingViewedUser.value = false;
    }
  }

  /// Retorna progresso semanal vazio (7 dias com 0 XP)
  List<Map<String, dynamic>> _getEmptyWeeklyProgress() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final progressList = <Map<String, dynamic>>[];

    for (var i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      progressList.add({
        'day': _getDayAbbreviation(date.weekday),
        'xp': 0,
        'date': dateStr,
      });
    }

    return progressList;
  }

  /// Retorna abreviação do dia da semana
  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case 1:
        return 'Seg'; // Segunda
      case 2:
        return 'Ter'; // Terça
      case 3:
        return 'Qua'; // Quarta
      case 4:
        return 'Qui'; // Quinta
      case 5:
        return 'Sex'; // Sexta
      case 6:
        return 'Sáb'; // Sábado
      case 7:
        return 'Dom'; // Domingo
      default:
        return '';
    }
  }

  /// Retorna bandeira do idioma
  String _getLanguageFlag(String code) {
    return LanguageHelper.getLanguageFlag(code.toLowerCase());
  }

  // Handlers de erro

  /// Handler de erros do Firestore
  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
  }
}
