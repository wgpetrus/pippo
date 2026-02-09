# Translation Prompt: Portuguese to English

## Context

**App Name:** Pippo

**App Description:** Pippo is a gamified language learning application similar to Duolingo. Users learn new languages through interactive lessons, exercises, and challenges. The app features:
- Onboarding flow for new users
- Authentication system
- Interactive lessons with various exercise types (image matching, translation, word ordering, etc.)
- Gamification elements (XP, gems, energy system, streaks)
- Social features (leaderboards, friends)
- Shop for boosts and customization
- Profile management

**Target Audience:** Language learners of all ages who want to learn through fun, interactive exercises.

**Tone:** Friendly, encouraging, motivational, and playful. The app uses a mascot character and aims to make learning feel like an adventure.

## Translation Requirements

1. **Natural Language Flow:** Translations should sound natural to native English speakers, not literal word-for-word translations.

2. **Maintain Tone:** Keep the friendly, encouraging, and playful tone of the original Portuguese text.

3. **Context Awareness:** Consider the context of each key (auth, onboarding, lessons, etc.) when translating.

4. **Consistency:** Use consistent terminology throughout (e.g., always use "streak" for "sequência", "gems" for "gemas", "energy" for "energia").

5. **Placeholders:** Preserve any placeholders in the format `{variable}` exactly as they appear.

6. **Punctuation:** Adapt punctuation to English conventions (e.g., question marks, exclamation points).

7. **Cultural Adaptation:** Adapt expressions and idioms to English-speaking culture when appropriate.

8. **Button Text:** Keep button text concise and action-oriented.

9. **Error Messages:** Make error messages clear and helpful.

10. **Gamification Terms:** Use standard gamification terminology familiar to English-speaking users.

## Key Terminology

| Portuguese | English |
|------------|---------|
| Sequência | Streak |
| Gemas | Gems |
| Energia | Energy |
| Raios | Sparks/Energy |
| XP | XP |
| Lição | Lesson |
| Exercício | Exercise |
| Desafio | Challenge |
| Missão | Quest/Mission |
| Ranking | Leaderboard |
| Liga | League |
| Mascote | Mascot |
| Streak de fogo | Fire streak |
| Guerreiro das Palavras | Word Warrior |
| Caça ao Tesouro | Treasure Hunt |

## Portuguese Translations to Translate

Below are all the Portuguese translation keys that need to be translated to English. Please provide ONLY the translated values, maintaining the exact same key names.

```dart
{
  // Auth Section
  'auth_cancel_button': 'Cancelar',
  'auth_confirm_password_hint': 'Digite sua senha novamente',
  'auth_confirm_password_label': 'Confirmar senha',
  'auth_email_hint': 'digite seu usuário / e-mail',
  'auth_email_label': 'Usuário / e-mail',
  'auth_facebook_button': 'Facebook',
  'auth_forgot_password': 'Esqueceu sua senha',
  'auth_forgot_password_description': 'Digite seu e-mail para receber um link de recuperação de senha.',
  'auth_forgot_password_title': 'Esqueci minha senha',
  'auth_gmail_button': 'Gmail',
  'auth_login_with_email_button': 'Fazer login com e-mail',
  'auth_new_password_description': 'Crie uma nova senha para sua conta.',
  'auth_new_password_hint': 'Digite sua nova senha',
  'auth_new_password_label': 'Nova senha',
  'auth_new_password_title': 'Nova senha',
  'auth_password_hint': 'digite sua senha',
  'auth_password_label': 'Senha',
  'auth_remembered_password': 'Lembrei minha senha',
  'auth_reset_password_button': 'Redefinir senha',
  'auth_send_link_button': 'Enviar link',
  'auth_signin_button': 'Entrar',
  'auth_signin_title': 'Entrar',
  'auth_verify_button': 'Verificar',
  'auth_verify_code_description': 'Digite o código de 5 dígitos que enviamos para seu e-mail.',
  'auth_verify_code_title': 'Verificar código',

  // Continue with all other sections...
}
```

## Output Format

Please provide the translations in the following format:

```dart
{
  'key_name': 'English translation',
  // ...
}
```

Ensure:
- All keys are translated
- Keys maintain their exact names
- Values are natural English
- Placeholders like {lang}, {count}, {energy}, etc. are preserved
- The structure and organization match the original
