import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// ProfileController - Manages all profile operations
/// 
/// This controller handles:
/// - Profile data management (view, edit, update)
/// - Settings management
/// - Authentication changes (password, phone)
/// - Social features (follow/unfollow)
/// - Course management
/// - Account deletion
class ProfileController extends GetxController {
  // Firebase Instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  // Profile Data States
  final userName = ''.obs;
  final username = ''.obs;
  final bio = ''.obs;
  final avatarId = ''.obs;
  final country = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final phoneVerified = false.obs;

  // Profile Stats (read-only from gamification)
  final totalXp = 0.obs;
  final currentStreak = 0.obs;
  final lessonsCompleted = 0.obs;
  final level = 1.obs;

  // Profile Completion
  final profileCompletionPercentage = 0.obs;
  final missingFields = <String>[].obs;

  // Settings States
  final soundEffects = true.obs;
  final listeningExercises = true.obs;
  final speakingExercises = true.obs;
  final practiceReminders = false.obs;
  final reminderTime = '18:00'.obs;
  final leaderboardUpdates = true.obs;
  final friendActivity = true.obs;
  final dailyGoal = 10.obs;

  // Social States
  final following = <Map<String, dynamic>>[].obs;
  final followers = <Map<String, dynamic>>[].obs;
  final followingCount = 0.obs;
  final followersCount = 0.obs;
  final viewedUserId = ''.obs;
  final viewedUserData = <String, dynamic>{}.obs;
  final isFollowingViewedUser = false.obs;

  // Course Management States
  final userCourses = <Map<String, dynamic>>[].obs;
  final primaryCourseId = ''.obs;

  // Search States
  final searchQuery = ''.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;
  final searchErrorMessage = ''.obs;

  // UI States
  final isLoading = false.obs;
  final isLoadingProfile = false.obs;
  final isLoadingSettings = false.obs;
  final isLoadingSocial = false.obs;
  final isLoadingCourses = false.obs;
  final errorMessage = ''.obs;
  final isUsernameAvailable = true.obs;
  final isCheckingUsername = false.obs;

