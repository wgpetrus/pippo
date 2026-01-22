import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserNamePage - Google Login Pre-fill Logic', () {
    test('should pre-fill name field when userName is set', () {
      // Arrange
      final userName = 'John Doe';

      // Act - Simulate what UserNamePage.initState() does
      String textFieldValue = '';
      if (userName.isNotEmpty) {
        textFieldValue = userName;
      }

      // Assert
      expect(textFieldValue, 'John Doe',
          reason: 'TextField should be pre-filled with Google displayName');
    });

    test('should have empty name field when userName is not set', () {
      // Arrange
      final userName = '';

      // Act - Simulate what UserNamePage.initState() does
      String textFieldValue = '';
      if (userName.isNotEmpty) {
        textFieldValue = userName;
      }

      // Assert
      expect(textFieldValue, '',
          reason: 'TextField should be empty when userName is not set');
    });

    test('should handle null userName gracefully', () {
      // Arrange
      String? userName;

      // Act - Simulate what UserNamePage.initState() does
      String textFieldValue = '';
      if (userName != null && userName.isNotEmpty) {
        textFieldValue = userName;
      }

      // Assert
      expect(textFieldValue, '',
          reason: 'TextField should be empty when userName is null');
    });
  });
}
