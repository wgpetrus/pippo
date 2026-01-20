import 'package:flutter_test/flutter_test.dart';
import 'package:pippo/shared/utils/validation_helper.dart';

void main() {
  group('ValidationHelper - validateName', () {
    test('should return null for valid name', () {
      expect(ValidationHelper.validateName('João Silva'), null);
      expect(ValidationHelper.validateName('Maria'), null);
      expect(ValidationHelper.validateName('José da Silva'), null);
      expect(ValidationHelper.validateName('André Luís'), null);
    });

    test('should return error for null or empty name', () {
      expect(ValidationHelper.validateName(null), 'Nome é obrigatório.');
      expect(ValidationHelper.validateName(''), 'Nome é obrigatório.');
      expect(ValidationHelper.validateName('   '), 'Nome é obrigatório.');
    });

    test('should return error for name with less than 2 characters', () {
      expect(
        ValidationHelper.validateName('A'),
        'Nome deve ter pelo menos 2 caracteres.',
      );
      expect(
        ValidationHelper.validateName(' B '),
        'Nome deve ter pelo menos 2 caracteres.',
      );
    });

    test('should return error for name with invalid characters', () {
      expect(
        ValidationHelper.validateName('João123'),
        'Nome deve conter apenas letras e espaços.',
      );
      expect(
        ValidationHelper.validateName('Maria@Silva'),
        'Nome deve conter apenas letras e espaços.',
      );
      expect(
        ValidationHelper.validateName('José_Silva'),
        'Nome deve conter apenas letras e espaços.',
      );
    });

    test('should accept names with accents', () {
      expect(ValidationHelper.validateName('José'), null);
      expect(ValidationHelper.validateName('André'), null);
      expect(ValidationHelper.validateName('Ângela'), null);
      expect(ValidationHelper.validateName('François'), null);
    });

    test('should trim whitespace before validation', () {
      expect(ValidationHelper.validateName('  João  '), null);
      expect(ValidationHelper.validateName('  Maria Silva  '), null);
    });
  });

  group('ValidationHelper - validateEmail', () {
    test('should return null for valid email', () {
      expect(ValidationHelper.validateEmail('user@example.com'), null);
      expect(ValidationHelper.validateEmail('test.user@domain.co'), null);
      expect(ValidationHelper.validateEmail('name+tag@email.com'), null);
      expect(ValidationHelper.validateEmail('user123@test.org'), null);
    });

    test('should return error for null or empty email', () {
      expect(ValidationHelper.validateEmail(null), 'E-mail é obrigatório.');
      expect(ValidationHelper.validateEmail(''), 'E-mail é obrigatório.');
      expect(ValidationHelper.validateEmail('   '), 'E-mail é obrigatório.');
    });

    test('should return error for invalid email format', () {
      expect(
        ValidationHelper.validateEmail('invalid'),
        'Por favor, insira um e-mail válido.',
      );
      expect(
        ValidationHelper.validateEmail('user@'),
        'Por favor, insira um e-mail válido.',
      );
      expect(
        ValidationHelper.validateEmail('@domain.com'),
        'Por favor, insira um e-mail válido.',
      );
      expect(
        ValidationHelper.validateEmail('user@domain'),
        'Por favor, insira um e-mail válido.',
      );
      expect(
        ValidationHelper.validateEmail('user domain@test.com'),
        'Por favor, insira um e-mail válido.',
      );
    });

    test('should trim whitespace before validation', () {
      expect(ValidationHelper.validateEmail('  user@example.com  '), null);
      expect(ValidationHelper.validateEmail('  test@domain.co  '), null);
    });
  });

  group('ValidationHelper - validatePassword', () {
    test('should return null for valid password', () {
      expect(ValidationHelper.validatePassword('123456'), null);
      expect(ValidationHelper.validatePassword('password'), null);
      expect(ValidationHelper.validatePassword('MyP@ssw0rd'), null);
      expect(ValidationHelper.validatePassword('abcdefghij'), null);
    });

    test('should return error for null or empty password', () {
      expect(ValidationHelper.validatePassword(null), 'Senha é obrigatória.');
      expect(ValidationHelper.validatePassword(''), 'Senha é obrigatória.');
    });

    test('should return error for password with less than 6 characters', () {
      expect(
        ValidationHelper.validatePassword('12345'),
        'Senha deve ter pelo menos 6 caracteres.',
      );
      expect(
        ValidationHelper.validatePassword('abc'),
        'Senha deve ter pelo menos 6 caracteres.',
      );
      expect(
        ValidationHelper.validatePassword('a'),
        'Senha deve ter pelo menos 6 caracteres.',
      );
    });

    test('should accept password with exactly 6 characters', () {
      expect(ValidationHelper.validatePassword('123456'), null);
      expect(ValidationHelper.validatePassword('abcdef'), null);
    });

    test('should NOT trim whitespace for password', () {
      // Password validation should not trim - spaces are valid characters
      expect(ValidationHelper.validatePassword('      '), null); // 6 spaces = valid
      expect(ValidationHelper.validatePassword('  abc  '), null); // 7 chars total = valid
    });
  });

  group('ValidationHelper - sanitizeName', () {
    test('should trim whitespace from name', () {
      expect(ValidationHelper.sanitizeName('  João  '), 'João');
      expect(ValidationHelper.sanitizeName('Maria Silva  '), 'Maria Silva');
      expect(ValidationHelper.sanitizeName('  José  '), 'José');
    });

    test('should return same string if no whitespace', () {
      expect(ValidationHelper.sanitizeName('João'), 'João');
      expect(ValidationHelper.sanitizeName('Maria Silva'), 'Maria Silva');
    });

    test('should handle empty string', () {
      expect(ValidationHelper.sanitizeName(''), '');
      expect(ValidationHelper.sanitizeName('   '), '');
    });
  });

  group('ValidationHelper - sanitizeEmail', () {
    test('should trim and lowercase email', () {
      expect(
        ValidationHelper.sanitizeEmail('  USER@EXAMPLE.COM  '),
        'user@example.com',
      );
      expect(
        ValidationHelper.sanitizeEmail('Test@Domain.Co'),
        'test@domain.co',
      );
      expect(
        ValidationHelper.sanitizeEmail('  EMAIL@TEST.ORG  '),
        'email@test.org',
      );
    });

    test('should return lowercase if no whitespace', () {
      expect(
        ValidationHelper.sanitizeEmail('USER@EXAMPLE.COM'),
        'user@example.com',
      );
      expect(ValidationHelper.sanitizeEmail('Test@Domain.Co'), 'test@domain.co');
    });

    test('should handle empty string', () {
      expect(ValidationHelper.sanitizeEmail(''), '');
      expect(ValidationHelper.sanitizeEmail('   '), '');
    });

    test('should preserve email structure while lowercasing', () {
      expect(
        ValidationHelper.sanitizeEmail('User.Name+Tag@Example.COM'),
        'user.name+tag@example.com',
      );
    });
  });
}
