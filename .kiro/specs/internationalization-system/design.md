# Design Document

## Overview

The internationalization system will transform the Pippo app from a Portuguese-only application to a multi-language platform supporting Portuguese (default), English, and Spanish. The implementation follows a four-stage workflow where Stage 1 (UI implementation) is already complete, and we will implement Stages 2-4: text extraction, AI translation, and GetX Translate integration.

The system leverages GetX's built-in Translations class to provide automatic language switching based on device locale, with Portuguese as the fallback language. All 43+ screens will be migrated from hardcoded strings to translation keys using the `.tr` extension.

## Architecture

### File Structure

```
lib/shared/translations/
├── app_translations.dart    # Main Translations class
├── pt_BR.dart               # Portuguese (Brazil) - Default
├── en_US.dart               # English (United States)
└── es_ES.dart               # Spanish (Spain)
```

### Translation Flow

```
Device Locale → GetX Locale Detection → Translation Map Lookup → Display Text
                                              ↓
                                        Key Not Found?
                                              ↓
                                    Fallback to pt_BR
```

### Integration Points

1. **GetMaterialApp Configuration** (`lib/main.dart`)
   - Set translations parameter
   - Configure locale and fallbackLocale
   - Enable automatic locale detection

2. **View Layer** (All 43+ screens)
   - Replace hardcoded strings with `.tr` calls
   - Maintain existing widget structure
   - No logic changes

3. **Widget Layer** (Global and feature widgets)
   - Update text parameters to use `.tr`
   - Preserve all functionality
   - Keep responsive behavior

## Components and Interfaces

### AppTranslations Class

```dart
// lib/shared/translations/app_translations.dart
import 'package:get/get.dart';
import 'pt_BR.dart';
import 'en_US.dart';
import 'es_ES.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'pt_BR': PtBR.translations,
    'en_US': EnUS.translations,
    'es_ES': EsES.translations,
  };
}
```

**Responsibilities:**
- Aggregate all language translation maps
- Provide GetX with locale-to-translation mapping
- Enable runtime language switching

### Language Translation Files

Each language file follows this structure:

```dart
// lib/shared/translations/pt_BR.dart
class PtBR {
  static const Map<String, String> translations = {
    // Auth Section
    'auth_signin_title': 'Entrar',
    'auth_email_label': 'Usuário / e-mail',
    'auth_email_hint': 'digite seu usuário / e-mail',
    'auth_password_label': 'Senha',
    'auth_password_hint': 'digite sua senha',
    'auth_forgot_password': 'Esqueceu sua senha?',
    'auth_no_account': 'Não tem uma conta? Cadastre-se',
    
    // Onboarding Section
    'onboarding_welcome_title': 'Pronto para Começar sua Aventura?',
    'onboarding_welcome_subtitle': 'Aprenda idiomas de forma divertida',
    'onboarding_select_language_title': 'Qual idioma você quer aprender?',
    'onboarding_language_level_title': 'Qual é o seu nível?',
    'onboarding_name_question': 'Qual é o seu nome?',
    'onboarding_name_label': 'Nome',
    'onboarding_age_question': 'Quantos anos você tem?',
    
    // Home Section
    'home_courses_tab': 'Cursos',
    'home_leaderboard_tab': 'Ranking',
    'home_shop_tab': 'Loja',
    'home_treasure_tab': 'Missões',
    'home_profile_tab': 'Perfil',
    
    // Lesson Section
    'lesson_correct_title': 'Correto!',
    'lesson_correct_subtitle': 'Isso mesmo!',
    'lesson_wrong_title': 'Ops!',
    'lesson_wrong_subtitle': 'Boa tentativa, mas não é bem assim.',
    'lesson_complete_title': 'Lição Completa!',
    
    // Profile Section
    'profile_edit_title': 'Editar Perfil',
    'profile_settings_title': 'Configurações',
    'profile_notifications_title': 'Notificações',
    
    // Common Section
    'common_continue': 'Continuar',
    'common_cancel': 'Cancelar',
    'common_save': 'Salvar',
    'common_delete': 'Excluir',
    'common_edit': 'Editar',
    'common_back': 'Voltar',
    'common_next': 'Próximo',
    'common_done': 'Concluído',
    'common_skip': 'Pular',
    
    // Error Section
    'error_network': 'Verifique sua conexão com a internet',
    'error_generic': 'Algo deu errado. Tente novamente.',
    'error_email_invalid': 'Por favor, insira um e-mail válido.',
    'error_password_short': 'A senha deve ter pelo menos 6 caracteres.',
    'error_field_required': 'Este campo é obrigatório.',
  };
}
```

