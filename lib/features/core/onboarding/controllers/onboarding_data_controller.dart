// Dart SDK
import 'dart:async';
import 'dart:math';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports locais
import '../../../../shared/utils/language_helper.dart';
import '../../../../shared/utils/error_handler.dart';
import '../../../../shared/utils/validation_helper.dart';

/// Controller de dados do onboarding
class OnboardingDataController extends GetxController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Constructor com DI
  OnboardingDataController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados adicionais
  final isAddingCourse = false.obs;
  final skipWelcome = false.obs;
  final authProvider = ''.obs;
  final showLoginOption = false.obs;
  final retryAttempt = 0.obs;
  final retryMessage = ''.obs;

  // Dados do onboarding
  final selectedLanguage = ''.obs;
  final languageLevel = ''.obs;
  final learningReason = ''.obs;
  final studyTime = ''.obs;
  final userName = ''.obs;
  final userAge = ''.obs;
  final userEmail = ''.obs;

  // Estado privado
  String? tempEmail;
  String? _tempPassword;
  bool _retryCancelled = false;

  String? get tempPassword => _tempPassword;

  // Lifecycle

  @override
  void onClose() {
    // Resetar estados
    isLoading.value = false;
    errorMessage.value = '';
    isAddingCourse.value = false;
    skipWelcome.value = false;
    authProvider.value = '';
    showLoginOption.value = false;
    retryAttempt.value = 0;
    retryMessage.value = '';
    selectedLanguage.value = '';
    languageLevel.value = '';
    learningReason.value = '';
    studyTime.value = '';
    userName.value = '';
    userAge.value = '';
    userEmail.value = '';

    super.onClose();
  }

  // Setters
  void setLanguage(String language) => selectedLanguage.value = language;
  void setLanguageLevel(String level) => languageLevel.value = level;
  void setLearningReason(String reason) => learningReason.value = reason;
  void setStudyTime(String time) => studyTime.value = time;
  void setUserName(String name) => userName.value = name;
  void setUserAge(String age) => userAge.value = age;
  void setUserEmail(String email) => userEmail.value = email;
  void setUserPassword(String password) => _tempPassword = password;

  void clearAllData() {
    tempEmail = null;
    _tempPassword = null;
    errorMessage.value = '';
    showLoginOption.value = false;
    retryMessage.value = '';
    retryAttempt.value = 0;
    selectedLanguage.value = '';
    languageLevel.value = '';
    learningReason.value = '';
    studyTime.value = '';
    userName.value = '';
    userAge.value = '';
    userEmail.value = '';
  }

  // Métodos públicos

  /// Finaliza a criação da conta (cria documentos no Firestore)
  Future<void> finalizeAccount() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      userName.value = ValidationHelper.sanitizeName(userName.value);
      if (authProvider.value != 'google') {
        userEmail.value = ValidationHelper.sanitizeEmail(userEmail.value);
      }

      final nameError = _validateName(userName.value);
      if (nameError != null) {
        errorMessage.value = nameError;
        return;
      }

      if (authProvider.value != 'google') {
        final emailError = _validateEmail(userEmail.value);
        if (emailError != null) {
          errorMessage.value = emailError;
          return;
        }
      }

      if (selectedLanguage.value.isEmpty) {
        errorMessage.value = 'Selecione um idioma.';
        return;
      }
      if (languageLevel.value.isEmpty) {
        errorMessage.value = 'Selecione um nível.';
        return;
      }
      if (learningReason.value.isEmpty) {
        errorMessage.value = 'Selecione o motivo de aprendizado.';
        return;
      }
      if (studyTime.value.isEmpty) {
        errorMessage.value = 'Selecione o tempo de estudo.';
        return;
      }

      final studyTimeMatch = RegExp(r'(\d+)').firstMatch(studyTime.value);
      final studyTimeValue =
          studyTimeMatch != null ? int.tryParse(studyTimeMatch.group(1)!) : null;
      if (studyTimeValue == null || studyTimeValue <= 0) {
        errorMessage.value = 'Tempo de estudo inválido.';
        return;
      }

      if (authProvider.value != 'google') {
        if (userName.value.isEmpty) {
          errorMessage.value = 'Digite seu nome.';
          return;
        }
        if (userAge.value.isEmpty) {
          errorMessage.value = 'Selecione sua idade.';
          return;
        }
      }

      final userDocSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDocSnapshot.exists) {
        final existingData = userDocSnapshot.data()!;
        final alreadyCompleted = existingData['onboardingCompleted'] ?? false;

        if (alreadyCompleted) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isFirstAccess', false);
          isLoading.value = false;
          return;
        }
      }

      final username = await _generateUniqueUsername(userName.value);

      await retryWithBackoff(() async {
        final batch = _firestore.batch();
        final userRef = _firestore.collection('users').doc(user.uid);

        if (userDocSnapshot.exists) {
          batch.update(userRef, {
            'name': userName.value,
            'searchName': userName.value.toLowerCase(),
            'username': username,
            'age': userAge.value,
            'onboardingCompleted': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          batch.set(userRef, {
            'id': user.uid,
            'email': userEmail.value,
            'name': userName.value,
            'searchName': userName.value.toLowerCase(),
            'username': username,
            'age': userAge.value,
            'authProvider': authProvider.value.isEmpty ? 'email' : authProvider.value,
            'onboardingCompleted': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        final courseRef = userRef.collection('courses').doc();
        batch.set(courseRef, {
          'id': courseRef.id,
          'language': selectedLanguage.value,
          'languageName': _getLanguageName(selectedLanguage.value),
          'level': languageLevel.value,
          'reason': learningReason.value,
          'studyTime': studyTimeValue,
          'isActive': true,
          'isPrimary': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final statsRef = courseRef.collection('stats').doc('gamification');
        batch.set(statsRef, {
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
            'weeklyXP': 0,
            'todayXp': 0,
            'level': 1,
            'xpToNextLevel': 100,
            'xpBoosterUntil': null,
            'lastWeeklyResetDate': '',
            'lastDailyResetDate': '',
          },
          'gems': {
            'gems': 100, // Recompensa de boas-vindas no primeiro curso
            'totalGemsEarned': 100,
            'totalGemsSpent': 0,
            'gemMultiplierUntil': null,
          },
          'currentLeague': 'bronze',
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        await batch.commit().timeout(const Duration(seconds: 30));
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Adiciona novo curso para usuário existente (modo add course)
  Future<void> addNewCourse() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        return;
      }

      final userId = user.uid;

      final studyTimeMatch = RegExp(r'(\d+)').firstMatch(studyTime.value);
      final studyTimeValue =
          studyTimeMatch != null ? int.tryParse(studyTimeMatch.group(1)!) : null;
      if (studyTimeValue == null || studyTimeValue <= 0) {
        errorMessage.value = 'Tempo de estudo inválido.';
        return;
      }

      final courseRef =
          _firestore.collection('users').doc(userId).collection('courses').doc();
      final courseId = courseRef.id;

      final batch = _firestore.batch();

      final currentCoursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .get();

      if (currentCoursesSnapshot.docs.isNotEmpty) {
        for (var doc in currentCoursesSnapshot.docs) {
          batch.update(doc.reference, {'isActive': false});
        }
      }

      final existingPrimarySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isPrimary', isEqualTo: true)
          .limit(1)
          .get();

      final shouldSetAsPrimary = existingPrimarySnapshot.docs.isEmpty;

      final courseData = {
        'id': courseId,
        'language': selectedLanguage.value,
        'languageName': _getLanguageName(selectedLanguage.value),
        'level': languageLevel.value,
        'reason': learningReason.value,
        'studyTime': studyTimeValue,
        'isActive': true,
        'isPrimary': shouldSetAsPrimary,
        'createdAt': FieldValue.serverTimestamp(),
      };

      batch.set(courseRef, courseData);

      final statsRef = courseRef.collection('stats').doc('gamification');

      // Verificar se é o primeiro curso do usuário para conceder recompensa
      // IMPORTANTE: Verificar ANTES de adicionar o novo curso ao batch
      final allCoursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();
      
      // Se não há cursos ainda, este será o primeiro (recompensa de 100 gems)
      final isFirstCourse = allCoursesSnapshot.docs.isEmpty;
      final initialGems = isFirstCourse ? 100 : 0;
      final initialGemsEarned = isFirstCourse ? 100 : 0;

      batch.set(statsRef, {
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
          'weeklyXP': 0,
          'todayXp': 0,
          'level': 1,
          'xpToNextLevel': 100,
          'xpBoosterUntil': null,
          'lastWeeklyResetDate': '',
          'lastDailyResetDate': '',
        },
        'gems': {
          'gems': initialGems,
          'totalGemsEarned': initialGemsEarned,
          'totalGemsSpent': 0,
          'gemMultiplierUntil': null,
        },
        'currentLeague': 'bronze',
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await batch.commit().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'Erro ao adicionar curso. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  void cancelRetry() {
    _retryCancelled = true;
    retryMessage.value = 'Operação cancelada.';
  }

  Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
  }) async {
    int attempt = 0;
    Exception? lastException;
    _retryCancelled = false;

    while (attempt < maxAttempts) {
      if (_retryCancelled) {
        retryAttempt.value = 0;
        retryMessage.value = '';
        throw Exception('Operação cancelada pelo usuário.');
      }

      try {
        attempt++;
        retryAttempt.value = attempt;
        if (attempt > 1) {
          retryMessage.value = 'Tentativa $attempt de $maxAttempts...';
        }

        final result = await operation();
        retryAttempt.value = 0;
        retryMessage.value = '';
        _retryCancelled = false;

        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        if (attempt < maxAttempts) {
          final delaySeconds = attempt == 1 ? 0 : pow(2, attempt - 1).toInt();

          if (delaySeconds > 0) {
            retryMessage.value =
                'Aguardando ${delaySeconds}s antes da próxima tentativa...';

            for (int i = 0; i < delaySeconds * 10; i++) {
              if (_retryCancelled) {
                retryAttempt.value = 0;
                retryMessage.value = '';
                throw Exception('Operação cancelada pelo usuário.');
              }
              await Future.delayed(const Duration(milliseconds: 100));
            }
          }
        }
      }
    }

    retryAttempt.value = 0;
    retryMessage.value = '';
    _retryCancelled = false;

    throw lastException ?? Exception('Erro desconhecido');
  }

  Future<String> _generateUniqueUsername(String name) async {
    final base = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');

    final normalizedBase = base.isEmpty ? 'user' : base;

    Future<bool> isTaken(String username) async {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 30));
      return snapshot.docs.isNotEmpty;
    }

    var candidate = normalizedBase;
    if (!await isTaken(candidate)) return candidate;

    for (var i = 0; i < 50; i++) {
      final suffix = (100 + Random().nextInt(900)).toString();
      candidate = '$normalizedBase$suffix';
      if (!await isTaken(candidate)) return candidate;
    }

    final fallbackSuffix = DateTime.now().millisecondsSinceEpoch.toString();
    return '$normalizedBase$fallbackSuffix';
  }

  String _getLanguageName(String code) {
    return LanguageHelper.getLanguageName(code);
  }
  String? _validateName(String? value) {
    return ValidationHelper.validateName(value);
  }

  String? _validateEmail(String? value) {
    return ValidationHelper.validateEmail(value);
  }
}