  // Phone Verification
  String verificationId = '';

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    // Controller initialization will be implemented in later tasks
  }

  @override
  void onClose() {
    // Cleanup if needed
    super.onClose();
  }

  // ============================================================================
  // Métodos Públicos - Profile Management
  // ============================================================================

  /// Carrega o perfil do usuário atual
  Future<void> loadOwnProfile() async {
    isLoadingProfile.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Carregar documento do usuário
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        errorMessage.value = 'Perfil não encontrado.';
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;

      // Atualizar estados observáveis
      userName.value = data['name'] ?? '';
      username.value = data['username'] ?? '';
      bio.value = data['bio'] ?? '';
      avatarId.value = data['avatarId'] ?? 'avatar_01';
      country.value = data['country'] ?? 'BR';
      email.value = data['email'] ?? '';
      phone.value = data['phone'] ?? '';
      phoneVerified.value = data['phoneVerified'] ?? false;

      // Carregar stats da gamificação
      await _loadProfileStats(userId);

      // Calcular completude do perfil
      _calculateProfileCompletion(data);

      // Carregar contadores sociais
      await _loadSocialCounts(userId);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar perfil. Tente novamente.';
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Carrega o perfil de outro usuário
  Future<void> loadUserProfile(String userId) async {
    isLoadingProfile.value = true;
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

      viewedUserData.value = userDoc.data() as Map<String, dynamic>;

      // Carregar stats
      final statsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('gamification')
          .get();

      if (statsDoc.exists) {
        final stats = statsDoc.data() as Map<String, dynamic>;
        viewedUserData['totalXp'] = stats['totalXp'] ?? 0;
        viewedUserData['currentStreak'] = stats['currentStreak'] ?? 0;
        viewedUserData['level'] = stats['level'] ?? 1;
      }

      // Verificar se o usuário atual segue este usuário
      await _checkIfFollowing(currentUserId, userId);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar perfil. Tente novamente.';
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Atualiza campos do perfil do usuário
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Se o nome foi atualizado, criar campo searchName para busca case-insensitive
      if (updates.containsKey('name')) {
        updates['searchName'] = (updates['name'] as String).toLowerCase();
      }

      // Adicionar timestamp de atualização
      updates['updatedAt'] = FieldValue.serverTimestamp();

      // Atualizar Firestore
      await _firestore.collection('users').doc(userId).update(updates);

      // Atualizar estados locais
      if (updates.containsKey('name')) userName.value = updates['name'];
      if (updates.containsKey('username')) username.value = updates['username'];
      if (updates.containsKey('bio')) bio.value = updates['bio'];
      if (updates.containsKey('avatarId')) avatarId.value = updates['avatarId'];
      if (updates.containsKey('country')) country.value = updates['country'];

      // Recalcular completude
      await loadOwnProfile();

      Get.snackbar(
        'Sucesso',
        'Perfil atualizado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao atualizar perfil. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifica disponibilidade de nome de usuário
  Future<void> checkUsernameAvailability(String newUsername) async {
    // Pular se for o mesmo nome de usuário atual
    if (newUsername == username.value) {
      isUsernameAvailable.value = true;
      return;
    }

    isCheckingUsername.value = true;

    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: newUsername)
          .limit(1)
          .get();

      isUsernameAvailable.value = query.docs.isEmpty;
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      isUsernameAvailable.value = false;
    } catch (e) {
      isUsernameAvailable.value = false;
    } finally {
      isCheckingUsername.value = false;
    }
  }

  // ============================================================================
  // Métodos Públicos - Settings Management
  // ============================================================================

  /// Carrega configurações do usuário do Firestore
  Future<void> loadSettings() async {
    isLoadingSettings.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final settingsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (settingsDoc.exists) {
        final data = settingsDoc.data() as Map<String, dynamic>;

        // Som e Exercícios
        soundEffects.value = data['soundEffects'] ?? true;
        listeningExercises.value = data['listeningExercises'] ?? true;
        speakingExercises.value = data['speakingExercises'] ?? true;

        // Notificações
        practiceReminders.value = data['practiceReminders'] ?? false;
        reminderTime.value = data['reminderTime'] ?? '18:00';
        leaderboardUpdates.value = data['leaderboardUpdates'] ?? true;
        friendActivity.value = data['friendActivity'] ?? true;

        // Meta diária
        dailyGoal.value = data['dailyGoal'] ?? 10;
      }
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar configurações. Tente novamente.';
    } finally {
      isLoadingSettings.value = false;
    }
  }

  /// Atualiza uma configuração específica
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set({key: value}, SetOptions(merge: true));

      // Atualizar estado local
      switch (key) {
        case 'soundEffects':
          soundEffects.value = value as bool;
          break;
        case 'listeningExercises':
          listeningExercises.value = value as bool;
          break;
        case 'speakingExercises':
          speakingExercises.value = value as bool;
          break;
        case 'practiceReminders':
          practiceReminders.value = value as bool;
          break;
        case 'reminderTime':
          reminderTime.value = value as String;
          break;
        case 'leaderboardUpdates':
          leaderboardUpdates.value = value as bool;
          break;
        case 'friendActivity':
          friendActivity.value = value as bool;
          break;
        case 'dailyGoal':
          dailyGoal.value = value as int;
          break;
      }
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao atualizar configuração. Tente novamente.';
    }
  }

  // ============================================================================
  // Métodos Públicos - Authentication Changes
  // ============================================================================

  /// Altera a senha do usuário com reautenticação
  Future<void> changePassword(String currentPassword, String newPassword) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Reautenticar
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Alterar senha
      await user.updatePassword(newPassword);

      Get.snackbar(
        'Sucesso',
        'Senha alterada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseAuthError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao alterar senha. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Vincula número de telefone usando Firebase Phone Auth
  Future<void> linkPhoneNumber(String phoneNumber, String verificationCode) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Criar credencial de telefone
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: verificationCode,
      );

      // Vincular credencial
      await user.linkWithCredential(credential);

      // Atualizar Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'phone': phoneNumber,
        'phoneVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      phone.value = phoneNumber;
      phoneVerified.value = true;

      Get.snackbar(
        'Sucesso',
        'Telefone vinculado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/profile/phone-linked');
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseAuthError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao vincular telefone. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================================
  // Métodos Públicos - Social Features
  // ============================================================================

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

      // Adicionar à subcoleção following do usuário atual
      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);

      batch.set(followingRef, {
        'userId': targetUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // Adicionar à subcoleção followers do usuário alvo
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

      // Remover da subcoleção following do usuário atual
      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);

      batch.delete(followingRef);

      // Remover da subcoleção followers do usuário alvo
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
    isLoadingSocial.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final followingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      final followingList = <Map<String, dynamic>>[];

      for (final doc in followingSnapshot.docs) {
        final followedUserId = doc.data()['userId'] as String;

        // Carregar dados do usuário
        final userDoc =
            await _firestore.collection('users').doc(followedUserId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          userData['userId'] = followedUserId;
          followingList.add(userData);
        }
      }

      following.value = followingList;
      followingCount.value = followingList.length;
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar seguindo. Tente novamente.';
    } finally {
      isLoadingSocial.value = false;
    }
  }

  /// Carrega lista de usuários que seguem o usuário atual
  Future<void> loadFollowers() async {
    isLoadingSocial.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final followersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .get();

      final followersList = <Map<String, dynamic>>[];

      for (final doc in followersSnapshot.docs) {
        final followerUserId = doc.data()['userId'] as String;

        // Carregar dados do usuário
        final userDoc =
            await _firestore.collection('users').doc(followerUserId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          userData['userId'] = followerUserId;
          followersList.add(userData);
        }
      }

      followers.value = followersList;
      followersCount.value = followersList.length;
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar seguidores. Tente novamente.';
    } finally {
      isLoadingSocial.value = false;
    }
  }

  // ============================================================================
  // Métodos Públicos - Course Management
  // ============================================================================

  /// Carrega todos os cursos do usuário atual
  Future<void> loadUserCourses() async {
    isLoadingCourses.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .get();

      final coursesList = <Map<String, dynamic>>[];
      String? primaryId;

      for (final doc in coursesSnapshot.docs) {
        final courseData = doc.data();
        courseData['id'] = doc.id;
        coursesList.add(courseData);

        if (courseData['isPrimary'] == true) {
          primaryId = doc.id;
        }
      }

      userCourses.value = coursesList;
      primaryCourseId.value = primaryId ?? '';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar cursos. Tente novamente.';
    } finally {
      isLoadingCourses.value = false;
    }
  }

  /// Define um curso como principal (apenas um pode ser principal)
  Future<void> setPrimaryCourse(String courseId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final batch = _firestore.batch();

      // Desmarcar todos os cursos como principal
      for (final course in userCourses) {
        final courseRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(course['id'] as String);

        batch.update(courseRef, {'isPrimary': false});
      }

      // Marcar o curso selecionado como principal
      final selectedCourseRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId);

      batch.update(selectedCourseRef, {'isPrimary': true});

      await batch.commit();

      // Atualizar estados locais
      primaryCourseId.value = courseId;
      for (final course in userCourses) {
        course['isPrimary'] = (course['id'] == courseId);
      }
      userCourses.refresh();

      Get.snackbar(
        'Sucesso',
        'Curso principal atualizado!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao definir curso principal. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove um curso dos cursos ativos do usuário
  Future<void> removeCourse(String courseId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Verificar se é o curso principal
      if (courseId == primaryCourseId.value) {
        errorMessage.value =
            'Não é possível remover o curso principal. Defina outro curso como principal primeiro.';
        return;
      }

      // Marcar como inativo ao invés de deletar (preservar progresso)
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .update({'isActive': false});

      // Remover da lista local
      userCourses.removeWhere((course) => course['id'] == courseId);

      Get.snackbar(
        'Sucesso',
        'Curso removido!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao remover curso. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================================
  // Métodos Públicos - Account Deletion
  // ============================================================================

  /// Exclui a conta do usuário com todos os dados associados
  Future<void> deleteAccount() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final userId = user.uid;

      // Deletar dados do usuário do Firestore
      final batch = _firestore.batch();

      // Deletar documento principal do usuário
      final userRef = _firestore.collection('users').doc(userId);
      batch.delete(userRef);

      // Nota: Subcoleções (courses, stats, history, following, followers)
      // devem ser deletadas via Cloud Function trigger na exclusão do usuário
      // para evitar exceder limites de batch write

      await batch.commit();

      // Deletar conta do Firebase Auth
      await user.delete();

      // Navegar para tela de autenticação
      Get.offAllNamed('/auth');

      Get.snackbar(
        'Conta Excluída',
        'Sua conta foi excluída permanentemente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        errorMessage.value =
            'Por segurança, faça login novamente antes de excluir sua conta.';
        // Acionar fluxo de reautenticação
        await _reauthenticateForDeletion();
      } else {
        errorMessage.value = _handleFirebaseAuthError(e);
      }
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao excluir conta. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================================
  // Métodos Privados
  // ============================================================================

  /// Carrega estatísticas de gamificação do perfil
  Future<void> _loadProfileStats(String userId) async {
    final statsDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification')
        .get();

    if (statsDoc.exists) {
      final stats = statsDoc.data() as Map<String, dynamic>;
      totalXp.value = stats['totalXp'] ?? 0;
      currentStreak.value = stats['currentStreak'] ?? 0;
      level.value = stats['level'] ?? 1;
    }

    // Contar lições completadas em todos os cursos
    final coursesSnapshot =
        await _firestore.collection('users').doc(userId).collection('courses').get();

    int totalLessons = 0;
    for (final courseDoc in coursesSnapshot.docs) {
      final courseData = courseDoc.data();
      totalLessons += (courseData['lessonsCompleted'] ?? 0) as int;
    }

    lessonsCompleted.value = totalLessons;
  }

  /// Calcula porcentagem de completude do perfil
  void _calculateProfileCompletion(Map<String, dynamic> userData) {
    final requiredFields = ['name', 'username', 'avatarId', 'country', 'bio'];
    final missing = <String>[];
    int completed = 0;

    for (final field in requiredFields) {
      final value = userData[field];
      if (value != null && value.toString().isNotEmpty) {
        completed++;
      } else {
        missing.add(field);
      }
    }

    profileCompletionPercentage.value =
        ((completed / requiredFields.length) * 100).round();
    missingFields.value = missing;
  }

  /// Carrega contadores de seguindo/seguidores
  Future<void> _loadSocialCounts(String userId) async {
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

    followingCount.value = followingSnapshot.count ?? 0;
    followersCount.value = followersSnapshot.count ?? 0;
  }

  /// Verifica se o usuário atual segue o usuário alvo
  Future<void> _checkIfFollowing(String currentUserId, String targetUserId) async {
    final followingDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .get();

    isFollowingViewedUser.value = followingDoc.exists;
  }

  /// Reautentica o usuário antes de exclusão de conta
  Future<void> _reauthenticateForDeletion() async {
    // Esta função seria chamada quando o erro 'requires-recent-login' ocorre
    // A implementação depende do fluxo de UI (modal/dialog para senha)
    // Por enquanto, apenas mostra mensagem para o usuário fazer login novamente
    errorMessage.value = 'Por segurança, faça login novamente antes de excluir sua conta.';
    
    // TODO: Implementar modal/dialog de reautenticação quando a UI estiver pronta
    // Após reautenticação bem-sucedida, chamar deleteAccount() novamente
  }

  // ============================================================================
  // Validadores
  // ============================================================================

  /// Valida o nome do usuário
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório.';
    }
    if (value.length < 2) {
      return 'O nome deve ter pelo menos 2 caracteres.';
    }
    if (value.length > 50) {
      return 'O nome deve ter no máximo 50 caracteres.';
    }
    return null;
  }

  /// Valida o nome de usuário
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome de usuário é obrigatório.';
    }
    if (value.length < 3) {
      return 'O nome de usuário deve ter pelo menos 3 caracteres.';
    }
    if (value.length > 20) {
      return 'O nome de usuário deve ter no máximo 20 caracteres.';
    }
    // Verificar formato: apenas letras, números e underscore
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Use apenas letras, números e underscore.';
    }
    // Verificar disponibilidade
    if (!isUsernameAvailable.value) {
      return 'Este nome de usuário já está em uso.';
    }
    return null;
  }

  /// Valida a bio do usuário
  String? validateBio(String? value) {
    if (value != null && value.length > 150) {
      return 'A bio deve ter no máximo 150 caracteres.';
    }
    return null;
  }

  /// Valida a senha atual
  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha atual é obrigatória.';
    }
    return null;
  }

  /// Valida a nova senha
  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nova senha é obrigatória.';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  /// Valida a confirmação de senha
  String? validateConfirmPassword(String? value, String newPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória.';
    }
    if (value != newPassword) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  /// Valida o número de telefone
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Número de telefone é obrigatório.';
    }
    // Remover caracteres de formatação
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Número de telefone inválido.';
    }
    return null;
  }

  // ============================================================================
  // Error Handlers
  // ============================================================================

  /// Trata erros do Firestore com mensagens amigáveis em português
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
      case 'failed-precondition':
        return 'Operação não permitida no estado atual. Tente novamente.';
      case 'aborted':
        return 'Operação cancelada. Tente novamente.';
      case 'out-of-range':
        return 'Erro: valor fora do intervalo permitido. Verifique os dados.';
      case 'unimplemented':
        return 'Operação não implementada.';
      case 'internal':
        return 'Erro interno do servidor. Tente novamente em alguns instantes.';
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'not-found':
        return 'Recurso não encontrado. Verifique os dados e tente novamente.';
      case 'already-exists':
        return 'Recurso já existe.';
      case 'cancelled':
        return 'Operação cancelada.';
      case 'data-loss':
        return 'Erro de integridade de dados.';
      case 'invalid-argument':
        return 'Erro: argumento inválido. Verifique os dados e tente novamente.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }

  // ============================================================================
  // Métodos Públicos - Search
  // ============================================================================

  /// Busca usuários por username ou nome
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    searchErrorMessage.value = '';
    searchQuery.value = query.trim().toLowerCase();

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null || currentUserId.isEmpty) {
        searchErrorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Buscar por username (exato ou começa com)
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchQuery.value)
          .where('username', isLessThan: '${searchQuery.value}z')
          .limit(20)
          .get();

      // Buscar por nome (case-insensitive via campo searchName)
      final nameQuery = await _firestore
          .collection('users')
          .where('searchName', isGreaterThanOrEqualTo: searchQuery.value)
          .where('searchName', isLessThan: '${searchQuery.value}z')
          .limit(20)
          .get();

      // Combinar resultados e remover duplicatas
      final results = <String, Map<String, dynamic>>{};

      for (var doc in usernameQuery.docs) {
        if (doc.id != currentUserId) {
          results[doc.id] = {
            'userId': doc.id,
            ...doc.data(),
          };
        }
      }

      for (var doc in nameQuery.docs) {
        if (doc.id != currentUserId && !results.containsKey(doc.id)) {
          results[doc.id] = {
            'userId': doc.id,
            ...doc.data(),
          };
        }
      }

      searchResults.value = results.values.toList();

      if (searchResults.isEmpty) {
        searchErrorMessage.value = 'Nenhum usuário encontrado.';
      }
    } on FirebaseException catch (e) {
      searchErrorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      searchErrorMessage.value = 'Erro ao buscar usuários. Tente novamente.';
    } finally {
      isSearching.value = false;
    }
  }

  /// Limpa resultados da busca
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    searchErrorMessage.value = '';
  }

  // ============================================================================
  // Métodos Privados - Error Handlers
  // ============================================================================

  /// Trata erros do Firebase Auth com mensagens amigáveis em português
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Senha incorreta. Verifique e tente novamente.';
      case 'weak-password':
        return 'Senha fraca. A senha deve ter pelo menos 6 caracteres.';
      case 'requires-recent-login':
        return 'Por favor, faça login novamente para continuar por segurança.';
      case 'invalid-verification-code':
        return 'Código de verificação inválido.';
      case 'invalid-verification-id':
        return 'ID de verificação inválido. Solicite um novo Código.';
      case 'credential-already-in-use':
        return 'Este telefone já está vinculado a outra conta.';
      case 'provider-already-linked':
        return 'Este método de autenticação já está vinculado.';
      case 'invalid-credential':
        return 'Credencial de autenticação inválida. Verifique seus dados e tente novamente.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      case 'too-many-requests':
        return 'Por favor, aguarde alguns minutos antes de tentar novamente.';
      default:
        return 'Erro ao processar solicitação. Tente novamente.';
    }
  }
}