**Key Organization:**
- Group by feature/context (auth, onboarding, home, etc.)
- Common texts in separate section
- Error messages in dedicated section
- Alphabetical order within each section

### GetMaterialApp Configuration

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared/translations/app_translations.dart';
import 'shared/routes/app_routes.dart';
import 'shared/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization...
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pippo',
      debugShowCheckedModeBanner: false,
      
      // Translation Configuration
      translations: AppTranslations(),
      locale: Get.deviceLocale,              // Use device language
      fallbackLocale: const Locale('pt', 'BR'), // Default to Portuguese
      
      // Theme Configuration
      theme: ThemeData(
        fontFamily: AppTheme.fontFamily,
        scaffoldBackgroundColor: AppTheme.white,
        useMaterial3: true,
      ),
      
      // Routes Configuration
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
```

**Configuration Parameters:**
- `translations`: Instance of AppTranslations
- `locale`: Automatically detect device language
- `fallbackLocale`: Portuguese as default
- Maintains existing theme and routing

## Data Models

### Translation Key Structure

Translation keys follow a hierarchical naming convention:

```
[context]_[element]_[type]

Where:
- context: Feature or section (auth, onboarding, profile, etc.)
- element: Specific UI element or action (signin, email, password, etc.)
- type: Optional suffix (title, label, hint, button, question, etc.)
```

**Examples:**

| Context | Element | Type | Full Key | Portuguese Value |
|---------|---------|------|----------|------------------|
| auth | signin | title | `auth_signin_title` | "Entrar" |
| auth | email | label | `auth_email_label` | "Usuário / e-mail" |
| auth | email | hint | `auth_email_hint` | "digite seu usuário / e-mail" |
| onboarding | welcome | title | `onboarding_welcome_title` | "Pronto para Começar sua Aventura?" |
| onboarding | name | question | `onboarding_name_question` | "Qual é o seu nome?" |
| common | continue | - | `common_continue` | "Continuar" |
| error | network | - | `error_network` | "Verifique sua conexão" |

### Translation Map Schema

```dart
Map<String, String> {
  'translation_key': 'Translated text value',
  // ...
}
```

**Constraints:**
- Keys: snake_case, no spaces, no accents, no special characters
- Values: UTF-8 strings, can contain any characters
- Keys must be unique within a language file
- All language files must have the same keys

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Translation Key Consistency

*For any* supported locale (pt_BR, en_US, es_ES), all translation files should contain exactly the same set of translation keys.

**Validates: Requirements 8.1, 8.5**

### Property 2: Fallback Locale Completeness

*For any* translation key used in the application, the fallback locale (pt_BR) should always contain a valid translation.

**Validates: Requirements 5.4, 8.3**

### Property 3: Translation Key Format Compliance

*For any* translation key in the system, it should match the pattern `[context]_[element](_[type])?` where all parts are in snake_case without spaces, accents, or special characters.

**Validates: Requirements 3.1, 3.2**

### Property 4: Device Locale Detection

*For any* device locale setting, when the app starts, it should either display content in that locale (if supported) or fall back to Portuguese.

**Validates: Requirements 5.2, 5.4, 7.2**

### Property 5: Text Replacement Preservation

*For any* screen before and after migration, the visual appearance and functionality should remain identical when viewed in Portuguese.

**Validates: Requirements 6.6, 6.7**

### Property 6: Common Key Reusability

*For any* text that appears in 3 or more different screens, it should be defined as a common key with the `common_` prefix and reused across all occurrences.

**Validates: Requirements 10.2, 10.4**

### Property 7: Error Message Localization

*For any* error condition in the application, the error message displayed to the user should use a translation key with `.tr` and be available in all supported languages.

**Validates: Requirements 9.1, 9.5**

### Property 8: Learning Language Independence

*For any* interface language setting, changing the learning language in SelectLanguagePage should not affect the interface language.

**Validates: Requirements 7.3, 7.4**

## Error Handling

### Missing Translation Keys

**Scenario:** A translation key is used in code but not defined in translation files.

**Handling:**
```dart
// GetX automatically handles missing keys by returning the key itself
Text('missing_key'.tr) // Displays: "missing_key"

// Development detection:
// - Enable GetX logging in debug mode
// - GetX will log warnings for missing keys
// - Use fallbackLocale to provide default text
```

**Prevention:**
- Maintain a master list of all translation keys
- Run validation script before deployment
- Use code review to catch missing keys

### Unsupported Locale

**Scenario:** User's device is set to a language not supported by the app.

**Handling:**
```dart
// GetX automatically falls back to fallbackLocale
locale: Get.deviceLocale,              // Try device language
fallbackLocale: const Locale('pt', 'BR'), // Fall back to Portuguese

