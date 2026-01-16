# Tradução e Idioma do App

> Sistema de internacionalização com GetX Translate

---

## Idioma da Interface

**O app deve estar em PORTUGUÊS**, não inglês.

- Todos os textos da interface: português
- Mensagens de erro: português
- Notificações: português
- Feedback: português

---

## Sistema de Tradução

### GetX Translate

Usar GetX Translate para internacionalização:

1. **Criar telas em português**
2. **Extrair textos para JSON com chaves**
3. **Usar nas telas como `.tr`**

---

## Estrutura de Arquivos

```
lib/shared/translations/
├── pt_BR.dart
├── en_US.dart
└── es_ES.dart
```

---

## Exemplo de Uso

### 1. Definir Traduções

```dart
// lib/shared/translations/pt_BR.dart
class PtBR {
  static const Map<String, String> translations = {
    // Auth
    'login_title': 'Entrar',
    'login_email_label': 'E-mail',
    'login_password_label': 'Senha',
    'login_button': 'Entrar',
    'login_forgot_password': 'Esqueceu a senha?',
    'login_no_account': 'Não tem uma conta? Cadastre-se',
    
    // Onboarding
    'onboarding_welcome_title': 'Bem-vindo ao Pippo!',
    'onboarding_welcome_subtitle': 'Aprenda idiomas de forma divertida',
    'onboarding_select_language': 'Qual idioma você quer aprender?',
    'onboarding_continue': 'Continuar',
    
    // Home
    'home_courses': 'Cursos',
    'home_leaderboard': 'Ranking',
    'home_shop': 'Loja',
    'home_treasure': 'Missões',
    'home_profile': 'Perfil',
    
    // Lesson
    'lesson_correct': 'Correto!',
    'lesson_correct_subtitle': 'Isso mesmo!',
    'lesson_wrong': 'Ops!',
    'lesson_wrong_subtitle': 'Boa tentativa, mas não é bem assim.',
    'lesson_continue': 'Continuar',
    'lesson_got_it': 'Entendi',
    
    // Gamification
    'streak_title': 'Sequência de Dias',
    'streak_current': 'Dias consecutivos',
    'streak_longest': 'Maior sequência',
    'energy_title': 'Energia',
    'energy_full': 'Totalmente carregado ⚡ Pronto para começar?',
    'energy_low': 'Apenas um raio restante... use com sabedoria!',
    'energy_empty': 'Sem raios; Faça uma pausa...',
    'gems_title': 'Gems',
    
    // Errors
    'error_network': 'Verifique sua conexão com a internet',
    'error_generic': 'Algo deu errado. Tente novamente.',
    'error_insufficient_gems': 'Gems insuficientes',
  };
}
```

### 2. Configurar no App

```dart
// main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslations(), // classe que implementa Translations
      locale: Get.deviceLocale, // idioma do sistema
      fallbackLocale: Locale('pt', 'BR'), // fallback para português
      // ...
    );
  }
}

// lib/shared/translations/app_translations.dart
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'pt_BR': PtBR.translations,
    'en_US': EnUS.translations,
    'es_ES': EsES.translations,
  };
}
```

### 3. Usar nas Telas

```dart
// ✅ CORRETO - usar .tr
Text('login_title'.tr)
Text('onboarding_welcome_title'.tr)
AppButton(text: 'login_button'.tr)

// ❌ ERRADO - texto hardcoded
Text('Entrar')
Text('Bem-vindo ao Pippo!')
```

---

## Tela SelectLanguage

**IMPORTANTE**: Esta tela é para escolher qual idioma APRENDER (francês, espanhol, etc), **NÃO** o idioma da interface do app.

```dart
// SelectLanguagePage - escolher idioma para aprender
class SelectLanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('select_language_title'.tr), // "Qual idioma você quer aprender?"
      ),
      body: GridView(
        children: [
          LanguageCard(
            flag: 'fr.png',
            name: 'Francês', // nome do idioma em português
            code: 'fr',
          ),
          LanguageCard(
            flag: 'es.png',
            name: 'Espanhol',
            code: 'es',
          ),
          // ...
        ],
      ),
    );
  }
}
```

---

## Idioma do Sistema

O idioma da interface do app segue automaticamente o idioma do sistema do usuário:

```dart
// Configurado no GetMaterialApp
locale: Get.deviceLocale, // português, inglês, espanhol, etc
```

**Não criar tela de seleção de idioma do app!**

---

## Textos em Inglês no project.md

Alguns textos no `project.md` estão em inglês (ex: "Correct!", "That's right!"). 

**Estes devem ser traduzidos para português:**

```dart
// ❌ ERRADO (inglês)
'lesson_correct': 'Correct!',
'lesson_correct_subtitle': 'That\'s right!',

// ✅ CORRETO (português)
'lesson_correct': 'Correto!',
'lesson_correct_subtitle': 'Isso mesmo!',
```

---

## Mensagens de Erro

Todas as mensagens de erro devem estar em português e ser amigáveis:

```dart
// ✅ CORRETO
'error_email_invalid': 'Por favor, insira um e-mail válido',
'error_password_short': 'A senha deve ter pelo menos 6 caracteres',
'error_username_taken': 'Este username já está em uso',

// ❌ ERRADO
'error_email_invalid': 'Invalid email format',
'error_password_short': 'Password too short',
```

---

## Resumo

1. ✅ Interface do app: **PORTUGUÊS**
2. ✅ Sistema de tradução: **GetX Translate**
3. ✅ Criar telas em português, extrair para JSON
4. ✅ Usar `.tr` em todos os textos
5. ✅ SelectLanguage: escolher idioma para **APRENDER**
6. ✅ Idioma da interface: segue **sistema do usuário**
7. ❌ **NÃO** criar tela de seleção de idioma do app
