# UI Validator

## Description
Valida arquivos de UI (views, pages, widgets) seguindo TODOS os padrões e regras de steering. Corrige problemas automaticamente.

## Trigger
- event: onFileSave
- filePattern: "**/*_view.dart,**/*_page.dart,**/widgets/**/*.dart"

## Prompt
Você é um validador de UI para projetos Flutter. Ao salvar um arquivo de UI, você DEVE:

1. **Ler e seguir TODOS os arquivos de steering** da pasta `.kiro/steering/`, especialmente:
   - `code-rules.md` — Regras gerais de código
   - `architecture.md` — Estrutura e nomenclatura
   - `conventions.md` — Comentários e formatação
   - `project-structure.md` — Organização de arquivos e imports
   - `styling-guide.md` — Theme, fontes, ícones e packages de UI
   - `responsive.md` — Responsividade completa
   - `getx-patterns.md` — Padrões de Views (sem lógica)

2. **Verificar e corrigir automaticamente:**

   ### Sem Lógica de Negócio (Etapa 7)
   - ❌ Sem chamadas diretas ao Firebase/API
   - ❌ Sem manipulação de dados
   - ❌ Sem regras de negócio
   - ❌ Sem validações complexas
   - ❌ Sem `Get.find()`, `Get.put()`, `Obx()` (será adicionado na etapa 8)

   ### Comentários TODO para Etapa 8
   - Usar `// TODO: [etapa 8]` para marcar onde entrará lógica futuramente
   - Exemplos:
     ```dart
     // Para dados mockados
     // TODO: [etapa 8] substituir por dados do controller
     final mockUser = 'João Silva';
     final mockItems = ['Item 1', 'Item 2'];
     
     // Para botões de ação
     ElevatedButton(
       onPressed: () {
         // TODO: [etapa 8] conectar com controller.login()
       },
       child: Text('Entrar'),
     )
     
     // Para validadores em forms
     TextFormField(
       validator: (value) {
         // TODO: [etapa 8] mover para controller.validateEmail()
         if (value == null || value.isEmpty) return 'Campo obrigatório';
         return null;
       },
     )
     ```

   ### Responsividade (responsive.md)
   - ✅ Usar classe `Responsive` para dimensões e espaçamentos
   - ✅ Usar `SafeArea` ou considerar safe area paddings
   - ✅ Usar `SingleChildScrollView` em forms
   - ✅ Limitar largura em desktop com `maxContentWidth`
   - ❌ Nunca hardcodar valores de tamanho/espaçamento
   - ❌ Nunca usar `MediaQuery` diretamente

   ### Theme e Estilização (styling-guide.md)
   - ✅ Usar `AppTheme` para cores, fontes e estilos
   - ✅ Usar FontAwesome gratuito ou Fluent UI para ícones
   - ❌ Nunca espalhar nomes de fonte nas views
   - ❌ Nunca hardcodar cores

   ### Packages Padrão da Empresa
   - `wolt_modal_sheet` para modals/bottomsheets
   - `pie_menu` para menus contextuais
   - `popover` para conteúdo flutuante
   - `mask_text_input_formatter` para máscaras de input
   - `pinput` para PIN/OTP
   - `toggle_switch` para switches
   - `syncfusion_flutter_charts` para gráficos
   - `showcaseview` para onboarding

   ### Widget Type
   - StatelessWidget por padrão
   - StatefulWidget apenas para forms (com TextEditingController)

   ### Nomenclatura e Estrutura
   - Arquivos: snake_case (`login_view.dart`, `profile_page.dart`)
   - Classes: PascalCase (`LoginView`, `ProfilePage`)
   - Sufixo `_view.dart` para views principais
   - Sufixo `_page.dart` para páginas internas
   - Widgets globais com prefixo `app_`

   ### Imports (ordem correta)
   1. Dart SDK (`dart:async`)
   2. Flutter (`package:flutter/material.dart`)
   3. Packages externos (`package:get/get.dart`)
   4. Imports locais (`../controllers/...`)

   ### Código Enxuto
   - Espaçamentos corretos entre blocos lógicos
   - Comentários organizacionais (`// Widgets`, `// Lifecycle`, etc)
   - Comentários em português
   - Nomes de arquivos curtos
   - Mínimo de código sem perder funcionalidade

3. **Ao encontrar problemas:**
   - Dizer brevemente os problemas, de forma direta e clara
   - Resolvê-los automaticamente

4. **Ao finalizar:**
   - Confirmar que a UI segue todos os padrões
   - Listar `// TODO: [etapa 8]` pendentes se houver
