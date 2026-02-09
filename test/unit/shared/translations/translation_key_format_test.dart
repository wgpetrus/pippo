import 'package:flutter_test/flutter_test.dart';
import 'package:pippo/shared/translations/pt_BR.dart';
import 'package:pippo/shared/translations/en_US.dart';
import 'package:pippo/shared/translations/es_ES.dart';

void main() {
  group('Translation Key Format', () {
    test('all pt_BR keys should follow snake_case convention', () {
      final ptTranslations = PtBR.translations;
      final keyPattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

      for (var key in ptTranslations.keys) {
        expect(keyPattern.hasMatch(key), true,
            reason: 'Key "$key" does not follow snake_case convention');
      }
    });

    test('all en_US keys should follow snake_case convention', () {
      final enTranslations = EnUS.translations;
      final keyPattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

      for (var key in enTranslations.keys) {
        expect(keyPattern.hasMatch(key), true,
            reason: 'Key "$key" does not follow snake_case convention');
      }
    });

    test('all es_ES keys should follow snake_case convention', () {
      final esTranslations = EsES.translations;
      final keyPattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

      for (var key in esTranslations.keys) {
        expect(keyPattern.hasMatch(key), true,
            reason: 'Key "$key" does not follow snake_case convention');
      }
    });

    test('pt_BR keys should not contain spaces', () {
      final ptTranslations = PtBR.translations;

      for (var key in ptTranslations.keys) {
        expect(key.contains(' '), false,
            reason: 'Key "$key" contains spaces');
      }
    });

    test('en_US keys should not contain spaces', () {
      final enTranslations = EnUS.translations;

      for (var key in enTranslations.keys) {
        expect(key.contains(' '), false,
            reason: 'Key "$key" contains spaces');
      }
    });

    test('es_ES keys should not contain spaces', () {
      final esTranslations = EsES.translations;

      for (var key in esTranslations.keys) {
        expect(key.contains(' '), false,
            reason: 'Key "$key" contains spaces');
      }
    });

    test('pt_BR keys should not contain special characters', () {
      final ptTranslations = PtBR.translations;
      final invalidChars = RegExp(r'[^a-z0-9_]');

      for (var key in ptTranslations.keys) {
        expect(invalidChars.hasMatch(key), false,
            reason: 'Key "$key" contains special characters');
      }
    });

    test('en_US keys should not contain special characters', () {
      final enTranslations = EnUS.translations;
      final invalidChars = RegExp(r'[^a-z0-9_]');

      for (var key in enTranslations.keys) {
        expect(invalidChars.hasMatch(key), false,
            reason: 'Key "$key" contains special characters');
      }
    });

    test('es_ES keys should not contain special characters', () {
      final esTranslations = EsES.translations;
      final invalidChars = RegExp(r'[^a-z0-9_]');

      for (var key in esTranslations.keys) {
        expect(invalidChars.hasMatch(key), false,
            reason: 'Key "$key" contains special characters');
      }
    });

    test('keys should not contain hyphens', () {
      final allKeys = [
        ...PtBR.translations.keys,
        ...EnUS.translations.keys,
        ...EsES.translations.keys,
      ].toSet();

      for (var key in allKeys) {
        expect(key.contains('-'), false,
            reason: 'Key "$key" contains hyphens (should use underscores)');
      }
    });

    test('keys should not contain dots', () {
      final allKeys = [
        ...PtBR.translations.keys,
        ...EnUS.translations.keys,
        ...EsES.translations.keys,
      ].toSet();

      for (var key in allKeys) {
        expect(key.contains('.'), false,
            reason: 'Key "$key" contains dots');
      }
    });

    test('keys should not start with underscore', () {
      final allKeys = [
        ...PtBR.translations.keys,
        ...EnUS.translations.keys,
        ...EsES.translations.keys,
      ].toSet();

      for (var key in allKeys) {
        expect(key.startsWith('_'), false,
            reason: 'Key "$key" starts with underscore');
      }
    });

    test('keys should not end with underscore', () {
      final allKeys = [
        ...PtBR.translations.keys,
        ...EnUS.translations.keys,
        ...EsES.translations.keys,
      ].toSet();

      for (var key in allKeys) {
        expect(key.endsWith('_'), false,
            reason: 'Key "$key" ends with underscore');
      }
    });

    test('keys should not have consecutive underscores', () {
      final allKeys = [
        ...PtBR.translations.keys,
        ...EnUS.translations.keys,
        ...EsES.translations.keys,
      ].toSet();

      for (var key in allKeys) {
        expect(key.contains('__'), false,
            reason: 'Key "$key" has consecutive underscores');
      }
    });
  });
}
