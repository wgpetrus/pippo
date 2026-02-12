import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

/// Test to verify that learning_controls_page.dart uses translation keys
/// instead of hardcoded strings
void main() {
  group('LearningControlsPage Translation Keys Verification', () {
    late String fileContent;

    setUpAll(() {
      // Read the learning_controls_page.dart file
      final file = File('lib/features/inners/profile/views/learning_controls_page.dart');
      fileContent = file.readAsStringSync();
    });

    test('deve usar translation key para o formato de minutos no modal', () {
      // Verifica que usa 'learning_controls_minutes_format'.trParams
      expect(fileContent.contains("'learning_controls_minutes_format'.trParams"), isTrue,
          reason: 'Modal should use learning_controls_minutes_format translation key with trParams');

      // Verifica que NÃO usa texto hardcoded '$minutes minutos'
      expect(fileContent.contains("'\$minutes minutos'"), isFalse,
          reason: 'Modal should not use hardcoded Portuguese text for minutes format');
    });

    test('deve usar trParams com parâmetro minutes correto', () {
      // Verifica que usa o formato correto: .trParams({'minutes': minutes.toString()})
      expect(fileContent.contains(".trParams({'minutes': minutes.toString()})"), isTrue,
          reason: 'Should use trParams with minutes parameter correctly');
    });

    test('não deve conter texto hardcoded de minutos em português', () {
      // Lista de textos hardcoded que NÃO devem estar presentes
      final hardcodedTexts = [
        "'\$minutes minutos'",
        "'minutos'",
      ];

      for (final text in hardcodedTexts) {
        expect(fileContent.contains(text), isFalse,
            reason: 'File should not contain hardcoded text: $text');
      }
    });

    test('deve usar translation key learning_controls_minutes_format', () {
      // Verifica que a key correta está presente
      expect(fileContent.contains("'learning_controls_minutes_format'"), isTrue,
          reason: 'File should contain learning_controls_minutes_format translation key');
    });

    test('deve usar todas as translation keys de learning controls', () {
      // Lista de translation keys que DEVEM estar presentes
      final translationKeys = [
        "'learning_controls_title'.tr",
        "'learning_controls_learning_style'.tr",
        "'learning_controls_sound_effects'.tr",
        "'learning_controls_listening_exercises'.tr",
        "'learning_controls_speaking_exercises'.tr",
        "'learning_controls_daily_goal_section'.tr",
        "'learning_controls_daily_goal'.tr",
        "'learning_controls_daily_goal_minutes'.tr",
        "'learning_controls_language_settings'.tr",
        "'learning_controls_display_mode'.tr",
        "'learning_controls_all_words'.tr",
        "'learning_controls_minutes_format'.trParams",
      ];

      for (final key in translationKeys) {
        expect(fileContent.contains(key), isTrue,
            reason: 'File should contain translation key: $key');
      }
    });
  });
}
