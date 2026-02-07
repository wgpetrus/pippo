import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/profile/controllers/profile_courses_controller.dart';

void main() {
  late ProfileCoursesController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    controller = ProfileCoursesController(
      firestore: firestore,
      auth: auth,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileCoursesController - loadUserCourses()', () {
    test('carrega cursos do usuário', () async {
      // Arrange - Criar cursos
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({
        'language': 'en',
        'isActive': true,
        'isPrimary': true,
        'progress': 25,
      });

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course2')
          .set({
        'language': 'es',
        'isActive': true,
        'isPrimary': false,
        'progress': 10,
      });

      // Act
      await controller.loadUserCourses();

      // Assert
      expect(controller.userCourses.length, 2);
      expect(controller.primaryCourseId.value, 'course1');
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('retorna lista vazia quando não há cursos', () async {
      // Act
      await controller.loadUserCourses();

      // Assert
      expect(controller.userCourses.length, 0);
    });
  });

  group('ProfileCoursesController - setPrimaryCourse()', () {
    test('define curso como primário', () async {
      // Arrange - Criar cursos
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({
        'language': 'en',
        'isActive': true,
        'isPrimary': true,
      });

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course2')
          .set({
        'language': 'es',
        'isActive': true,
        'isPrimary': false,
      });

      controller.userCourses.value = [
        {'id': 'course1', 'isPrimary': true},
        {'id': 'course2', 'isPrimary': false},
      ];

      // Act
      await controller.setPrimaryCourse('course2', showSnackbar: false);

      // Assert
      expect(controller.primaryCourseId.value, 'course2');
      expect(controller.isLoading.value, false);
      
      // Verificar no Firestore
      final doc1 = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .get();
      expect(doc1.data()?['isPrimary'], false);

      final doc2 = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course2')
          .get();
      expect(doc2.data()?['isPrimary'], true);
    });
  });

  group('ProfileCoursesController - removeCourse()', () {
    test('remove curso da lista', () async {
      // Arrange - Criar múltiplos cursos
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({
        'language': 'en',
        'isActive': true,
        'isPrimary': true,
      });

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course2')
          .set({
        'language': 'es',
        'isActive': true,
        'isPrimary': false,
      });

      controller.userCourses.value = [
        {'id': 'course1', 'isPrimary': true},
        {'id': 'course2', 'isPrimary': false},
      ];

      // Act
      await controller.removeCourse('course2');

      // Assert
      expect(controller.userCourses.length, 1);
      expect(controller.userCourses.first['id'], 'course1');
      
      // Verificar no Firestore
      final doc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course2')
          .get();
      expect(doc.data()?['isActive'], false);
    });

    test('não permite remover único curso', () async {
      // Arrange - Criar apenas um curso
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({
        'language': 'en',
        'isActive': true,
        'isPrimary': true,
      });

      controller.userCourses.value = [
        {'id': 'course1', 'isPrimary': true},
      ];

      // Act
      await controller.removeCourse('course1');

      // Assert
      expect(controller.errorMessage.value, contains('pelo menos um curso'));
      expect(controller.userCourses.length, 1);
    });
  });
}
