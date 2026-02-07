import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';

/// ProfileDataController - Manages user profile data
///
/// Responsibility: Manage user profile data (name, avatar, bio, stats)
class ProfileDataController extends GetxController {
  // Firebase Instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Profile Data States
  final userName = ''.obs;
  final username = ''.obs;
  final bio = ''.obs;
  final avatarId = ''.obs;
  final country = ''.obs;
  final email = ''.obs;

  // Profile Stats (read-only from gamification)
  final totalXp = 0.obs;
  final currentStreak = 0.obs;
  final lessonsCompleted = 0.obs;
  final level = 1.obs;

  // Profile Completion
  final profileCompletionPercentage = 0.obs;
  final missingFields = <String>[].obs;

  // Username Availability
  final isUsernameAvailable = true.obs;
  final isCheckingUsername = false.obs;

  // Métodos públicos

  /// Carrega o perfil do usuário atual
  Future<void> loadOwnProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      if (kDebugMode) {
        debugPrint('🔍 loadOwnProfile: Carregando perfil do usuário $userId');
      }

      // Carregar documento do usuário
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        errorMessage.value = 'Perfil não encontrado.';
        if (kDebugMode) {
          debugPrint('⚠️ loadOwnProfile: Documento do usuário não existe');
        }
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      if (kDebugMode) {
        debugPrint('✅ loadOwnProfile: Documento do usuário carregado');
      }

      // Atualizar estados observáveis
      userName.value = data['name'] ?? '';
      username.value = data['username'] ?? '';
      bio.value = data['bio'] ?? '';
      avatarId.value = data['avatarId'] ?? 'avatar_01';
      country.value = data['country'] ?? 'BR';
      email.value = data['email'] ?? '';

      if (kDebugMode) {
        debugPrint('✅ loadOwnProfile: Estados básicos atualizados');
      }

      // Carregar stats da gamificação
      await _loadProfileStats(userId);
      if (kDebugMode) {
        debugPrint('✅ loadOwnProfile: Stats carregadas');
      }

      // Calcular completude do perfil
      _calculateProfileCompletion(data);
      if (kDebugMode) {
        debugPrint('✅ loadOwnProfile: Completude calculada');
      }

      if (kDebugMode) {
        debugPrint('🎉 loadOwnProfile: Perfil carregado com sucesso');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ loadOwnProfile: FirebaseException - ${e.code}: ${e.message}',
        );
      }
      errorMessage.value = _handleFirestoreError(e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ loadOwnProfile: Erro genérico - $e');
        debugPrint('Stack trace: $stackTrace');
      }
      errorMessage.value = 'Erro ao carregar perfil. Tente novamente.';
    } finally {
      isLoading.value = false;
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

      // Atualizar estados locais IMEDIATAMENTE para UI responsiva
      if (updates.containsKey('name')) userName.value = updates['name'];
      if (updates.containsKey('username')) username.value = updates['username'];
      if (updates.containsKey('bio')) bio.value = updates['bio'];
      if (updates.containsKey('avatarId')) {
        avatarId.value = updates['avatarId'];
        // Forçar atualização da UI
        avatarId.refresh();
      }
      if (updates.containsKey('country')) country.value = updates['country'];

      // Recalcular completude (sem recarregar tudo)
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        _calculateProfileCompletion(userDoc.data() as Map<String, dynamic>);
      }

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

  // Métodos privados

  /// Carrega estatísticas de gamificação do perfil (do curso ativo)
  Future<void> _loadProfileStats(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 _loadProfileStats: Carregando stats para $userId');
      }

      // 1. Buscar curso ativo
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (coursesSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ _loadProfileStats: Nenhum curso ativo encontrado');
        }
        // Valores padrão
        totalXp.value = 0;
        level.value = 1;
        currentStreak.value = 0;
        lessonsCompleted.value = 0;
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;
      if (kDebugMode) {
        debugPrint('✅ _loadProfileStats: Curso ativo: $courseId');
      }

      // 2. Buscar stats do curso ativo (estrutura NOVA)
      final statsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .get();

      if (statsDoc.exists) {
        final stats = statsDoc.data() as Map<String, dynamic>;

        // Estrutura nova (aninhada)
        final xpData = stats['xp'] as Map<String, dynamic>?;
        final streakData = stats['streak'] as Map<String, dynamic>?;

        totalXp.value = xpData?['totalXp'] ?? 0;
        level.value = xpData?['level'] ?? 1;
        currentStreak.value = streakData?['currentStreak'] ?? 0;

        if (kDebugMode) {
          debugPrint(
            '📊 _loadProfileStats: totalXp=${totalXp.value}, level=${level.value}, streak=${currentStreak.value}',
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ _loadProfileStats: Stats doc NÃO existe');
        }
        // Valores padrão
        totalXp.value = 0;
        level.value = 1;
        currentStreak.value = 0;
      }

      // Contar lições completadas do curso ativo
      final progressSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      lessonsCompleted.value = progressSnapshot.count ?? 0;

      if (kDebugMode) {
        debugPrint(
          '✅ _loadProfileStats: Lições completadas: ${lessonsCompleted.value}',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ _loadProfileStats: Erro - $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow; // Propagar erro para ser capturado no loadOwnProfile
    }
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

  // Validadores

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

  // Error Handlers

  /// Trata erros do Firestore com mensagens amigáveis em português
  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
  }
}
