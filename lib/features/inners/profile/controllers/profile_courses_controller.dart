import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';
import '../../../../shared/utils/language_helper.dart';

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
          'languageName': LanguageHelper.getLanguageName(languageCode),
          'flag': LanguageHelper.getLanguageFlag(languageCode),
          'flagAsset': LanguageHelper.getLanguageFlag(languageCode),
          'isPrimary': courseData['isPrimary'] ?? false,
          'isActive': courseData['isActive'] ?? true,
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

  // Handlers de erro

  /// Handler de erros do Firestore
  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
  }
}
