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
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Courses States
  final userCourses = <Map<String, dynamic>>[].obs;
  final primaryCourseId = ''.obs;

  /// Constructor com DI opcional (backward compatible)
  ProfileCoursesController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadUserCourses();
  }

  @override
  void onClose() {
    // Limpar listas
    userCourses.clear();

    // Resetar estados
    isLoading.value = false;
    errorMessage.value = '';

    super.onClose();
  }

  // Métodos públicos

  /// Carrega cursos do usuário
  Future<void> loadUserCourses() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'error_unauthenticated'.tr;
        return;
      }

      // Carregar TODOS os cursos (sem filtro de isActive)
      // Isso garante que todos os cursos inicializados apareçam
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      final courses = <Map<String, dynamic>>[];

      for (final doc in coursesSnapshot.docs) {
        final courseData = doc.data();
        final languageCode = courseData['language'] as String;
        final isActive = courseData['isActive'] ?? true;

        // Apenas adicionar cursos ativos (mas buscar todos para garantir)
        if (isActive) {
          courses.add({
            'id': doc.id,
            'language': languageCode,
            'languageName': LanguageHelper.getLanguageName(languageCode),
            'flag': LanguageHelper.getLanguageFlag(languageCode),
            'flagAsset': LanguageHelper.getLanguageFlag(languageCode),
            'isPrimary': courseData['isPrimary'] ?? false,
            'isActive': isActive,
            'progress': courseData['progress'] ?? 0,
            'startedAt': courseData['startedAt'],
          });

          if (courseData['isPrimary'] == true) {
            primaryCourseId.value = doc.id;
          }
        }
      }

      userCourses.value = courses;
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'error_generic'.tr;
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
        errorMessage.value = 'error_unauthenticated'.tr;
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
          'common_success'.tr,
          'primary_course_updated'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'error_generic'.tr;
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
        errorMessage.value = 'error_unauthenticated'.tr;
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
        errorMessage.value = 'error_last_course_cannot_remove'.tr;
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
        'common_success'.tr,
        'course_removed_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'error_generic'.tr;
    } finally {
      isLoading.value = false;
    }
  }
}
