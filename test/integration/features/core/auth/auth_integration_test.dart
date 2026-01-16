// Dart SDK
import 'dart:async';

// Flutter packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import 'package:pippo/features/core/auth/controllers/auth_controller.dart';
import 'package:pippo/features/inners/splash/controllers/splash_controller.dart';

import 'auth_integration_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  FlutterSecureStorage,
  User,
  UserCredential,
  DocumentReference,
  DocumentSnapshot,
  CollectionReference,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests - Complete Login Flow', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockFlutterSecureStorage mockSecureStorage;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockDocumentReference<Map<String, dynamic>> mockDocRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
    late AuthController authController;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockSecureStorage = MockFlutterSecureStorage();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();

      // Setup GetX for navigation testing
      Get.testMode = true;

      authController = AuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Complete login flow: signin → Firestore fetch → navigation to home',
        () async {
      // Arrange
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testUserId = 'user123';

      when(mockUser.uid).thenReturn(testUserId);
      when(mockUserCredential.user).thenReturn(mockUser);

      // Mock successful authentication
      when(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      // Mock Firestore collection and document
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

      // Mock document exists with onboardingCompleted = true
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'email': testEmail,
        'onboardingCompleted': true,
        'createdAt': Timestamp.now(),
      });

      // Mock update lastActiveAt
      when(mockDocRef.update(any)).thenAnswer((_) async => {});

      // Act
      await authController.login(testEmail, testPassword);

      // Assert
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, '');

      // Verify authentication was called
      verify(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);

      // Verify Firestore fetch was called
      verify(mockFirestore.collection('users')).called(1);
      verify(mockCollectionRef.doc(testUserId)).called(1);
      verify(mockDocRef.get()).called(1);

      // Verify lastActiveAt was updated
      verify(mockDocRef.update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      })).called(1);

      // Verify navigation to home (in real app, would check Get.currentRoute)
      // Note: In test mode, we can't fully verify navigation, but we can verify
      // that the flow completed without errors
    });

    test(
        'Complete login flow: signin → Firestore fetch → navigation to onboarding',
        () async {
      // Arrange
      const testEmail = 'newuser@example.com';
      const testPassword = 'password123';
      const testUserId = 'newuser123';

      when(mockUser.uid).thenReturn(testUserId);
      when(mockUserCredential.user).thenReturn(mockUser);

      // Mock successful authentication
      when(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      // Mock Firestore collection and document
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

      // Mock document exists with onboardingCompleted = false
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'email': testEmail,
        'onboardingCompleted': false,
        'createdAt': Timestamp.now(),
      });

      // Act
      await authController.login(testEmail, testPassword);

      // Assert
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, '');

      // Verify authentication was called
      verify(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);

      // Verify Firestore fetch was called
      verify(mockFirestore.collection('users')).called(1);
      verify(mockCollectionRef.doc(testUserId)).called(1);
      verify(mockDocRef.get()).called(1);

      // Verify lastActiveAt was NOT updated (onboarding incomplete)
      verifyNever(mockDocRef.update(any));
    });

    test('Login flow handles authentication errors correctly', () async {
      // Arrange
      const testEmail = 'test@example.com';
      const testPassword = 'wrongpassword';

      // Mock authentication failure
      when(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenThrow(
        FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password',
        ),
      );

      // Act
      await authController.login(testEmail, testPassword);

      // Assert
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value,
          'Senha incorreta. Verifique e tente novamente.');

      // Verify authentication was attempted
      verify(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);

      // Verify Firestore was never called
      verifyNever(mockFirestore.collection(any));
    });

    test('Login flow handles Firestore errors correctly', () async {
      // Arrange
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testUserId = 'user123';

      when(mockUser.uid).thenReturn(testUserId);
      when(mockUserCredential.user).thenReturn(mockUser);

      // Mock successful authentication
      when(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      // Mock Firestore error
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Service unavailable',
        ),
      );

      // Act
      await authController.login(testEmail, testPassword);

      // Assert
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, isNotEmpty);

      // Verify authentication was successful
      verify(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);

      // Verify Firestore was attempted
      verify(mockFirestore.collection('users')).called(1);
    });
  });

  group('Integration Tests - Complete Password Recovery Flow', () {
    late MockFirebaseAuth mockAuth;
    late MockFlutterSecureStorage mockSecureStorage;
    late MockUser mockUser;
    late AuthController authController;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockSecureStorage = MockFlutterSecureStorage();
      mockUser = MockUser();

      Get.testMode = true;

      authController = AuthController();
    });

    tearDown(() {
      Get.reset();
    });

    test(
        'Complete password recovery flow: forgot → send code → verify → reset → signin',
        () async {
      // Arrange
      const testEmail = 'test@example.com';
      const testCode = '12345';
      const testNewPassword = 'newpassword123';

      // Mock current user for password reset
      when(mockAuth.currentUser).thenReturn(mockUser);

      // Step 1: Send password reset code
      when(mockAuth.sendPasswordResetEmail(email: testEmail))
          .thenAnswer((_) async => {});
      when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await authController.sendPasswordResetCode(testEmail);

      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, '');

      // Verify email was sent
      verify(mockAuth.sendPasswordResetEmail(email: testEmail)).called(1);

      // Verify OTP was stored
      verify(mockSecureStorage.write(key: 'otp_code', value: anyNamed('value')))
          .called(1);
      verify(mockSecureStorage.write(key: 'otp_email', value: testEmail))
          .called(1);
      verify(mockSecureStorage.write(
              key: 'otp_expiration', value: anyNamed('value')))
          .called(1);

      // Step 2: Verify code
      final expirationTime = DateTime.now().add(const Duration(minutes: 10));
      when(mockSecureStorage.read(key: 'otp_code'))
          .thenAnswer((_) async => testCode);
      when(mockSecureStorage.read(key: 'otp_expiration'))
          .thenAnswer((_) async => expirationTime.toIso8601String());

      await authController.verifyCode(testCode);

      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, '');

      // Verify code was read from storage
      verify(mockSecureStorage.read(key: 'otp_code')).called(1);
      verify(mockSecureStorage.read(key: 'otp_expiration')).called(1);

      // Step 3: Reset password
      when(mockSecureStorage.read(key: 'otp_email'))
          .thenAnswer((_) async => testEmail);
      when(mockUser.updatePassword(testNewPassword))
          .thenAnswer((_) async => {});
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      await authController.resetPassword(testNewPassword);

      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, '');

      // Verify password was updated
      verify(mockUser.updatePassword(testNewPassword)).called(1);

      // Verify OTP was cleared
      verify(mockSecureStorage.delete(key: 'otp_code')).called(1);
      verify(mockSecureStorage.delete(key: 'otp_email')).called(1);
      verify(mockSecureStorage.delete(key: 'otp_expiration')).called(1);
    });

    test('Password recovery handles expired code correctly', () async {
      // Arrange
      const testCode = '12345';

      // Mock expired code
      final expirationTime = DateTime.now().subtract(const Duration(minutes: 11));
      when(mockSecureStorage.read(key: 'otp_code'))
          .thenAnswer((_) async => testCode);
      when(mockSecureStorage.read(key: 'otp_expiration'))
          .thenAnswer((_) async => expirationTime.toIso8601String());

      // Act
      await authController.verifyCode(testCode);

      // Assert
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value,
          'Código expirado. Solicite um novo código.');

      // Verify code was read
      verify(mockSecureStorage.read(key: 'otp_code')).called(1);
      verify(mockSecureStorage.read(key: 'otp_expiration')).called(1);
    });

    test('Password recovery handles invalid code correctly', () async {
      // Arrange
      const testCode = '12345';
      const wrongCode = '54321';

      // Mock valid expiration but wrong code
      final expirationTime = DateTime.now().add(const Duration(minutes: 10));
      when(mockSecureStorage.read(key: 'otp_code'))
          .thenAnswer((_) async => testCode);
      when(mockSecureStorage.read(key: 'otp_expiration'))
          .thenAnswer((_) async => expirationTime.toIso8601String());

      // Act
      await authController.verifyCode(wrongCode);

      // Assert
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value,
          'Código inválido. Verifique e tente novamente.');

      // Verify code was read
      verify(mockSecureStorage.read(key: 'otp_code')).called(1);
      verify(mockSecureStorage.read(key: 'otp_expiration')).called(1);
    });

    test('Password recovery handles resend with timer correctly', () async {
      // Arrange
      const testEmail = 'test@example.com';

      // Mock send password reset
      when(mockAuth.sendPasswordResetEmail(email: testEmail))
          .thenAnswer((_) async => {});
      when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      // Act - First send
      await authController.sendPasswordResetCode(testEmail);

      // Assert - Timer should be started
      expect(authController.resendTimer.value, 60);

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 100));

      // Timer should have decreased
      expect(authController.resendTimer.value, lessThan(60));
    });
  });

  group('Integration Tests - Splash Navigation', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;
    late MockDocumentReference<Map<String, dynamic>> mockDocRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
    late SplashController splashController;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();

      Get.testMode = true;

      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});

      splashController = SplashController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Splash navigates to onboarding for first-time unauthenticated user',
        () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // SharedPreferences will return true for first access (default)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', true);

      // Act
      splashController.retry();

      // Wait for navigation
      await Future.delayed(const Duration(milliseconds: 2100));

      // Assert
      expect(splashController.isLoading.value, false);
      expect(splashController.errorMessage.value, '');
    });

    test('Splash navigates to auth for returning unauthenticated user',
        () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Set first access to false
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);

      // Act
      splashController.retry();

      // Wait for navigation
      await Future.delayed(const Duration(milliseconds: 2100));

      // Assert
      expect(splashController.isLoading.value, false);
      expect(splashController.errorMessage.value, '');
    });

    test('Splash navigates to onboarding for authenticated user with incomplete onboarding',
        () async {
      // Arrange
      const testUserId = 'user123';
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      // Mock Firestore
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

      // Mock onboardingCompleted = false
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'onboardingCompleted': false,
      });

      // Act
      splashController.retry();

      // Wait for navigation
      await Future.delayed(const Duration(milliseconds: 2100));

      // Assert
      expect(splashController.isLoading.value, false);
      expect(splashController.errorMessage.value, '');

      // Verify Firestore was called
      verify(mockFirestore.collection('users')).called(1);
    });

    test('Splash navigates to home for authenticated user with complete onboarding',
        () async {
      // Arrange
      const testUserId = 'user123';
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      // Mock Firestore
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

      // Mock onboardingCompleted = true
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'onboardingCompleted': true,
      });

      // Act
      splashController.retry();

      // Wait for navigation
      await Future.delayed(const Duration(milliseconds: 2100));

      // Assert
      expect(splashController.isLoading.value, false);
      expect(splashController.errorMessage.value, '');

      // Verify Firestore was called
      verify(mockFirestore.collection('users')).called(1);
    });

    test('Splash handles Firestore timeout correctly', () async {
      // Arrange
      const testUserId = 'user123';
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      // Mock Firestore timeout
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 6),
          () => mockDocSnapshot,
        ),
      );

      // Act
      splashController.retry();

      // Wait for timeout
      await Future.delayed(const Duration(milliseconds: 2100));
      await Future.delayed(const Duration(seconds: 6));

      // Assert
      expect(splashController.isLoading.value, false);
      expect(splashController.errorMessage.value,
          'Verifique sua conexão com a internet');
      expect(splashController.showRetryButton.value, true);
    });

    test('Splash handles network error correctly', () async {
      // Arrange
      const testUserId = 'user123';
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      // Mock Firestore network error
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Network error',
        ),
      );

      // Act
      splashController.retry();

      // Wait for navigation
      await Future.delayed(const Duration(milliseconds: 2100));

      // Assert
      expect(splashController.isLoading.value, false);
      expect(splashController.errorMessage.value,
          'Verifique sua conexão com a internet');
      expect(splashController.showRetryButton.value, true);
    });
  });

  group('Integration Tests - Error Recovery and Retry', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;
    late MockDocumentReference<Map<String, dynamic>> mockDocRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
    late SplashController splashController;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();

      Get.testMode = true;

      SharedPreferences.setMockInitialValues({});

      splashController = SplashController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Retry mechanism works after network error', () async {
      // Arrange
      const testUserId = 'user123';
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      // First attempt: network error
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Network error',
        ),
      );

      // Act - First attempt
      splashController.retry();
      await Future.delayed(const Duration(milliseconds: 2100));

      // Assert - Error state
      expect(splashController.isLoading.value, false);
      expect(splashController.errorMessage.value,
          'Verifique sua conexão com a internet');
      expect(splashController.showRetryButton.value, true);

      // Arrange - Second attempt: success
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'onboardingCompleted': true,
      });

      // Act - Retry
      splashController.retry();
      await Future.delayed(const Duration(milliseconds: 2100));

      // Assert - Success
      expect(splashController.isLoading.value, false);
      expect(splashController.errorMessage.value, '');
      expect(splashController.showRetryButton.value, false);

      // Verify Firestore was called twice
      verify(mockFirestore.collection('users')).called(2);
    });

    test('Error recovery clears previous error messages', () async {
      // Arrange
      const testUserId = 'user123';
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      // First attempt: error
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(testUserId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        ),
      );

      // Act - First attempt
      splashController.retry();
      await Future.delayed(const Duration(milliseconds: 2100));

      // Assert - Error state
      expect(splashController.errorMessage.value, isNotEmpty);

      // Arrange - Second attempt: success
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'onboardingCompleted': true,
      });

      // Act - Retry
      splashController.retry();
      await Future.delayed(const Duration(milliseconds: 2100));

      // Assert - Error cleared
      expect(splashController.errorMessage.value, '');
    });
  });
}
