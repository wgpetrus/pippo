# Tradução e Idioma do App

> Sistema de internacionalização com GetX Translate

---

## Estado Atual do Projeto

### ✅ O que já temos implementado

| Item | Status | Detalhes |
|------|--------|----------|
| **GetX** | ✅ Instalado | Versão 4.6.6 no pubspec.yaml |
| **GetMaterialApp** | ✅ Configurado | Em `lib/main.dart` |
| **Todas as telas** | ✅ Implementadas | 43+ views/pages com textos hardcoded em português |
| **Widgets globais** | ✅ Criados | AppButton, AppTextField, AppAppbar, etc |
| **Theme** | ✅ Definido | Cores, fontes e estilos em `shared/theme/theme.dart` |
| **Estrutura de pastas** | ✅ Organizada | Features, shared, assets |

### ❌ O que NÃO temos (e vamos implementar)

| Item | Status |
|------|--------|
| **Pasta translations** | ❌ Não existe |
| **Arquivos de tradução** | ❌ Não existem (pt_BR.dart, en_US.dart, es_ES.dart) |
| **AppTranslations** | ❌ Não existe |
| **Uso de .tr** | ❌ Nenhum texto usa `.tr` ainda |
| **Configuração de locale** | ❌ Não configurado no GetMaterialApp |

### 📊 Resumo

- **43+ telas** já implementadas com textos hardcoded em português
- **Todos os textos** precisam ser extraídos para JSON
- **GetX já está pronto** para receber o sistema de tradução
- **Partimos da Etapa 2** (extração de textos)

---

## De Onde Partimos

**Estamos na Etapa 2 do fluxo:**

✅ **Etapa 1 COMPLETA** - Todas as telas já estão criadas com textos hardcoded em português

🔄 **Etapa 2 ATUAL** - Precisamos extrair todos os textos para JSON

⏳ **Etapa 3 PENDENTE** - Traduzir com IA

⏳ **Etapa 4 PENDENTE** - Implementar GetX Translate

---

## Fluxo de Trabalho (Ordem Obrigatória)

**⚠️ IMPORTANTE: Seguir esta ordem exata conforme definido pela empresa:**

### 1. Criar Todas as Telas Primeiro ✅ COMPLETO

~~Implementar todas as telas com textos **hardcoded em português**~~

**Status:** ✅ Já temos 43+ telas implementadas com textos em português

Exemplos do que já existe:
```dart
// signin_view.dart
AppAppbar(title: 'Entrar')
AppTextField(label: 'Usuário / e-mail', hint: 'digite seu usuário / e-mail')
AppTextField(label: 'Senha', hint: 'digite sua senha')

// welcome_view.dart
Text('Pronto para Começar sua Aventura?')

// user_name_page.dart
Text('Qual é o seu nome?')
Text('Nome')
```

---

### 2. Extrair Todos os Textos para JSON 🔄 ETAPA ATUAL

**Esta é a etapa que vamos implementar agora.**

Precisamos:
1. Percorrer todas as 43+ telas do projeto
2. Identificar todos os textos hardcoded
3. Criar chaves descritivas para cada texto
4. Gerar arquivo JSON com todos os textos

**Locais onde existem textos:**
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
- Widgets de features (modals, cards, etc)
- Widgets globais (AppButton, AppTextField, etc)

**Exemplo do que vamos fazer:**

```json
{
  "auth_signin_title": "Entrar",
  "auth_email_label": "Usuário / e-mail",
  "auth_email_hint": "digite seu usuário / e-mail",
  "auth_password_label": "Senha",
  "auth_password_hint": "digite sua senha",
  "onboarding_welcome_title": "Pronto para Começar sua Aventura?",
  "onboarding_name_question": "Qual é o seu nome?",
  "onboarding_name_label": "Nome"
}
```

---

### 3. Traduzir com IA ⏳ PENDENTE

Após extrair todos os textos, usar IA para traduzir o JSON para outros idiomas:

```json
// en_US.json
{
  "auth_signin_title": "Sign In",
  "auth_email_label": "Username / email",
  "auth_email_hint": "enter your username / email",
  "auth_password_label": "Password",
  "auth_password_hint": "enter your password"
}

// es_ES.json
{
  "auth_signin_title": "Iniciar Sesión",
  "auth_email_label": "Usuario / correo electrónico",
  "auth_email_hint": "ingresa tu usuario / correo electrónico",
  "auth_password_label": "Contraseña",
  "auth_password_hint": "ingresa tu contraseña"
}
```

---

### 4. Implementar GetX Translate ⏳ PENDENTE

Substituir todos os textos hardcoded por chaves com `.tr`:

```dart
// ANTES (estado atual)
AppAppbar(title: 'Entrar')
AppTextField(label: 'Usuário / e-mail', hint: 'digite seu usuário / e-mail')
AppButton(text: 'Continuar')

// DEPOIS (após implementação)
AppAppbar(title: 'auth_signin_title'.tr)
AppTextField(label: 'auth_email_label'.tr, hint: 'auth_email_hint'.tr)
AppButton(text: 'common_continue'.tr)
```

---

## Idioma da Interface

**O app deve estar em PORTUGUÊS por padrão**, mas suportar múltiplos idiomas.

- Interface: português (padrão)
- Mensagens de erro: português
- Notificações: português
- Feedback: português
- Idioma segue configuração do sistema do usuário

---

## Estrutura de Arquivos

