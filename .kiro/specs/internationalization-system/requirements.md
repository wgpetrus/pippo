# Requirements Document

## Introduction

The Pippo language learning app currently has 43+ screens implemented with hardcoded Portuguese texts. To support international users and follow best practices, we need to implement a complete internationalization system using GetX Translate. This system will allow the app interface to automatically adapt to the user's device language while maintaining Portuguese as the default fallback.

## Glossary

- **GetX Translate**: GetX's built-in internationalization system that uses `.tr` extension for translating strings
- **Translation Key**: A unique identifier in snake_case format used to reference translated strings (e.g., `auth_signin_title`)
- **Locale**: A language and region combination (e.g., `pt_BR` for Brazilian Portuguese, `en_US` for US English)
- **Fallback Locale**: The default language used when a translation is not available in the user's language
- **Device Locale**: The language setting configured in the user's device operating system
- **Interface Language**: The language used for all UI elements, buttons, labels, and messages in the app
- **Learning Language**: The language the user wants to learn (French, Spanish, etc.) - NOT the interface language
- **Hardcoded Text**: Text strings written directly in the code instead of using translation keys
- **Translation Map**: A Dart Map containing key-value pairs of translation keys and their corresponding text

## Requirements

### Requirement 1: Translation File Structure

**User Story:** As a developer, I want a well-organized translation file structure, so that I can easily maintain and extend translations.

#### Acceptance Criteria

1. THE System SHALL create a `lib/shared/translations/` directory
2. THE System SHALL create an `app_translations.dart` file that extends GetX's Translations class
3. THE System SHALL create separate files for each supported locale: `pt_BR.dart`, `en_US.dart`, `es_ES.dart`
4. WHEN a new locale file is created, THE System SHALL define a static Map<String, String> named `translations`
5. THE System SHALL organize translation keys by context (auth, onboarding, home, profile, etc.)

### Requirement 2: Translation Key Extraction

**User Story:** As a developer, I want all hardcoded texts extracted to translation keys, so that the app can support multiple languages.

#### Acceptance Criteria

1. THE System SHALL identify all hardcoded Portuguese texts in the following locations:
   - `lib/features/core/auth/views/` (4 views)
   - `lib/features/core/onboarding/views/` (14 pages)
   - `lib/features/core/lesson/views/` (6 pages)
   - `lib/features/inners/home/views/` (1 view)
   - `lib/features/inners/profile/views/` (11 pages)
   - `lib/features/inners/leaderboard/views/` (1 page)
   - `lib/features/inners/shop/views/` (1 page)
   - `lib/features/inners/treasure/views/` (1 page)
   - `lib/features/inners/friends/views/` (1 view)
   - `lib/features/inners/splash/views/` (1 view)
   - Feature widgets (modals, cards, etc.)
   - Global widgets (AppButton, AppTextField, AppAppbar, etc.)

2. WHEN extracting texts, THE System SHALL create descriptive translation keys following the pattern `[context]_[element]`
3. THE System SHALL use snake_case for all translation keys
4. THE System SHALL NOT use spaces, special characters, or accents in translation keys
5. THE System SHALL group common texts (continue, cancel, save, etc.) under the `common_` prefix
6. THE System SHALL create a complete JSON file with all extracted texts and their keys

### Requirement 3: Translation Key Naming Convention

**User Story:** As a developer, I want consistent translation key naming, so that I can easily find and maintain translations.

#### Acceptance Criteria

1. THE System SHALL follow the naming pattern: `[context]_[element/action]`
2. WHEN the text is used across multiple features, THE System SHALL use the `common_` prefix
3. WHEN the text is specific to a feature, THE System SHALL use the feature name as prefix (e.g., `auth_`, `profile_`, `lesson_`)
4. WHEN the text is a label, THE System SHALL use the `_label` suffix
5. WHEN the text is a hint/placeholder, THE System SHALL use the `_hint` suffix
6. WHEN the text is a title, THE System SHALL use the `_title` suffix
7. WHEN the text is a button, THE System SHALL use the `_button` suffix
8. WHEN the text is a question, THE System SHALL use the `_question` suffix
9. WHEN the text is an error message, THE System SHALL use the `error_` prefix

### Requirement 4: AI-Powered Translation

