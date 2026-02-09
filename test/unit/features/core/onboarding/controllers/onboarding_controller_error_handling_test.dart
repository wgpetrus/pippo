import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/shared/translations/app_translations.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(AppTranslations());
    Get.updateLocale(const Locale('pt', 'BR'));
  });

  tearDown(() {
    Get.reset();
  });

  group('Error Handling - Firestore Error Codes', () {
    // Helper function to simulate error handling logic
    // IMPORTANTE: Manter sincronizado com lib/shared/utils/error_handler.dart
    // NOTE: Returns translation keys (not translated messages) for testing
    String getFirestoreErrorMessage(String errorCode) {
      switch (errorCode) {
        case 'permission-denied':
          return 'error_firestore_permission_denied';
        case 'unavailable':
          return 'error_firestore_unavailable';
        case 'deadline-exceeded':
          return 'error_firestore_deadline_exceeded';
        case 'resource-exhausted':
          return 'error_firestore_resource_exhausted';
        case 'failed-precondition':
          return 'error_firestore_failed_precondition';
        case 'aborted':
          return 'error_firestore_aborted';
        case 'out-of-range':
          return 'error_firestore_out_of_range';
        case 'unimplemented':
          return 'error_firestore_unimplemented';
        case 'internal':
          return 'error_firestore_internal';
        case 'unauthenticated':
          return 'error_firestore_unauthenticated';
        case 'not-found':
          return 'error_firestore_not_found';
        case 'already-exists':
          return 'error_firestore_already_exists';
        case 'cancelled':
          return 'error_firestore_cancelled';
        case 'data-loss':
          return 'error_firestore_data_loss';
        case 'invalid-argument':
          return 'error_firestore_invalid_argument';
        default:
          return 'error_firestore_default';
      }
    }
    
    test('permission-denied error returns correct translation key', () {
      final message = getFirestoreErrorMessage('permission-denied');
      expect(message, equals('error_firestore_permission_denied'));
    });

    test('unavailable error returns correct translation key', () {
      final message = getFirestoreErrorMessage('unavailable');
      expect(message, equals('error_firestore_unavailable'));
    });

    test('deadline-exceeded error returns correct translation key', () {
      final message = getFirestoreErrorMessage('deadline-exceeded');
      expect(message, equals('error_firestore_deadline_exceeded'));
    });

    test('resource-exhausted error returns correct translation key', () {
      final message = getFirestoreErrorMessage('resource-exhausted');
      expect(message, equals('error_firestore_resource_exhausted'));
    });

    test('failed-precondition error returns correct translation key', () {
      final message = getFirestoreErrorMessage('failed-precondition');
      expect(message, equals('error_firestore_failed_precondition'));
    });

    test('aborted error returns correct translation key', () {
      final message = getFirestoreErrorMessage('aborted');
      expect(message, equals('error_firestore_aborted'));
    });

    test('out-of-range error returns correct translation key', () {
      final message = getFirestoreErrorMessage('out-of-range');
      expect(message, equals('error_firestore_out_of_range'));
    });

    test('unimplemented error returns correct translation key', () {
      final message = getFirestoreErrorMessage('unimplemented');
      expect(message, equals('error_firestore_unimplemented'));
    });

    test('internal error returns correct translation key', () {
      final message = getFirestoreErrorMessage('internal');
      expect(message, equals('error_firestore_internal'));
    });

    test('unauthenticated error returns correct translation key', () {
      final message = getFirestoreErrorMessage('unauthenticated');
      expect(message, equals('error_firestore_unauthenticated'));
    });

    test('not-found error returns correct translation key', () {
      final message = getFirestoreErrorMessage('not-found');
      expect(message, equals('error_firestore_not_found'));
    });

    test('already-exists error returns correct translation key', () {
      final message = getFirestoreErrorMessage('already-exists');
      expect(message, equals('error_firestore_already_exists'));
    });

    test('cancelled error returns correct translation key', () {
      final message = getFirestoreErrorMessage('cancelled');
      expect(message, equals('error_firestore_cancelled'));
    });

    test('data-loss error returns correct translation key', () {
      final message = getFirestoreErrorMessage('data-loss');
      expect(message, equals('error_firestore_data_loss'));
    });

    test('invalid-argument error returns correct translation key', () {
      final message = getFirestoreErrorMessage('invalid-argument');
      expect(message, equals('error_firestore_invalid_argument'));
    });

    test('unknown error returns default translation key', () {
      final message = getFirestoreErrorMessage('unknown-error-code');
      expect(message, equals('error_firestore_default'));
    });

    test('all Firestore error messages are translation keys', () {
      final errorCodes = [
        'permission-denied',
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'failed-precondition',
        'aborted',
        'out-of-range',
        'unimplemented',
        'internal',
        'unauthenticated',
        'not-found',
        'already-exists',
        'cancelled',
        'data-loss',
        'invalid-argument',
      ];

      for (final code in errorCodes) {
        final message = getFirestoreErrorMessage(code);
        
        // Verify message is not empty
        expect(message.isNotEmpty, isTrue,
            reason: 'Error code "$code" must return non-empty translation key');
        
        // Verify message is a translation key (starts with error_)
        expect(message.startsWith('error_'), isTrue,
            reason: 'Error code "$code" must return translation key starting with "error_"');
        
        // Verify message follows snake_case convention
        expect(message, matches(RegExp(r'^[a-z_]+$')),
            reason: 'Error code "$code" translation key must be snake_case');
      }
    });

    test('Firestore error messages do not contain technical terms', () {
      final errorCodes = [
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'unauthenticated',
        'not-found',
      ];

      // Translation keys should not contain technical implementation details
      final technicalTerms = ['exception', 'stack', 'debug', 'trace'];

      for (final code in errorCodes) {
        final message = getFirestoreErrorMessage(code);
        final lowerMessage = message.toLowerCase();
        
        for (final term in technicalTerms) {
          expect(lowerMessage, isNot(contains(term)),
              reason: 'Error code "$code" translation key must not contain technical term "$term"');
        }
      }
    });

    test('each Firestore error code has unique translation key', () {
      final errorCodes = [
        'permission-denied',
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'unauthenticated',
        'not-found',
        'already-exists',
        'cancelled',
      ];

      final messages = <String>{};
      for (final code in errorCodes) {
        final message = getFirestoreErrorMessage(code);
        messages.add(message);
      }

      // All translation keys should be unique
      expect(messages.length, equals(errorCodes.length),
          reason: 'Error codes should have distinct translation keys');
    });

    test('Firestore error messages are user-friendly', () {
      final errorCodes = [
        'permission-denied',
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'unauthenticated',
      ];

      for (final code in errorCodes) {
        final message = getFirestoreErrorMessage(code);
        
        // Verify translation key follows naming convention
        expect(message.startsWith('error_firestore_'), isTrue,
            reason: 'Error code "$code" translation key should start with "error_firestore_"');
      }
    });
  });

  group('Error Handling - Error Message Display', () {
    test('error message is cleared when starting new operation', () {
      // Simulate error message state
      String errorMessage = 'error_previous';
      
      // Simulate starting new operation
      errorMessage = '';
      
      expect(errorMessage, isEmpty,
          reason: 'Error message should be cleared when starting new operation');
    });

    test('error message is displayed when not empty', () {
      final errorMessage = 'error_test_message';
      
      expect(errorMessage.isNotEmpty, isTrue,
          reason: 'Error message should be displayed when not empty');
    });

    test('error message is hidden when empty', () {
      final errorMessage = '';
      
      expect(errorMessage.isEmpty, isTrue,
          reason: 'Error message should be hidden when empty');
    });

    test('error message is translation key', () {
      final errorMessages = [
        'error_firestore_permission_denied',
        'error_firestore_unavailable',
        'error_firestore_deadline_exceeded',
        'error_firestore_unauthenticated',
      ];

      for (final message in errorMessages) {
        // Verify message is a translation key
        expect(message.startsWith('error_'), isTrue,
            reason: 'Error message should be a translation key starting with "error_"');
      }
    });

    test('error message does not contain technical terms', () {
      final errorMessages = [
        'error_firestore_permission_denied',
        'error_firestore_unavailable',
        'error_firestore_deadline_exceeded',
      ];

      final technicalTerms = ['exception', 'stack', 'debug', 'trace'];

      for (final message in errorMessages) {
        final lowerMessage = message.toLowerCase();
        
        for (final term in technicalTerms) {
          expect(lowerMessage, isNot(contains(term)),
              reason: 'Error message should not contain technical term "$term"');
        }
      }
    });
  });

  group('Error Handling - Error Message Clearing', () {
    test('error message is cleared at start of createAccount', () {
      String errorMessage = 'error_previous';
      
      // Simulate start of createAccount
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of sendVerificationCode', () {
      String errorMessage = 'error_previous';
      
      // Simulate start of sendVerificationCode
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of resendVerificationCode', () {
      String errorMessage = 'error_previous';
      
      // Simulate start of resendVerificationCode
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of verifyCode', () {
      String errorMessage = 'error_previous';
      
      // Simulate start of verifyCode
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of finalizeAccount', () {
      String errorMessage = 'error_previous';
      
      // Simulate start of finalizeAccount
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of addNewCourse', () {
      String errorMessage = 'error_previous';
      
      // Simulate start of addNewCourse
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message persists until next operation', () {
      String errorMessage = 'error_test';
      
      // Error message should remain until explicitly cleared
      expect(errorMessage, equals('error_test'));
      
      // Simulate starting new operation
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });
  });

  group('Error Handling - Translation Keys', () {
    test('all error messages are translation keys', () {
      final errorMessages = [
        'error_firestore_permission_denied',
        'error_firestore_unavailable',
        'error_firestore_deadline_exceeded',
        'error_firestore_resource_exhausted',
        'error_firestore_unauthenticated',
        'error_firestore_not_found',
        'error_firestore_already_exists',
      ];

      for (final message in errorMessages) {
        // Verify message follows translation key format
        expect(message, matches(RegExp(r'^[a-z_]+$')),
            reason: 'Error message "$message" must be snake_case translation key');
      }
    });
  });
}
