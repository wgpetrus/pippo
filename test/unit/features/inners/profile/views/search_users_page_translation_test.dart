import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

/// Test to verify that search_users_page.dart uses translation keys
/// instead of hardcoded strings
void main() {
  group('SearchUsersPage Translation Keys Verification', () {
    late String fileContent;

    setUpAll(() {
      // Read the search_users_page.dart file
      final file = File('lib/features/inners/profile/views/search_users_page.dart');
      fileContent = file.readAsStringSync();
    });

    test('deve usar translation key para o título do AppBar', () {
      // Verifica que usa 'profile_search_title'.tr
      expect(fileContent.contains("'profile_search_title'.tr"), isTrue,
          reason: 'AppBar title should use profile_search_title translation key');

      // Verifica que NÃO usa texto hardcoded
      expect(fileContent.contains("'Buscar usuários'"), isFalse,
          reason: 'AppBar title should not use hardcoded Portuguese text');
    });

    test('deve usar translation key para o hint do campo de busca', () {
      // Verifica que usa 'profile_search_hint'.tr
      expect(fileContent.contains("'profile_search_hint'.tr"), isTrue,
          reason: 'Search field hint should use profile_search_hint translation key');

      // Verifica que NÃO usa texto hardcoded
      expect(fileContent.contains("'Digite username ou nome'"), isFalse,
          reason: 'Search field hint should not use hardcoded Portuguese text');
    });

    test('deve usar translation key para o estado vazio', () {
      // Verifica que usa 'profile_search_empty_state'.tr
      expect(fileContent.contains("'profile_search_empty_state'.tr"), isTrue,
          reason: 'Empty state should use profile_search_empty_state translation key');

      // Verifica que NÃO usa texto hardcoded
      expect(fileContent.contains("'Busque por username ou nome'"), isFalse,
          reason: 'Empty state should not use hardcoded Portuguese text');
    });

    test('deve usar translation key para nenhum resultado encontrado', () {
      // Verifica que usa 'profile_search_no_results'.tr
      expect(fileContent.contains("'profile_search_no_results'.tr"), isTrue,
          reason: 'No results message should use profile_search_no_results translation key');

      // Verifica que NÃO usa texto hardcoded
      expect(fileContent.contains("'Nenhum usuário encontrado'"), isFalse,
          reason: 'No results message should not use hardcoded Portuguese text');
    });

    test('não deve conter NENHUM texto hardcoded em português', () {
      // Lista de textos hardcoded que NÃO devem estar presentes
      final hardcodedTexts = [
        "'Buscar usuários'",
        "'Digite username ou nome'",
        "'Busque por username ou nome'",
        "'Nenhum usuário encontrado'",
      ];

      for (final text in hardcodedTexts) {
        expect(fileContent.contains(text), isFalse,
            reason: 'File should not contain hardcoded text: $text');
      }
    });

    test('deve usar TODAS as translation keys corretas', () {
      // Lista de translation keys que DEVEM estar presentes
      final translationKeys = [
        "'profile_search_title'.tr",
        "'profile_search_hint'.tr",
        "'profile_search_empty_state'.tr",
        "'profile_search_no_results'.tr",
      ];

      for (final key in translationKeys) {
        expect(fileContent.contains(key), isTrue,
            reason: 'File should contain translation key: $key');
      }
    });
  });
}