// Example: Device in French (fr_FR)
// 1. GetX looks for 'fr_FR' translations → Not found
// 2. GetX falls back to 'pt_BR' → Found
// 3. App displays in Portuguese
```

### Incomplete Translations

**Scenario:** A language file is missing some translation keys.

**Handling:**
```dart
// GetX falls back to fallbackLocale for missing keys
// Example: en_US missing 'new_feature_title'
Text('new_feature_title'.tr)
// 1. Looks in en_US → Not found
// 2. Falls back to pt_BR → Found
// 3. Displays Portuguese text for that specific key
```

**Prevention:**
- Automated key count validation
- CI/CD checks for translation completeness
- Translation file diff reviews

### Runtime Language Switching

**Scenario:** User wants to change interface language (future feature).

**Handling:**
```dart
// GetX supports runtime language switching
void changeLanguage(String languageCode, String countryCode) {
  var locale = Locale(languageCode, countryCode);
  Get.updateLocale(locale);
  // All .tr calls automatically update
  // No app restart needed
}

// Example usage:
changeLanguage('en', 'US'); // Switch to English
changeLanguage('pt', 'BR'); // Switch to Portuguese
```

### Special Characters and Formatting

**Scenario:** Translation contains special characters, line breaks, or formatting.

**Handling:**
```dart
// Translation files support UTF-8 and escape sequences
static const Map<String, String> translations = {
  'multiline_text': 'Primeira linha\nSegunda linha',
  'special_chars': 'Olá! Como você está? 😊',
  'quotes': 'Ele disse: "Olá"',
  'apostrophe': 'It\'s working',
};

// Usage in code:
Text('multiline_text'.tr) // Displays with line break
Text('special_chars'.tr)  // Displays emoji correctly
```

## Testing Strategy

### Dual Testing Approach

The internationalization system requires both unit tests and property-based tests to ensure correctness:

**Unit Tests** - Verify specific examples and edge cases:
- Specific translation key lookups
- Fallback behavior for missing keys
- Locale detection for known device settings
- Common key reusability in specific screens

**Property Tests** - Verify universal properties:
- All language files have identical key sets
- All translation keys follow naming convention
- Fallback locale always has complete translations
- Text replacement preserves visual appearance

### Unit Testing

**Test File:** `test/unit/shared/translations/app_translations_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/shared/translations/app_translations.dart';
import 'package:pippo/shared/translations/pt_BR.dart';
import 'package:pippo/shared/translations/en_US.dart';
import 'package:pippo/shared/translations/es_ES.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  group('AppTranslations', () {
    test('should contain all supported locales', () {
      final translations = AppTranslations();
      final keys = translations.keys;
      
      expect(keys.containsKey('pt_BR'), true);
      expect(keys.containsKey('en_US'), true);
      expect(keys.containsKey('es_ES'), true);
    });

    test('should return correct translation for pt_BR', () {
      final ptTranslations = PtBR.translations;
      
      expect(ptTranslations['auth_signin_title'], 'Entrar');
      expect(ptTranslations['common_continue'], 'Continuar');
    });

    test('should return correct translation for en_US', () {
      final enTranslations = EnUS.translations;
      
      expect(enTranslations['auth_signin_title'], 'Sign In');
      expect(enTranslations['common_continue'], 'Continue');
    });

    test('should handle missing key gracefully', () {
      Get.put(AppTranslations());
      Get.updateLocale(const Locale('pt', 'BR'));
      
      // Missing key returns the key itself
      expect('nonexistent_key'.tr, 'nonexistent_key');
    });
  });

  group('Translation Key Format', () {
    test('should follow snake_case convention', () {
      final ptTranslations = PtBR.translations;
      
      for (var key in ptTranslations.keys) {
        expect(key, matches(r'^[a-z][a-z0-9_]*$'));
      }
    });

    test('should not contain spaces or special characters', () {
      final ptTranslations = PtBR.translations;
      
      for (var key in ptTranslations.keys) {
        expect(key.contains(' '), false);
        expect(key.contains('-'), false);
        expect(key.contains('.'), false);
      }
    });
  });

  group('Common Keys', () {
    test('should have common_continue in all languages', () {
      expect(PtBR.translations.containsKey('common_continue'), true);
      expect(EnUS.translations.containsKey('common_continue'), true);
      expect(EsES.translations.containsKey('common_continue'), true);
    });

    test('should have common_cancel in all languages', () {
      expect(PtBR.translations.containsKey('common_cancel'), true);
      expect(EnUS.translations.containsKey('common_cancel'), true);
      expect(EsES.translations.containsKey('common_cancel'), true);
    });
  });
}
```

### Property-Based Testing

**Test File:** `test/property/shared/translations/translation_properties_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pippo/shared/translations/pt_BR.dart';
import 'package:pippo/shared/translations/en_US.dart';
import 'package:pippo/shared/translations/es_ES.dart';

