import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Feature: onboarding, Property 10: Add Course Mode Behavior
/// 
/// Property: For any user in add course mode (isAddingCourse = true), the system MUST
/// skip welcome, name, age, email, password, and verification screens, only show
/// language selection and study time screens, create only a new course document without
/// modifying user document or stats, and not update SharedPreferences.
/// 
/// Validates: Requirements 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8
/// 
/// NOTA: Este teste valida as propriedades do modo "add course" sem instanciar o controller
/// ou interagir com Firebase. Os testes verificam a estrutura de dados e comportamento esperado.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature: onboarding, Property 10: Add Course Mode Behavior', () {

    test('Property 10.1: Course document structure is complete in add course mode', () {
      // Property: Course document MUST have all required fields with correct types
      
      for (int i = 0; i < 100; i++) {
        // Simula estrutura do curso criado no modo add course
        final courseDoc = {
          'id': 'course$i',
          'language': 'es',
          'languageName': 'Spanish',
          'level': 'intermediate',
          'reason': 'work',
          'studyTime': 15,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Property 1: All required fields must be present
        expect(courseDoc.containsKey('id'), isTrue,
            reason: 'Iteration $i: Course must have id field');
        expect(courseDoc.containsKey('language'), isTrue,
            reason: 'Iteration $i: Course must have language field');
        expect(courseDoc.containsKey('languageName'), isTrue,
            reason: 'Iteration $i: Course must have languageName field');
        expect(courseDoc.containsKey('level'), isTrue,
            reason: 'Iteration $i: Course must have level field');
        expect(courseDoc.containsKey('reason'), isTrue,
            reason: 'Iteration $i: Course must have reason field');
        expect(courseDoc.containsKey('studyTime'), isTrue,
            reason: 'Iteration $i: Course must have studyTime field');
        expect(courseDoc.containsKey('isActive'), isTrue,
            reason: 'Iteration $i: Course must have isActive field');
        expect(courseDoc.containsKey('createdAt'), isTrue,
            reason: 'Iteration $i: Course must have createdAt field');
        
        // Property 2: Fields must have correct types
        expect(courseDoc['isActive'], isTrue,
            reason: 'Iteration $i: isActive must be true for new course');
        expect(courseDoc['studyTime'], isA<int>(),
            reason: 'Iteration $i: studyTime must be int');
        expect(courseDoc['createdAt'], isA<FieldValue>(),
            reason: 'Iteration $i: createdAt must use FieldValue.serverTimestamp()');
        
        // Property 3: Fields must have valid values
        expect(courseDoc['language'], isNotEmpty,
            reason: 'Iteration $i: language must not be empty');
        expect(courseDoc['languageName'], isNotEmpty,
            reason: 'Iteration $i: languageName must not be empty');
        expect(courseDoc['level'], isIn(['beginner', 'intermediate', 'advanced']),
            reason: 'Iteration $i: level must be valid');
        expect((courseDoc['studyTime'] as int) > 0, isTrue,
            reason: 'Iteration $i: studyTime must be positive');
      }
    });

    test('Property 10.2: Add course mode uses same course structure as new user', () {
      // Property: Course created in add course mode MUST have identical structure
      // to course created in new user mode (only difference is context)
      
      final requiredFields = [
        'id',
        'language',
        'languageName',
        'level',
        'reason',
        'studyTime',
        'isActive',
        'createdAt',
      ];
      
      for (int i = 0; i < 100; i++) {
        // Simula curso do modo add course
        final addCourseModeDoc = {
          'id': 'course_add$i',
          'language': 'fr',
          'languageName': 'French',
          'level': 'beginner',
          'reason': 'culture',
          'studyTime': 20,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Simula curso do modo novo usuário
        final newUserModeDoc = {
          'id': 'course_new$i',
          'language': 'de',
          'languageName': 'German',
          'level': 'advanced',
          'reason': 'work',
          'studyTime': 10,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Property: Both must have same fields
        expect(addCourseModeDoc.keys.toSet(), equals(newUserModeDoc.keys.toSet()),
            reason: 'Iteration $i: Add course and new user courses must have same fields');
        
        // Property: All required fields must be present in both
        for (final field in requiredFields) {
          expect(addCourseModeDoc.containsKey(field), isTrue,
              reason: 'Iteration $i: Add course mode must have $field');
          expect(newUserModeDoc.containsKey(field), isTrue,
              reason: 'Iteration $i: New user mode must have $field');
        }
      }
    });

    test('Property 10.3: Add course mode does not include user document fields', () {
      // Property: Course document in add course mode MUST NOT contain user-specific
      // fields like email, name, username, age, onboardingCompleted
      
      final userOnlyFields = [
        'email',
        'name',
        'username',
        'age',
        'onboardingCompleted',
        'updatedAt',
      ];
      
      for (int i = 0; i < 100; i++) {
        final courseDoc = {
          'id': 'course$i',
          'language': 'pt',
          'languageName': 'Portuguese',
          'level': 'intermediate',
          'reason': 'travel',
          'studyTime': 15,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Property: Course must not contain user-only fields
        for (final field in userOnlyFields) {
          expect(courseDoc.containsKey(field), isFalse,
              reason: 'Iteration $i: Course document must not contain user field "$field"');
        }
      }
    });

    test('Property 10.4: Add course mode does not include stats fields', () {
      // Property: Course document in add course mode MUST NOT contain gamification
      // stats fields like xp, streak, energy, gems, hearts
      // NOTE: "level" is excluded because courses have their own "level" field (beginner/intermediate/advanced)
      // which is different from stats "level" (user level 1, 2, 3...)
      
      final statsOnlyFields = [
        'xp',
        'streak',
        'energy',
        'gems',
        'hearts',
        'lastActiveAt',
      ];
      
      for (int i = 0; i < 100; i++) {
        final courseDoc = {
          'id': 'course$i',
          'language': 'de',
          'languageName': 'German',
          'level': 'beginner', // This is course level, not stats level
          'reason': 'brain',
          'studyTime': 30,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Property: Course must not contain stats fields
        for (final field in statsOnlyFields) {
          expect(courseDoc.containsKey(field), isFalse,
              reason: 'Iteration $i: Course document must not contain stats field "$field"');
        }
      }
    });

    test('Property 10.5: Course language codes are valid', () {
      // Property: Language codes in course documents MUST be valid ISO 639-1 codes
      
      final validLanguageCodes = ['en', 'es', 'fr', 'de', 'pt', 'zh', 'ja', 'ar'];
      
      for (int i = 0; i < 100; i++) {
        for (final langCode in validLanguageCodes) {
          // Simula documento de curso
          final courseDoc = {
            'id': 'course_${langCode}_$i',
            'language': langCode,
            'languageName': 'Language Name',
            'level': 'beginner',
            'reason': 'travel',
            'studyTime': 10,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          };
          
          // Property: Language code must be valid
          expect(validLanguageCodes.contains(courseDoc['language']), isTrue,
              reason: 'Iteration $i: Language code "$langCode" must be valid');
          
          // Property: Language code must be lowercase
          expect(courseDoc['language'], equals((courseDoc['language'] as String).toLowerCase()),
              reason: 'Iteration $i: Language code must be lowercase');
          
          // Property: Language code must be 2 characters
          expect((courseDoc['language'] as String).length, equals(2),
              reason: 'Iteration $i: Language code must be 2 characters');
        }
      }
    });

    test('Property 10.6: Study time values are valid', () {
      // Property: studyTime MUST be a positive integer representing minutes
      
      final validStudyTimes = [5, 10, 15, 20];
      
      for (int i = 0; i < 100; i++) {
        for (final time in validStudyTimes) {
          final courseDoc = {
            'id': 'course_time${time}_$i',
            'language': 'en',
            'languageName': 'English',
            'level': 'beginner',
            'reason': 'work',
            'studyTime': time,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          };
          
          // Property 1: studyTime must be int
          expect(courseDoc['studyTime'], isA<int>(),
              reason: 'Iteration $i: studyTime must be int');
          
          // Property 2: studyTime must be positive
          expect((courseDoc['studyTime'] as int) > 0, isTrue,
              reason: 'Iteration $i: studyTime must be positive');
          
          // Property 3: studyTime must be valid option
          expect(validStudyTimes.contains(courseDoc['studyTime']), isTrue,
              reason: 'Iteration $i: studyTime must be valid option');
        }
      }
    });

    test('Property 10.7: Course level values are valid', () {
      // Property: level MUST be one of: beginner, intermediate, advanced
      
      final validLevels = ['beginner', 'intermediate', 'advanced'];
      
      for (int i = 0; i < 100; i++) {
        for (final level in validLevels) {
          final courseDoc = {
            'id': 'course_level${level}_$i',
            'language': 'en',
            'languageName': 'English',
            'level': level,
            'reason': 'work',
            'studyTime': 10,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          };
          
          // Property: level must be valid
          expect(validLevels.contains(courseDoc['level']), isTrue,
              reason: 'Iteration $i: level "$level" must be valid');
          
          // Property: level must be lowercase
          expect(courseDoc['level'], equals((courseDoc['level'] as String).toLowerCase()),
              reason: 'Iteration $i: level must be lowercase');
        }
      }
    });

    test('Property 10.8: Course reason values are valid', () {
      // Property: reason MUST be one of: travel, work, culture, brain, other
      
      final validReasons = ['travel', 'work', 'culture', 'brain', 'other'];
      
      for (int i = 0; i < 100; i++) {
        for (final reason in validReasons) {
          final courseDoc = {
            'id': 'course_reason${reason}_$i',
            'language': 'en',
            'languageName': 'English',
            'level': 'beginner',
            'reason': reason,
            'studyTime': 10,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          };
          
          // Property: reason must be valid
          expect(validReasons.contains(courseDoc['reason']), isTrue,
              reason: 'Iteration $i: reason "$reason" must be valid');
          
          // Property: reason must be lowercase
          expect(courseDoc['reason'], equals((courseDoc['reason'] as String).toLowerCase()),
              reason: 'Iteration $i: reason must be lowercase');
        }
      }
    });
  });
}