```
lib/shared/translations/
├── app_translations.dart    # Classe principal
├── pt_BR.dart               # Português (padrão)
├── en_US.dart               # Inglês
└── es_ES.dart               # Espanhol
```

---

## Implementação GetX Translate

### 1. Criar Arquivos de Tradução

```dart
// lib/shared/translations/pt_BR.dart
class PtBR {
  static const Map<String, String> translations = {
    // Auth
    'login_welcome': 'Seja bem-vindo ao app Pippo!',
    'email_hint': 'Digite seu email',
    'password_hint': 'Digite sua senha',
    'login_button': 'Entrar',
    'forgot_password': 'Esqueceu a senha?',
    'no_account': 'Não tem uma conta? Cadastre-se',
    
    // Onboarding
    'onboarding_welcome': 'Bem-vindo ao Pippo!',
    'onboarding_subtitle': 'Aprenda idiomas de forma divertida',
    'select_language_title': 'Qual idioma você quer aprender?',
    'continue_button': 'Continuar',
    
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
    
    // Errors
    'error_network': 'Verifique sua conexão com a internet',
    'error_generic': 'Algo deu errado. Tente novamente.',
  };
}
```

```dart
// lib/shared/translations/en_US.dart
class EnUS {
  static const Map<String, String> translations = {
    'login_welcome': 'Welcome to Pippo app!',
    'email_hint': 'Enter your email',
    'password_hint': 'Enter your password',
    'login_button': 'Sign in',
    // ... resto das traduções
  };
}
```

### 2. Configurar AppTranslations

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

### 3. Configurar no main.dart

```dart
// main.dart
import 'shared/translations/app_translations.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: Get.deviceLocale, // idioma do sistema
      fallbackLocale: Locale('pt', 'BR'), // fallback para português
      // ...
    );
  }
}
```

### 4. Usar nas Telas

```dart
// Textos simples
Text('login_welcome'.tr)
Text('home_courses'.tr)

// Em widgets
AppButton(text: 'login_button'.tr)
AppTextField(hintText: 'email_hint'.tr)

// Em AppBar
AppAppbar(title: 'home_profile'.tr)
```

---

## Padrão de Nomenclatura de Chaves

### Estrutura

```
[contexto]_[elemento/acao]
```

### Exemplos Baseados no Projeto Atual

| Contexto | Chave | Valor Atual |
|----------|-------|-------------|
| Auth | `auth_signin_title` | "Entrar" |
| Auth | `auth_email_label` | "Usuário / e-mail" |
| Auth | `auth_email_hint` | "digite seu usuário / e-mail" |
| Auth | `auth_password_label` | "Senha" |
| Auth | `auth_password_hint` | "digite sua senha" |
| Auth | `auth_forgot_password` | "Esqueceu sua senha" |
| Onboarding | `onboarding_welcome_title` | "Pronto para Começar sua Aventura?" |
| Onboarding | `onboarding_name_question` | "Qual é o seu nome?" |
| Onboarding | `onboarding_name_label` | "Nome" |
| Onboarding | `onboarding_age_question` | "Quantos anos você tem?" |
| Common | `common_continue` | "Continuar" |
| Common | `common_cancel` | "Cancelar" |
| Error | `error_network` | "Verifique sua conexão" |
| Profile | `profile_edit` | "Editar perfil" |
| Settings | `settings_notifications` | "Notificações" |

### Regras

- ✅ Usar snake_case
- ✅ Prefixo com contexto (tela/feature)
- ✅ Descritivo e curto
- ✅ Agrupar textos comuns (continue, cancel, save, etc) em `common_`
- ❌ Não usar espaços ou caracteres especiais
- ❌ Não usar acentos nas chaves

---

## Importante: SelectLanguage

**ATENÇÃO**: A tela `SelectLanguagePage` é para escolher qual **idioma APRENDER** (francês, espanhol, etc), **NÃO** o idioma da interface do app.

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
        ],
      ),
    );
  }
}
```

**O idioma da interface do app segue automaticamente o sistema do usuário.**

---

## Checklist de Implementação

### Etapa 1: Criar Telas
- [ ] Implementar todas as telas com textos hardcoded em português
- [ ] Revisar todas as telas para garantir textos em português
- [ ] Não usar `.tr` ainda

### Etapa 2: Extrair Textos
- [ ] Criar arquivo JSON com todos os textos
- [ ] Definir chaves descritivas seguindo padrão
- [ ] Organizar por contexto/feature
- [ ] Revisar para não esquecer nenhum texto

### Etapa 3: Traduzir
- [ ] Usar IA para traduzir JSON para inglês
- [ ] Usar IA para traduzir JSON para espanhol
- [ ] Revisar traduções para garantir qualidade
- [ ] Criar arquivos pt_BR.dart, en_US.dart, es_ES.dart

### Etapa 4: Implementar GetX
- [ ] Criar AppTranslations
- [ ] Configurar no main.dart
- [ ] Substituir todos os textos hardcoded por `.tr`
- [ ] Testar troca de idioma
- [ ] Verificar fallback para português

---

## Resumo

1. ✅ **Criar todas as telas primeiro** com textos hardcoded em português
2. ✅ **Extrair todos os textos** para JSON com chaves descritivas
3. ✅ **Traduzir com IA** para outros idiomas
4. ✅ **Implementar GetX Translate** substituindo textos por `.tr`
5. ✅ Interface em **português por padrão**
6. ✅ Idioma da interface segue **sistema do usuário**
7. ✅ SelectLanguage é para escolher idioma **para aprender**
8. ❌ **NÃO** criar tela de seleção de idioma do app