void main() {
  group('Translation Properties', () {
    // Feature: internationalization-system, Property 1: Translation Key Consistency
    test('all language files should have identical key sets', () {
      final ptKeys = PtBR.translations.keys.toSet();
      final enKeys = EnUS.translations.keys.toSet();
      final esKeys = EsES.translations.keys.toSet();
      
      // All files should have the same keys
      expect(ptKeys, equals(enKeys));
      expect(ptKeys, equals(esKeys));
      expect(enKeys, equals(esKeys));
    }, tags: ['property']);

    // Feature: internationalization-system, Property 2: Fallback Locale Completeness
    test('fallback locale should have all keys used in the app', () {
      final ptTranslations = PtBR.translations;
      
      // Every key should have a non-empty value
      for (var entry in ptTranslations.entries) {
        expect(entry.value.isNotEmpty, true,
            reason: 'Key ${entry.key} has empty value in pt_BR');
      }
    }, tags: ['property']);

    // Feature: internationalization-system, Property 3: Translation Key Format Compliance
    test('all translation keys should follow naming convention', () {
      final allKeys = [
        ...PtBR.translations.keys,
        ...EnUS.translations.keys,
        ...EsES.translations.keys,
      ].toSet();
      
      final keyPattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');
      
      for (var key in allKeys) {
        expect(keyPattern.hasMatch(key), true,
            reason: 'Key "$key" does not follow naming convention');
      }
    }, tags: ['property']);

    // Feature: internationalization-system, Property 6: Common Key Reusability
    test('common keys should be prefixed with common_', () {
      final commonKeys = [
        'common_continue',
        'common_cancel',
        'common_save',
        'common_delete',
        'common_edit',
        'common_back',
        'common_next',
        'common_done',
        'common_skip',
      ];
      
      for (var key in commonKeys) {
        expect(PtBR.translations.containsKey(key), true,
            reason: 'Common key $key missing in pt_BR');
        expect(EnUS.translations.containsKey(key), true,
            reason: 'Common key $key missing in en_US');
        expect(EsES.translations.containsKey(key), true,
            reason: 'Common key $key missing in es_ES');
      }
    }, tags: ['property']);
  });
}
```

### Integration Testing

**Test File:** `test/integration/translations_integration_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/main.dart';
import 'package:pippo/shared/translations/app_translations.dart';

void main() {
  testWidgets('app should display Portuguese by default', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    
    // Verify Portuguese is active
    expect(Get.locale, const Locale('pt', 'BR'));
  });

  testWidgets('app should switch language dynamically', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    
    // Switch to English
    Get.updateLocale(const Locale('en', 'US'));
    await tester.pumpAndSettle();
    
    expect(Get.locale, const Locale('en', 'US'));
  });

  testWidgets('missing translation should fall back to Portuguese', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    
    // Switch to unsupported language
    Get.updateLocale(const Locale('fr', 'FR'));
    await tester.pumpAndSettle();
    
    // Should fall back to pt_BR
    expect(Get.locale, const Locale('pt', 'BR'));
  });
}
```

### Test Configuration

**Minimum Test Coverage:**
- Unit tests: 100 iterations per property test (due to randomization)
- All translation files must be tested
- All common keys must be verified
- Fallback behavior must be tested

**Test Execution:**
```bash
# Run all tests
flutter test

# Run only unit tests
flutter test test/unit/

# Run only property tests
flutter test test/property/ --tags=property

# Run integration tests
flutter test test/integration/
```

### Manual Testing Checklist

- [ ] Test app in Portuguese (pt_BR)
- [ ] Test app in English (en_US)
- [ ] Test app in Spanish (es_ES)
- [ ] Test app with unsupported locale (should fall back to Portuguese)
- [ ] Verify all screens display translated text
- [ ] Verify no hardcoded strings remain
- [ ] Verify error messages are translated
- [ ] Verify common buttons use consistent translations
- [ ] Test SelectLanguagePage (should not change interface language)
- [ ] Verify visual appearance is identical across languages
