# Regras de Código

> **⚠️ CÓDIGO ENXUTO É OBRIGATÓRIO. NADA DE COMPLEXIDADE DESNECESSÁRIA.**
>
> O principal problema a evitar: **controllers complexos com managers, sets, streams, validação em tempo real.**
> O padrão é simples: TextEditingController na View, validator do widget, submit valida tudo.

---

## Princípios Gerais

- **Nomes de arquivos curtos** — evitar nomes extensos
- **Espaçamentos corretos** — separar blocos lógicos com linha em branco
- **Comentários organizacionais** — usar para separar seções do código
- **Código enxuto** — mínimo possível sem perder funcionalidade

---

## Documentação Detalhada

- [Arquitetura](architecture.md) — Estrutura de pastas, navegação, nomenclatura
- [Fluxo de Desenvolvimento](dev-flow.md) — Etapas do desenvolvimento
- [Padrões GetX](getx-patterns.md) — Controllers, Views, Obx, Navegação
- [Validação de Forms](forms-validation.md) — Padrão de formulários
- [Firebase](firebase.md) — Error handlers, conversão de datas
- [Estrutura do Projeto](project-structure.md) — Organização de arquivos e imports
- [Guia de Estilização](styling-guide.md) — Theme, fontes e ícones
- [Responsividade](responsive.md) — Breakpoints, SafeArea, dimensões responsivas
- [Segurança e Armazenamento](security-storage.md) — SharedPreferences, SecureStorage, regras de segurança
- [Convenções](conventions.md) — Comentários, mensagens e formatação de dados

---

## Resumo

| Regra | Obrigatório |
|-------|-------------|
| Responsividade com classe Responsive | ✅ SIM |
| Código enxuto, sem complexidade | ✅ SIM |
| Controller com isLoading e errorMessage | ✅ SIM |
| TextEditingController na View, não no Controller | ✅ SIM |
| View sem lógica de negócio | ✅ SIM |
| StatelessWidget padrão, StatefulWidget só para forms | ✅ SIM |
| Obx() apenas onde é reativo | ✅ SIM |
| Fontes e padrões de estilo centralizadas em theme | ✅ SIM |
| FontAwesome gratuito para ícones | ✅ SIM |
| Packages de UI padrão da empresa | ✅ SIM |
| Comentários em português | ✅ SIM |
| Get.offAllNamed() apenas após login/logout/onboarding completo | ✅ SIM |
| Get.toNamed() para navegação com possibilidade de voltar | ✅ SIM |
| Cada page na sua feature (não tudo em home) | ✅ SIM |
| Cada arquivo na pasta correta | ✅ SIM |
| SharedPreferences para dados não sensíveis | ✅ SIM |
| SecureStorage para dados sensíveis | ✅ SIM |
| Nunca logar dados sensíveis | ✅ SIM |
| Nomes de arquivos curtos | ✅ SIM |
| Espaçamentos corretos no código | ✅ SIM |
| Comentários organizacionais | ✅ SIM |

---

## Packages de UI Padrão

> **⚠️ IMPORTANTE: Usar os packages aprovados pela empresa antes de buscar alternativas.**

Ver detalhes e exemplos em [styling-guide.md](styling-guide.md).

| Package | Quando Usar |
|---------|-------------|
| `wolt_modal_sheet` | Modals, bottomsheets etc |
| `pie_menu` | Menus de ações contextuais (dots) etc |
| `popover` | Conteúdo flutuante etc |
| `mask_text_input_formatter` | Máscaras de input (telefone, CPF, data) etc |
| `pinput` | Input de PIN/OTP etc |
| `toggle_switch` | Switches com opções etc |
| `syncfusion_flutter_charts` | Gráficos (linha, barra, pizza etc) etc |
| `showcaseview` | Onboarding, tutoriais interativos etc |
| `uuid` | Geração de IDs (usar v5 para dados pessoais) etc |
