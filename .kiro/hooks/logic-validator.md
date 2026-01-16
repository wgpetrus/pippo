# Logic Validator

## Description
Valida arquivos de lógica (controllers, testes) seguindo TODOS os padrões e regras de steering. Corrige problemas automaticamente.

## Trigger
- event: onFileSave
- filePattern: "**/*_controller.dart,**/*_test.dart"

## Prompt
Você é um validador de lógica para projetos Flutter. Ao salvar um arquivo de controller ou teste, você DEVE:

1. **Ler e seguir TODOS os arquivos de steering** da pasta `.kiro/steering/`, especialmente:
   - `code-rules.md` — Regras gerais de código
   - `getx-patterns.md` — Padrões de Controllers
   - `forms-validation.md` — Validação de formulários
   - `firebase.md` — Error handlers padronizados
   - `security-storage.md` — Segurança e armazenamento
   - `conventions.md` — Comentários e formatação
   - `project-structure.md` — Organização de arquivos e imports
   - `architecture.md` — Estrutura de testes

2. **Verificar e corrigir automaticamente:**

   ### Controllers - Estados Obrigatórios
   ```dart
   // Todo controller DEVE ter:
   final isLoading = false.obs;
   final errorMessage = ''.obs;
   ```

   ### Controllers - Proibições
   - ❌ Sem `TextEditingController` (fica na View)
   - ❌ Sem `Stream`, `StreamController`, `StreamSubscription` (usar `.obs`)
   - ❌ Sem `Set<String>` para tracking
   - ❌ Sem classes tipo `ValidationManager`, `FormManager`
   - ❌ Sem lógica complexa de validação
   - ❌ Sem complexidade desnecessária

   ### Validadores
   - Simples, retornam `String?`
   - Sem side effects
   - Mensagens em português e amigáveis
   ```dart
   String? validateEmail(String? value) {
     if (value == null || value.isEmpty) return 'E-mail é obrigatório.';
     if (!GetUtils.isEmail(value)) return 'Por favor, insira um e-mail válido.';
     return null;
   }
   ```

   ### Firebase Handlers (firebase.md)
   - Usar `_handleFirebaseLoginError()` para login
   - Usar `_handleFirebaseRegisterError()` para registro
   - Usar `_handleFirebaseResetPasswordError()` para reset
   - Usar `_handleFirestoreError()` para Firestore

   ### Navegação
   - Usar `Get.offAllNamed()` após login/logout para limpar stack

   ### Segurança (security-storage.md)
   - ❌ Nunca logar dados sensíveis (senhas, tokens, CPF)
   - ✅ Usar `SecureStorage` para tokens e dados sensíveis
   - ✅ Usar `SharedPreferences` para dados não sensíveis
   - ❌ Nunca hardcodar chaves de API
   - ✅ Limpar dados no logout

   ### Packages Padrão
   - `uuid` v5 para dados pessoais (determinístico)
   - `flutter_secure_storage` para dados sensíveis

   ### Testes (architecture.md)
   - Estrutura espelhando `lib/`
   - Sufixo `_test.dart` obrigatório
   - Testar controllers e widgets reutilizáveis
   - Views não precisam de testes

   ### Nomenclatura
   - Arquivos: snake_case (`auth_controller.dart`)
   - Classes: PascalCase (`AuthController`)
   - Sufixo `_controller.dart` para controllers

   ### Imports (ordem correta)
   1. Dart SDK (`dart:async`)
   2. Flutter (`package:flutter/material.dart`)
   3. Packages externos (`package:get/get.dart`)
   4. Imports locais (`../controllers/...`)

   ### Código Enxuto
   - Espaçamentos corretos entre blocos lógicos
   - Comentários organizacionais (`// Estados`, `// Lifecycle`, `// Métodos públicos`, `// Métodos privados`, `// Validadores`)
   - Comentários em português
   - Nomes de arquivos curtos
   - Mínimo de código sem perder funcionalidade

   ### Mensagens de Erro
   - Em português
   - Amigáveis (nunca técnicas)
   ```dart
   // ✅ CORRETO
   errorMessage.value = 'Não foi possível fazer login. Tente novamente.';
   
   // ❌ ERRADO
   errorMessage.value = 'FirebaseAuthException: user-not-found';
   ```

3. **Ao encontrar problemas:**
   - Dizer brevemente os problemas, de forma direta e clara
   - Resolvê-los automaticamente

4. **Ao finalizar:**
   - Confirmar que o código segue todos os padrões
   - Alertar sobre possíveis problemas de segurança se houver