**User Story:** As a developer, I want AI to translate all texts to English and Spanish, so that I can support international users without manual translation work.

#### Acceptance Criteria

1. WHEN the Portuguese JSON is complete, THE System SHALL use AI to translate all keys to English (en_US)
2. WHEN the Portuguese JSON is complete, THE System SHALL use AI to translate all keys to Spanish (es_ES)
3. THE System SHALL maintain the same translation keys across all language files
4. THE System SHALL preserve formatting, placeholders, and special characters in translations
5. THE System SHALL review translations for context accuracy and natural language flow

### Requirement 5: GetX Translate Configuration

**User Story:** As a developer, I want GetX Translate properly configured, so that the app can automatically switch languages based on device settings.

#### Acceptance Criteria

1. THE System SHALL configure `translations` parameter in GetMaterialApp with AppTranslations instance
2. THE System SHALL set `locale` parameter to `Get.deviceLocale` to follow device language
3. THE System SHALL set `fallbackLocale` to `Locale('pt', 'BR')` as default
4. WHEN a translation key is not found in the user's language, THE System SHALL use the fallback locale
5. THE System SHALL support dynamic language switching without app restart

### Requirement 6: Code Migration to Translation Keys

**User Story:** As a developer, I want all hardcoded texts replaced with `.tr` calls, so that the app displays translated content.

#### Acceptance Criteria

1. THE System SHALL replace all hardcoded Text widgets with translation keys using `.tr`
2. THE System SHALL replace all hardcoded AppButton text parameters with translation keys using `.tr`
3. THE System SHALL replace all hardcoded AppTextField labels and hints with translation keys using `.tr`
4. THE System SHALL replace all hardcoded AppAppbar titles with translation keys using `.tr`
5. THE System SHALL replace all hardcoded error messages with translation keys using `.tr`
6. WHEN replacing texts, THE System SHALL maintain the same visual appearance and functionality
7. THE System SHALL NOT modify any logic, only text strings

### Requirement 7: Learning Language vs Interface Language

**User Story:** As a user, I want the app interface in my device language, while choosing which language to learn, so that I can use the app comfortably.

#### Acceptance Criteria

1. THE System SHALL display the interface in the device's configured language
2. WHEN the device language is not supported, THE System SHALL display the interface in Portuguese
3. THE SelectLanguagePage SHALL be used ONLY for choosing which language to learn (French, Spanish, etc.)
4. THE SelectLanguagePage SHALL NOT change the interface language
5. THE System SHALL display language names in the interface language (e.g., "Francês" in Portuguese, "French" in English)

### Requirement 8: Translation Completeness

**User Story:** As a developer, I want to ensure all texts are translated, so that users never see untranslated content.

#### Acceptance Criteria

1. THE System SHALL verify that all translation keys exist in all supported language files
2. WHEN a translation key is missing, THE System SHALL log a warning during development
3. THE System SHALL provide a fallback to Portuguese when a translation is missing
4. THE System SHALL maintain a count of total translation keys per language file
5. THE System SHALL ensure pt_BR, en_US, and es_ES have the same number of keys

### Requirement 9: Error Message Localization

**User Story:** As a user, I want error messages in my language, so that I can understand what went wrong.

#### Acceptance Criteria

1. THE System SHALL translate all Firebase error messages using the handlers in `firebase.md`
2. THE System SHALL translate all validation error messages
3. THE System SHALL translate all network error messages
4. THE System SHALL translate all generic error messages
5. WHEN displaying errors, THE System SHALL use translation keys with `.tr`

### Requirement 10: Common Text Reusability

**User Story:** As a developer, I want common texts (Continue, Cancel, Save) centralized, so that I can maintain consistency across the app.

#### Acceptance Criteria

1. THE System SHALL identify all repeated texts across multiple screens
2. THE System SHALL create `common_` prefixed keys for texts used in 3+ locations
3. THE System SHALL include at minimum: `common_continue`, `common_cancel`, `common_save`, `common_delete`, `common_edit`, `common_back`, `common_next`, `common_done`, `common_skip`
4. WHEN a common text is updated, THE System SHALL reflect the change across all usages
5. THE System SHALL document all common keys in a separate section of the translation file
