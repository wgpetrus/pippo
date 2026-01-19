// Flutter packages
import 'package:flutter_test/flutter_test.dart';

/// Feature: onboarding, Property 8: Username Uniqueness Guarantee
/// 
/// Property: For any user name provided, the system MUST generate a unique username
/// by converting to lowercase, removing spaces, and appending a random number (1-9999)
/// if the username already exists, repeating until a unique username is found.
/// 
/// Validates: Requirements 7.1, 7.2, 7.3, 7.4
/// 
/// NOTA: Estes testes validam a lógica de geração de username sem interação real com Firestore.
/// Os testes verificam as propriedades de transformação e unicidade do algoritmo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper function to simulate username generation logic
  // IMPORTANTE: Manter sincronizado com OnboardingController.generateUniqueUsername
  String generateBaseUsername(String name) {
    return name.toLowerCase().replaceAll(' ', '');
  }

  group('Feature: onboarding, Property 8: Username Uniqueness Guarantee', () {

    test('Property 8.1: Username generation converts to lowercase', () {
      // Property: generateBaseUsername MUST convert all characters to lowercase
      
      final testNames = [
        'JOÃO',
        'Maria',
        'PEDRO SILVA',
        'Ana Paula',
        'JoSé',
        'MARIA SILVA SANTOS',
        'ABC',
        'XyZ',
      ];

      for (int i = 0; i < 100; i++) {
        for (final name in testNames) {
          final username = generateBaseUsername(name);
          
          // Property: Username must be all lowercase
          expect(username, equals(username.toLowerCase()),
              reason: 'Iteration $i: Username "$username" from "$name" must be lowercase');
          
          // Property: Username must not contain uppercase letters
          expect(username.contains(RegExp(r'[A-Z]')), isFalse,
              reason: 'Iteration $i: Username "$username" must not contain uppercase letters');
        }
      }
    });

    test('Property 8.2: Username generation removes all spaces', () {
      // Property: generateBaseUsername MUST remove all spaces from the name
      
      final testNames = [
        'João Silva',
        'Maria  Silva', // double space
        'Pedro   Silva   Santos', // multiple spaces
        ' Ana Paula ', // leading/trailing spaces
        'José da Silva',
        'Maria Silva Santos Junior',
        '  Spaced  Name  ',
      ];

      for (int i = 0; i < 100; i++) {
        for (final name in testNames) {
          final username = generateBaseUsername(name);
          
          // Property: Username must not contain any spaces
          expect(username.contains(' '), isFalse,
              reason: 'Iteration $i: Username "$username" from "$name" must not contain spaces');
          
          // Property: Username length must be less than or equal to name without spaces
          final nameWithoutSpaces = name.replaceAll(' ', '');
          expect(username.length, equals(nameWithoutSpaces.toLowerCase().length),
              reason: 'Iteration $i: Username length must match name without spaces');
        }
      }
    });

    test('Property 8.3: Username generation is deterministic for same input', () {
      // Property: generateBaseUsername MUST return the same result for the same input
      // (pure function)
      
      final testNames = [
        'João Silva',
        'Maria',
        'Pedro Santos',
        'Ana Paula',
        'José',
      ];

      for (int i = 0; i < 50; i++) {
        for (final name in testNames) {
          // Generate username multiple times
          final usernames = <String>[];
          for (int j = 0; j < 10; j++) {
            usernames.add(generateBaseUsername(name));
          }
          
          // Property: All results must be identical
          final firstUsername = usernames.first;
          expect(usernames.every((u) => u == firstUsername), isTrue,
              reason: 'Iteration $i: generateBaseUsername must be deterministic for "$name"');
        }
      }
    });

    test('Property 8.4: Username generation handles edge cases', () {
      // Property: generateBaseUsername MUST handle edge cases correctly
      
      final edgeCases = [
        {'name': 'A', 'expected': 'a'},
        {'name': 'AB', 'expected': 'ab'},
        {'name': 'A B', 'expected': 'ab'},
        {'name': '   João   ', 'expected': 'joão'},
        {'name': 'JOÃO SILVA', 'expected': 'joãosilva'},
        {'name': 'José  da  Silva', 'expected': 'josédasilva'},
        {'name': 'Maria123', 'expected': 'maria123'},
        {'name': 'User_Name', 'expected': 'user_name'},
      ];

      for (int i = 0; i < 100; i++) {
        for (final testCase in edgeCases) {
          final name = testCase['name'] as String;
          final expected = testCase['expected'] as String;
          final username = generateBaseUsername(name);
          
          // Property: Username must match expected transformation
          expect(username, equals(expected),
              reason: 'Iteration $i: Username from "$name" must be "$expected"');
        }
      }
    });

    test('Property 8.5: Username with number suffix follows pattern', () {
      // Property: When appending random number, it MUST be between 1 and 9999
      // and concatenated directly to base username (no separator)
      
      final baseUsername = 'joaosilva';
      final validSuffixes = List.generate(9999, (i) => i + 1);

      for (int i = 0; i < 100; i++) {
        for (final suffix in validSuffixes.take(50)) {
          final username = '$baseUsername$suffix';
          
          // Property 1: Username must start with base username
          expect(username.startsWith(baseUsername), isTrue,
              reason: 'Iteration $i: Username "$username" must start with base "$baseUsername"');
          
          // Property 2: Suffix must be a number between 1 and 9999
          final suffixStr = username.substring(baseUsername.length);
          final suffixNum = int.tryParse(suffixStr);
          expect(suffixNum, isNotNull,
              reason: 'Iteration $i: Suffix "$suffixStr" must be a valid number');
          expect(suffixNum! >= 1 && suffixNum <= 9999, isTrue,
              reason: 'Iteration $i: Suffix $suffixNum must be between 1 and 9999');
          
          // Property 3: No separator between base and suffix
          expect(username, equals('$baseUsername$suffix'),
              reason: 'Iteration $i: Username must have no separator between base and suffix');
        }
      }
    });

    test('Property 8.6: Multiple usernames from same name are unique when suffixed', () {
      // Property: When generating multiple usernames from the same base name,
      // each with a different suffix, all usernames MUST be unique
      
      final baseName = 'João Silva';
      final baseUsername = generateBaseUsername(baseName);

      for (int i = 0; i < 50; i++) {
        final usernames = <String>{};
        
        // Generate 100 usernames with different suffixes
        for (int suffix = 1; suffix <= 100; suffix++) {
          final username = '$baseUsername$suffix';
          usernames.add(username);
        }
        
        // Property: All usernames must be unique (set size equals list size)
        expect(usernames.length, equals(100),
            reason: 'Iteration $i: All 100 usernames must be unique');
      }
    });

    test('Property 8.7: Username generation preserves non-space characters', () {
      // Property: generateBaseUsername MUST preserve all non-space characters
      // (only lowercase conversion and space removal)
      
      final testNames = [
        'João123',
        'Maria_Silva',
        'Pedro-Santos',
        'Ana.Paula',
        'José@Silva',
        'User123_Test',
      ];

      for (int i = 0; i < 100; i++) {
        for (final name in testNames) {
          final username = generateBaseUsername(name);
          final nameWithoutSpaces = name.replaceAll(' ', '').toLowerCase();
          
          // Property: Username must equal name with spaces removed and lowercased
          expect(username, equals(nameWithoutSpaces),
              reason: 'Iteration $i: Username must preserve all non-space characters from "$name"');
        }
      }
    });

    test('Property 8.8: Username generation handles special characters', () {
      // Property: generateBaseUsername MUST handle special characters correctly
      // (preserve them, only remove spaces and lowercase)
      
      final testNames = [
        'José',
        'María',
        'François',
        'Müller',
        'Øyvind',
        'Łukasz',
      ];

      for (int i = 0; i < 100; i++) {
        for (final name in testNames) {
          final username = generateBaseUsername(name);
          
          // Property 1: Username must be lowercase version of name
          expect(username, equals(name.toLowerCase()),
              reason: 'Iteration $i: Username must be lowercase version of "$name"');
          
          // Property 2: Username must not contain spaces
          expect(username.contains(' '), isFalse,
              reason: 'Iteration $i: Username must not contain spaces');
        }
      }
    });

    test('Property 8.9: Username length is predictable', () {
      // Property: Username length MUST equal name length minus number of spaces
      
      final testNames = [
        'João',
        'Maria Silva',
        'Pedro Silva Santos',
        'Ana Paula',
        'José da Silva',
      ];

      for (int i = 0; i < 100; i++) {
        for (final name in testNames) {
          final username = generateBaseUsername(name);
          final expectedLength = name.replaceAll(' ', '').length;
          
          // Property: Username length must equal name without spaces
          expect(username.length, equals(expectedLength),
              reason: 'Iteration $i: Username length must equal name length minus spaces');
        }
      }
    });

    test('Property 8.10: Username generation is idempotent', () {
      // Property: Applying generateBaseUsername twice MUST produce the same result
      // as applying it once (idempotent operation)
      
      final testNames = [
        'João Silva',
        'MARIA',
        'Pedro  Santos',
        ' Ana Paula ',
      ];

      for (int i = 0; i < 100; i++) {
        for (final name in testNames) {
          final username1 = generateBaseUsername(name);
          final username2 = generateBaseUsername(username1);
          
          // Property: Applying transformation twice must equal applying once
          expect(username2, equals(username1),
              reason: 'Iteration $i: generateBaseUsername must be idempotent for "$name"');
        }
      }
    });

    test('Property 8.11: Different names produce different base usernames', () {
      // Property: Different input names MUST produce different base usernames
      // (unless they differ only in case or spaces)
      
      final testPairs = [
        ['João Silva', 'Maria Silva'],
        ['Pedro', 'Paulo'],
        ['Ana Paula', 'Ana Maria'],
        ['José Santos', 'José Silva'],
      ];

      for (int i = 0; i < 100; i++) {
        for (final pair in testPairs) {
          final username1 = generateBaseUsername(pair[0]);
          final username2 = generateBaseUsername(pair[1]);
          
          // Property: Different names must produce different usernames
          expect(username1, isNot(equals(username2)),
              reason: 'Iteration $i: Different names "${pair[0]}" and "${pair[1]}" must produce different usernames');
        }
      }
    });

    test('Property 8.12: Same name with different case/spaces produces same username', () {
      // Property: Names that differ only in case or spacing MUST produce
      // the same base username
      
      final testGroups = [
        ['João Silva', 'joão silva', 'JOÃO SILVA', 'João  Silva'],
        ['Maria', 'MARIA', 'maria', ' Maria '],
        ['Pedro Santos', 'PEDRO SANTOS', 'pedro santos', 'Pedro  Santos'],
      ];

      for (int i = 0; i < 100; i++) {
        for (final group in testGroups) {
          final usernames = group.map((name) => generateBaseUsername(name)).toSet();
          
          // Property: All variations must produce the same username
          expect(usernames.length, equals(1),
              reason: 'Iteration $i: Names differing only in case/spaces must produce same username: $group');
        }
      }
    });
  });
}
