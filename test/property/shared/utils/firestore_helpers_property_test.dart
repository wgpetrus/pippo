import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glados/glados.dart';
import 'package:pippo/shared/utils/firestore_helpers.dart';

void main() {
  group('Feature: lesson-system, Firestore Helpers Property Tests', () {
    // Property 1: Timestamp Round Trip
    // For any DateTime value, converting to Timestamp and back should
    // preserve the original value (within millisecond precision)
    // Validates: Requirements 8.3, 12.5
    Glados(any.dateTime).test(
      'Property 1: Timestamp Round Trip - DateTime → Timestamp → DateTime preserves value',
      (originalDateTime) {
        // Convert DateTime to Timestamp
        final timestamp = FirestoreHelpers.dateTimeToTimestamp(originalDateTime);
        
        // Verify timestamp was created
        expect(
          timestamp,
          isNotNull,
          reason: 'Timestamp should not be null for valid DateTime',
        );
        
        // Convert back to DateTime
        final convertedDateTime = FirestoreHelpers.timestampToDateTime(timestamp);
        
        // Verify converted DateTime is not null
        expect(
          convertedDateTime,
          isNotNull,
          reason: 'Converted DateTime should not be null',
        );
        
        // Verify the values match (within millisecond precision)
        // Firestore Timestamp has microsecond precision, but we compare milliseconds
        final originalMillis = originalDateTime.millisecondsSinceEpoch;
        final convertedMillis = convertedDateTime!.millisecondsSinceEpoch;
        
        expect(
          convertedMillis,
          equals(originalMillis),
          reason: 'Round trip conversion should preserve DateTime value. '
              'Original: $originalDateTime (${originalMillis}ms), '
              'Converted: $convertedDateTime (${convertedMillis}ms)',
        );
      },
    );

    // Property 2: Null Handling Consistency
    // For null input, both conversion functions should return null
    Glados<void>(any.either(any.bool, any.bool)).test(
      'Property 2: Null input returns null for both conversions',
      (_) {
      // Test dateTimeToTimestamp with null
      final timestampFromNull = FirestoreHelpers.dateTimeToTimestamp(null);
      expect(
        timestampFromNull,
        isNull,
        reason: 'dateTimeToTimestamp(null) should return null',
      );
      
      // Test timestampToDateTime with null
      final dateTimeFromNull = FirestoreHelpers.timestampToDateTime(null);
      expect(
        dateTimeFromNull,
        isNull,
        reason: 'timestampToDateTime(null) should return null',
      );
    },
    );

    // Property 3: Timestamp Identity
    // For any Timestamp value, passing it to timestampToDateTime should
    // return the equivalent DateTime
    Glados(any.dateTime).test(
      'Property 3: Timestamp passed to timestampToDateTime returns equivalent DateTime',
      (originalDateTime) {
        // Create a Timestamp directly
        final timestamp = Timestamp.fromDate(originalDateTime);
        
        // Convert using helper
        final convertedDateTime = FirestoreHelpers.timestampToDateTime(timestamp);
        
        // Verify not null
        expect(
          convertedDateTime,
          isNotNull,
          reason: 'Converted DateTime should not be null',
        );
        
        // Verify values match
        final originalMillis = originalDateTime.millisecondsSinceEpoch;
        final convertedMillis = convertedDateTime!.millisecondsSinceEpoch;
        
        expect(
          convertedMillis,
          equals(originalMillis),
          reason: 'Timestamp conversion should preserve value',
        );
      },
    );

    // Property 4: DateTime Identity
    // For any DateTime value, passing it to timestampToDateTime should
    // return the same DateTime (identity function for DateTime input)
    Glados(any.dateTime).test(
      'Property 4: DateTime passed to timestampToDateTime returns same DateTime',
      (originalDateTime) {
        // Pass DateTime directly to timestampToDateTime
        final result = FirestoreHelpers.timestampToDateTime(originalDateTime);
        
        // Verify not null
        expect(
          result,
          isNotNull,
          reason: 'Result should not be null',
        );
        
        // Verify it's the same DateTime
        expect(
          result!.millisecondsSinceEpoch,
          equals(originalDateTime.millisecondsSinceEpoch),
          reason: 'DateTime should pass through unchanged',
        );
      },
    );

    // Property 5: Fallback Behavior
    // For any DateTime fallback, timestampToDateTimeWithFallback should
    // return the fallback when given null or invalid input
    Glados(any.dateTime).test(
      'Property 5: Fallback is used when input is null or invalid',
      (fallbackDateTime) {
        // Test with null
        final resultFromNull = FirestoreHelpers.timestampToDateTimeWithFallback(
          null,
          fallbackDateTime,
        );
        
        expect(
          resultFromNull.millisecondsSinceEpoch,
          equals(fallbackDateTime.millisecondsSinceEpoch),
          reason: 'Should return fallback for null input',
        );
        
        // Test with invalid type (string)
        final resultFromInvalid = FirestoreHelpers.timestampToDateTimeWithFallback(
          'invalid',
          fallbackDateTime,
        );
        
        expect(
          resultFromInvalid.millisecondsSinceEpoch,
          equals(fallbackDateTime.millisecondsSinceEpoch),
          reason: 'Should return fallback for invalid input type',
        );
      },
    );

    // Property 6: Fallback Not Used for Valid Input
    // For any valid Timestamp or DateTime, timestampToDateTimeWithFallback
    // should return the converted value, not the fallback
    Glados2(any.dateTime, any.dateTime).test(
      'Property 6: Fallback is not used when input is valid',
      (inputDateTime, fallbackDateTime) {
        // Ensure they're different (at least 1 second apart)
        final adjustedFallback = fallbackDateTime.add(const Duration(seconds: 1));
        
        // Test with Timestamp
        final timestamp = Timestamp.fromDate(inputDateTime);
        final resultFromTimestamp = FirestoreHelpers.timestampToDateTimeWithFallback(
          timestamp,
          adjustedFallback,
        );
        
        expect(
          resultFromTimestamp.millisecondsSinceEpoch,
          equals(inputDateTime.millisecondsSinceEpoch),
          reason: 'Should return converted Timestamp, not fallback',
        );
        
        // Test with DateTime
        final resultFromDateTime = FirestoreHelpers.timestampToDateTimeWithFallback(
          inputDateTime,
          adjustedFallback,
        );
        
        expect(
          resultFromDateTime.millisecondsSinceEpoch,
          equals(inputDateTime.millisecondsSinceEpoch),
          reason: 'Should return input DateTime, not fallback',
        );
      },
    );

    // Property 7: Conversion Preserves Ordering
    // For any two DateTimes where dt1 < dt2, their Timestamp conversions
    // should maintain the same ordering
    Glados2(any.dateTime, any.dateTime).test(
      'Property 7: Timestamp conversion preserves DateTime ordering',
      (dt1, dt2) {
        // Skip if they're equal
        if (dt1.millisecondsSinceEpoch == dt2.millisecondsSinceEpoch) {
          return;
        }
        
        // Ensure dt1 is before dt2
        final earlier = dt1.isBefore(dt2) ? dt1 : dt2;
        final later = dt1.isBefore(dt2) ? dt2 : dt1;
        
        // Convert both to Timestamps
        final ts1 = FirestoreHelpers.dateTimeToTimestamp(earlier);
        final ts2 = FirestoreHelpers.dateTimeToTimestamp(later);
        
        // Verify ordering is preserved
        expect(
          ts1!.compareTo(ts2!) < 0,
          isTrue,
          reason: 'Timestamp ordering should match DateTime ordering. '
              'Earlier: $earlier, Later: $later',
        );
      },
    );
  });
}
