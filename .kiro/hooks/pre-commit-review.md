# Pre-Commit Review

## Description
Revisão geral antes de commitar seguindo TODOS os padrões e regras de steering. Corrige problemas automaticamente.

## Trigger
- event: onManual
- label: "🔍 Pre-Commit Review"

## Prompt
Você é um revisor de código para projetos Flutter. Ao ser acionado manualmente antes de um commit, você DEVE:

1. **Ler e seguir TODOS os arquivos de steering** da pasta `.kiro/steering/` e `.kiro/steering/docs`:
   - `code-rules.md` — Regras gerais
   - `architecture.md` — Estrutura e nomenclatura
   - `conventions.md` — Comentários e formatação
   - `project-structure.md` — Organização de arquivos
   - `getx-patterns.md` — Padrões GetX
   - `forms-validation.md` — Validação de forms
   - `firebase.md` — Error handlers
   - `styling-guide.md` — Theme e packages de UI
   - `responsive.md` — Responsividade
   - `security-storage.md` — Segurança

2. **Revisar TODOS os arquivos modificados** e verificar:

   ### Estrutura de Pastas
   - Cada page na sua feature (não tudo em home)
   - Arquivos na pasta correta (`views/`, `controllers/`, `widgets/`, `bindings/`)
   - Widgets globais em `shared/widgets/` com prefixo `app_`
   - Widgets específicos na pasta da feature

   ### Nomenclatura
   - Arquivos: snake_case
   - Classes: PascalCase
   - Variáveis/Métodos: camelCase
   - Constantes: UPPER_SNAKE_CASE
   - Sufixos corretos (`_view.dart`, `_page.dart`, `_controller.dart`, `_binding.dart`)

   ### TODOs Pendentes (Etapa 8)
   - Listar todos os `// TODO: [etapa 8]`
   - Alertar se houver TODOs que deveriam ter sido substituídos (se já estiver na etapa 8)

   ### Segurança
   - ❌ Sem chaves de API hardcoded
   - ❌ Sem logs de dados sensíveis (senhas, tokens, CPF)
   - ✅ SecureStorage para dados sensíveis
   - ✅ SharedPreferences para dados não sensíveis

   ### Packages Padrão
   - Verificar se usa packages aprovados da empresa
   - `wolt_modal_sheet`, `pie_menu`, `popover`, `pinput`, etc para UI
   - `uuid` v5 para dados pessoais
   - `flutter_secure_storage` para dados sensíveis

   ### Imports
   - Ordem correta em todos os arquivos:
     1. Dart SDK
     2. Flutter
     3. Packages externos
     4. Imports locais

   ### Código Enxuto
   - Sem complexidade desnecessária
   - Espaçamentos corretos
   - Comentários organizacionais
   - Comentários em português
   - Nomes de arquivos curtos

   ### Views
   - Sem lógica de negócio
   - StatelessWidget padrão
   - StatefulWidget só para forms
   - Responsividade com `Responsive`
   - Theme com `AppTheme`

   ### Controllers
   - Estados obrigatórios (`isLoading.obs`, `errorMessage.obs`)
   - Sem TextEditingController
   - Sem Streams
   - Firebase handlers padronizados
   - Mensagens em português e amigáveis

   ### Testes
   - Estrutura espelhando `lib/`
   - Sufixo `_test.dart`

3. **Ao encontrar problemas:**
   - Corrigir automaticamente
   - Explicar brevemente o que foi corrigido

4. **Ao finalizar, gerar relatório:**
   ```
   ✅ Estrutura de pastas: OK
   ✅ Nomenclatura: OK
   ⚠️ TODOs [etapa 8] pendentes: 3 encontrados
   ✅ Segurança: OK
   ✅ Packages: OK
   ✅ Imports: OK
   ✅ Código enxuto: OK
   
   Sugestão de commit: feat: implementa tela de login
   ```

5. **Sugerir mensagem de commit** seguindo padrão:
   - `feat:` nova funcionalidade
   - `fix:` correção de bug
   - `refactor:` refatoração sem mudar comportamento
   - `chore:` manutenção (deps, configs)
