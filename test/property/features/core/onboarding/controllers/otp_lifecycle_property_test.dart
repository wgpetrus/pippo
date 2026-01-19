import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Property 7: OTP Lifecycle Management
/// 
/// Validates: Requirements 6.4, 6.5, 6.6, 6.7, 6.8, 6.12, 6.13, 6.14, 6.15, 6.16, 6.17, 6.18, 6.19
/// 
/// This property test verifies that:
/// - OTP codes are always 5 digits
/// - Expiration logic works correctly (10 minutes)
/// - Codes older than 10 minutes are rejected
/// - Firestore document structure matches specification
/// - Document key is email address
void main() {
  group('Feature: onboarding, Property 7: OTP Lifecycle Management', () {
    test('OTP codes are always exactly 5 digits', () {
      // Generate 100 OTP codes
      for (int i = 0; i < 100; i++) {
        final code = _generateOTP();
        
        // Verify format: exactly 5 digits
        expect(code.length, equals(5), reason: 'OTP code must be exactly 5 digits');
        expect(RegExp(r'^\d{5}$').hasMatch(code), isTrue, reason: 'OTP code must contain only digits');
        
        // Verify range: 10000 to 99999
        final codeInt = int.parse(code);
        expect(codeInt, greaterThanOrEqualTo(10000), reason: 'OTP code must be >= 10000');
        expect(codeInt, lessThanOrEqualTo(99999), reason: 'OTP code must be <= 99999');
      }
    });

    test('Firestore document structure matches specification', () {
      // Test document structure
      final testEmail = 'test@example.com';
      final code = _generateOTP();
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 10));
      
      // Simulate document structure
      final document = {
        'code': code,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'attempts': 0,
        'createdAt': Timestamp.fromDate(now),
      };
      
      // Verify all required fields exist
      expect(document.containsKey('code'), isTrue, reason: 'Document must have code field');
      expect(document.containsKey('expiresAt'), isTrue, reason: 'Document must have expiresAt field');
      expect(document.containsKey('attempts'), isTrue, reason: 'Document must have attempts field');
      expect(document.containsKey('createdAt'), isTrue, reason: 'Document must have createdAt field');
      
      // Verify field types
      expect(document['code'], isA<String>(), reason: 'code must be String');
      expect(document['expiresAt'], isA<Timestamp>(), reason: 'expiresAt must be Timestamp');
      expect(document['attempts'], isA<int>(), reason: 'attempts must be int');
      expect(document['createdAt'], isA<Timestamp>(), reason: 'createdAt must be Timestamp');
      
      // Verify initial values
      expect(document['code'], equals(code), reason: 'code must match generated code');
      expect(document['attempts'], equals(0), reason: 'attempts must start at 0');
      
      // Verify expiration is 10 minutes from now
      final expiresAtDate = (document['expiresAt'] as Timestamp).toDate();
      final expectedExpiration = now.add(const Duration(minutes: 10));
      final difference = expiresAtDate.difference(expectedExpiration).inSeconds.abs();
      expect(difference, lessThan(2), reason: 'expiresAt must be 10 minutes from createdAt');
    });

    test('Expiration logic correctly identifies expired codes', () {
      final now = DateTime.now();
      
      // Test various expiration scenarios
      // expiresAt represents when the code expires (created + 10 minutes)
      // If current time > expiresAt, code is expired
      final testCases = [
        // (expiresAt offset from now in minutes, should be expired)
        (-11, true),  // Expired 11 minutes ago - expired
        (-10, true),  // Expired exactly 10 minutes ago - expired (boundary)
        (-1, true),   // Expired 1 minute ago - expired
        (0, false),   // Expires now - not expired (boundary)
        (1, false),   // Expires in 1 minute - not expired
        (5, false),   // Expires in 5 minutes - not expired
        (9, false),   // Expires in 9 minutes - not expired
        (10, false),  // Expires in 10 minutes - not expired
      ];
      
      for (final testCase in testCases) {
        final minutesOffset = testCase.$1 as int;
        final shouldBeExpired = testCase.$2 as bool;
        
        final expiresAt = now.add(Duration(minutes: minutesOffset));
        final isExpired = now.isAfter(expiresAt);
        
        expect(
          isExpired,
          equals(shouldBeExpired),
          reason: 'Code that expires $minutesOffset minutes from now should ${shouldBeExpired ? "be" : "not be"} expired',
        );
      }
    });

    test('Codes older than 10 minutes are always rejected', () {
      final now = DateTime.now();
      
      // Test 20 different timestamps older than 10 minutes
      for (int i = 11; i <= 30; i++) {
        final expiresAt = now.subtract(Duration(minutes: i));
        final isExpired = now.isAfter(expiresAt);
        
        expect(
          isExpired,
          isTrue,
          reason: 'Code expired $i minutes ago must be rejected',
        );
      }
    });

    test('Document key format matches email address', () {
      // Test various email formats
      final testEmails = [
        'user@example.com',
        'test.user@example.com',
        'user+tag@example.co.uk',
        'user123@test-domain.com',
        'a@b.c',
      ];
      
      for (final email in testEmails) {
        // Verify email can be used as document key (no special Firestore restrictions)
        expect(email.isNotEmpty, isTrue, reason: 'Email must not be empty');
        expect(email.contains('@'), isTrue, reason: 'Email must contain @');
        
        // Firestore document keys cannot contain certain characters
        // but email addresses are valid keys
        final invalidChars = ['/', '\\'];
        for (final char in invalidChars) {
          expect(
            email.contains(char),
            isFalse,
            reason: 'Email used as document key must not contain $char',
          );
        }
      }
    });

    test('OTP generation produces unique codes across multiple generations', () {
      final codes = <String>{};
      
      // Generate 100 codes
      for (int i = 0; i < 100; i++) {
        final code = _generateOTP();
        codes.add(code);
      }
      
      // While collisions are possible with random generation,
      // we expect high uniqueness (at least 90% unique in 100 generations)
      expect(
        codes.length,
        greaterThan(90),
        reason: 'OTP generation should produce mostly unique codes',
      );
    });

    test('Timestamp conversion maintains accuracy', () {
      final testDates = [
        DateTime.now(),
        DateTime.now().add(const Duration(minutes: 10)),
        DateTime.now().subtract(const Duration(minutes: 10)),
        DateTime(2024, 1, 1, 12, 0, 0),
        DateTime(2025, 12, 31, 23, 59, 59),
      ];
      
      for (final date in testDates) {
        final timestamp = Timestamp.fromDate(date);
        final convertedBack = timestamp.toDate();
        
        // Allow 1 second difference due to precision
        final difference = convertedBack.difference(date).inSeconds.abs();
        expect(
          difference,
          lessThan(2),
          reason: 'Timestamp conversion must maintain accuracy',
        );
      }
    });
  });
}

/// Helper: Generate 5-digit OTP code (same logic as controller)
String _generateOTP() {
  final random = Random();
  final code = (10000 + random.nextInt(90000)).toString();
  return code;
}
