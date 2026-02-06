import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/app_assets.dart';

/// ProfileCoursesController - Manages user courses
///
/// Responsibility: Manage user courses (add, remove, set primary)
class ProfileCoursesController extends GetxController {
  // Firebase Instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Courses States
  final userCourses = <Map<String, dynamic>>[].obs;
  final primaryCourseId = ''.obs;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadUserCourses();
  }

  // Métodos públicos

  /// Carrega cursos do usuário
  Future<void> loadUserCourses() async {
    isLoading.value = true;
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

      final courses = <Map<String, dynamic>>[];

      for (final doc in coursesSnapshot.docs) {
        final courseData = doc.data();
        final languageCode = courseData['language'] as String;

        courses.add({
          'id': doc.id,
          'language': languageCode,
          'languageName': _getLanguageName(languageCode),
          'flag': _getLanguageFlag(languageCode),
          'isPrimary': courseData['isPrimary'] ?? false,
          'progress': courseData['progress'] ?? 0,
          'startedAt': courseData['startedAt'],
        });

        if (courseData['isPrimary'] == true) {
          primaryCourseId.value = doc.id;
        }
      }

      userCourses.value = courses;
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar cursos. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Define curso primário
  Future<void> setPrimaryCourse(
    String courseId, {
    bool showSnackbar = true,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final batch = _firestore.batch();

      // Remover isPrimary de todos os cursos
      for (final course in userCourses) {
        final courseRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(course['id'] as String);

        batch.update(courseRef, {'isPrimary': false});
      }

      // Definir novo curso primário
      final newPrimaryRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId);

      batch.update(newPrimaryRef, {'isPrimary': true});

      await batch.commit();

      // Atualizar estado local
      primaryCourseId.value = courseId;

      // Atualizar lista de cursos
      for (var i = 0; i < userCourses.length; i++) {
        userCourses[i]['isPrimary'] = userCourses[i]['id'] == courseId;
      }
      userCourses.refresh();

      if (showSnackbar) {
        Get.snackbar(
          'Sucesso',
          'Curso primário atualizado!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao definir curso primário. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove curso
  Future<void> removeCourse(String courseId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Verificar se é o curso primário
      final courseToRemove = userCourses.firstWhere(
        (course) => course['id'] == courseId,
        orElse: () => <String, dynamic>{},
      );

      if (courseToRemove.isEmpty) {
        errorMessage.value = 'Curso não encontrado.';
        return;
      }

      final isPrimary = courseToRemove['isPrimary'] == true;

      // Não permitir remover se for o único curso
      if (userCourses.length == 1) {
        errorMessage.value = 'Você precisa ter pelo menos um curso ativo.';
        return;
      }

      // Marcar curso como inativo
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .update({'isActive': false});

      // Se era o curso primário, definir outro como primário
      if (isPrimary && userCourses.length > 1) {
        final newPrimaryCourse = userCourses.firstWhere(
          (course) => course['id'] != courseId,
        );
        await setPrimaryCourse(
          newPrimaryCourse['id'] as String,
          showSnackbar: false,
        );
      }

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

  // Métodos privados

  /// Retorna nome do idioma
  String _getLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'pt':
        return 'Portuguese';
      case 'zh':
        return 'Chinese';
      case 'ja':
        return 'Japanese';
      case 'ar':
        return 'Arabic';
      default:
        return 'Unknown';
    }
  }

  /// Retorna bandeira do idioma
  String _getLanguageFlag(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return AppAssets.usaFlag;
      case 'es':
        return AppAssets.spanishFlag;
      case 'fr':
        return AppAssets.frenchFlag;
      case 'de':
        return AppAssets.germanyFlag;
      case 'pt':
        return AppAssets.brazilFlag;
      case 'zh':
        return AppAssets.chinaFlag;
      case 'ja':
        return AppAssets.japanFlag;
      case 'ar':
        return AppAssets.sauditFlag;
      default:
        return AppAssets.usaFlag;
    }
  }

  // Handlers de erro

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
