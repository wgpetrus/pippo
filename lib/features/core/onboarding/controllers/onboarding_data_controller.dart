// Dart SDK
import 'dart:async';
import 'dart:math';

// Flutter
import 'package:flutter/foundation.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports locais
import '../../../../shared/utils/language_helper.dart';
import '../../../../shared/utils/validation_helper.dart';

/// Controller de dados do onboarding
class OnboardingDataController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

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
  String? _tempEmail;
  String? _tempPassword;
  bool _retryCancelled = false;

  // Getters/Setters
  String? get tempPassword => _tempPassword;
  String? get tempEmail => _tempEmail;
  set tempEmail(String? value) => _tempEmail = value;

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
    _tempEmail = null;
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
          debugPrint('⚠️ Onboarding já foi completado. Pulando criação.');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isFirstAccess', false);
          isLoading.value = false;
          return;
        }
        debugPrint('📝 Documento existe mas onboarding incompleto. Atualizando...');
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
            'gems': 0,
            'totalGemsEarned': 0,
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
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Adiciona novo curso para usuário existente (modo add course)
  Future<void> addNewCourse() async {
    debugPrint('📚 addNewCourse: INICIANDO...');
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado. Faça login novamente.';
        debugPrint('  ❌ Usuário não autenticado');
        return;
      }

      final userId = user.uid;
      debugPrint('  👤 UserId: $userId');

      final studyTimeMatch = RegExp(r'(\d+)').firstMatch(studyTime.value);
      final studyTimeValue =
          studyTimeMatch != null ? int.tryParse(studyTimeMatch.group(1)!) : null;
      if (studyTimeValue == null || studyTimeValue <= 0) {
        errorMessage.value = 'Tempo de estudo inválido.';
        debugPrint('  ❌ Tempo de estudo inválido: ${studyTime.value}');
        return;
      }

      debugPrint('  📊 Dados do novo curso:');
      debugPrint('    - Idioma: ${selectedLanguage.value}');
      debugPrint('    - Nome: ${_getLanguageName(selectedLanguage.value)}');
      debugPrint('    - Nível: ${languageLevel.value}');
      debugPrint('    - Motivo: ${learningReason.value}');
      debugPrint('    - Tempo: $studyTimeValue min/dia');

      final courseRef =
          _firestore.collection('users').doc(userId).collection('courses').doc();
      final courseId = courseRef.id;
      debugPrint('  🆔 Novo courseId: $courseId');

      final batch = _firestore.batch();

      debugPrint('  🔄 Desativando curso atual...');
      final currentCoursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .get();

      if (currentCoursesSnapshot.docs.isNotEmpty) {
        for (var doc in currentCoursesSnapshot.docs) {
          batch.update(doc.reference, {'isActive': false});
          debugPrint('    📝 Marcando curso ${doc.id} para desativar');
        }
      }

      final courseData = {
        'id': courseId,
        'language': selectedLanguage.value,
        'languageName': _getLanguageName(selectedLanguage.value),
        'level': languageLevel.value,
        'reason': learningReason.value,
        'studyTime': studyTimeValue,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      debugPrint('  💾 Criando curso no Firestore...');
      debugPrint('    Path: users/$userId/courses/$courseId');
      batch.set(courseRef, courseData);

      final statsRef = courseRef.collection('stats').doc('gamification');
      debugPrint('  💾 Criando stats do novo curso...');
      debugPrint('    Path: users/$userId/courses/$courseId/stats/gamification');

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
          'gems': 0,
          'totalGemsEarned': 0,
          'totalGemsSpent': 0,
          'gemMultiplierUntil': null,
        },
        'currentLeague': 'bronze',
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      debugPrint('  🔄 Executando batch commit...');
      await batch.commit().timeout(const Duration(seconds: 30));
      debugPrint('  ✅ Curso e stats salvos com sucesso!');
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
      debugPrint('  ❌ Timeout ao salvar curso');
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      debugPrint('  ❌ FirebaseException: ${e.code} - ${e.message}');
    } catch (e) {
      errorMessage.value = 'Erro ao adicionar curso. Tente novamente.';
      debugPrint('  ❌ Erro ao adicionar curso: $e');
    } finally {
      isLoading.value = false;
      debugPrint(
          '✅ addNewCourse: CONCLUÍDO (erro: ${errorMessage.value.isEmpty ? "nenhum" : errorMessage.value})');
    }
  }

  void cancelRetry() {
    _retryCancelled = true;
    retryMessage.value = 'Operação cancelada.';
    if (kDebugMode) {
      debugPrint('🚫 Retry cancelado pelo usuário');
    }
  }

  // Métodos privados

  Future<String> _generateUniqueUsername(String name) async {
    try {
      String baseUsername = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (baseUsername.isEmpty) {
        baseUsername = 'user';
      }

      String username = baseUsername;
      int attempts = 0;
      const maxAttempts = 100;

      while (attempts < maxAttempts) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 30));

        if (querySnapshot.docs.isEmpty) {
          return username;
        }

        final random = Random().nextInt(9999) + 1;
        username = '$baseUsername$random';
        attempts++;
      }

      throw Exception('Não foi possível gerar um nome de usuário único.');
    } on TimeoutException {
      throw Exception(
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.');
    } on FirebaseException catch (e) {
      throw Exception(_handleFirestoreError(e));
    } catch (e) {
      throw Exception('Erro ao verificar nome de usuário. Tente novamente.');
    }
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
        if (kDebugMode) {
          debugPrint('🚫 Retry cancelado na tentativa $attempt');
        }
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

        if (kDebugMode) {
          debugPrint('🔄 Tentativa $attempt de $maxAttempts');
        }

        final result = await operation();
        retryAttempt.value = 0;
        retryMessage.value = '';
        _retryCancelled = false;

        if (kDebugMode && attempt > 1) {
          debugPrint('✅ Operação bem-sucedida na tentativa $attempt');
        }

        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        if (kDebugMode) {
          debugPrint('❌ Tentativa $attempt falhou: ${e.toString()}');
        }

        if (attempt < maxAttempts) {
          final delaySeconds = attempt == 1 ? 0 : pow(2, attempt - 1).toInt();

          if (delaySeconds > 0) {
            retryMessage.value =
                'Aguardando ${delaySeconds}s antes da próxima tentativa...';

            if (kDebugMode) {
              debugPrint('⏳ Aguardando ${delaySeconds}s antes da próxima tentativa...');
            }

            for (int i = 0; i < delaySeconds * 10; i++) {
              if (_retryCancelled) {
                if (kDebugMode) {
                  debugPrint('🚫 Retry cancelado durante aguardo');
                }
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

    if (kDebugMode) {
      debugPrint('💥 Todas as $maxAttempts tentativas falharam');
    }

    throw lastException!;
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
        return 'Valor fora do intervalo permitido.';
      case 'unimplemented':
        return 'Operação não implementada.';
      case 'internal':
        return 'Erro interno do servidor. Tente novamente em alguns instantes.';
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'not-found':
        return 'Recurso não encontrado.';
      case 'already-exists':
        return 'Recurso já existe.';
      case 'cancelled':
        return 'Operação cancelada.';
      case 'data-loss':
        return 'Erro de integridade de dados.';
      case 'invalid-argument':
        return 'Argumento inválido.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }
}
