# Telas de Profile

> Documentação das telas de perfil do app Pippo

---

## Visão Geral

A feature Profile contém:
1. **Profile Page** — Perfil próprio do usuário
2. **User Profile Page** — Perfil de outro usuário
3. **Settings** — Configurações do app
4. **Edit Profile** — Edição de dados pessoais
5. **Notifications** — Configurações de notificações
6. **Learning Controls** — Controles de aprendizado
7. **Courses** — Gerenciamento de cursos
8. **Phone Number** — Vinculação de telefone

---

## Navegação

```
Profile Page
  │
  ├─► Settings ──► Edit Profile ──► Change Password
  │              │
  │              ├─► Phone Number ──► Verify Phone ──► Phone Linked
  │              │
  │              └─► Delete Account (modal)
  │
  ├─► Notifications
  │
  ├─► Learning Controls
  │
  ├─► Courses
  │
  └─► Friends (via following/followers)

User Profile Page (perfil de outro usuário)
  └─► Follow back
```

---

## 1. Profile (`features/inners/profile/`)

### Estrutura Atual

```
profile/
├── views/
│   ├── profile_page.dart
│   ├── user_profile_page.dart
│   ├── settings_page.dart
│   ├── edit_profile_page.dart
│   ├── change_password_page.dart
│   ├── phone_number_page.dart
│   ├── verify_phone_page.dart
│   ├── phone_linked_page.dart
│   ├── notifications_page.dart
│   ├── learning_controls_page.dart
│   └── courses_page.dart
└── widgets/
    ├── change_avatar_modal.dart
    ├── complete_profile_card.dart
    ├── confirm_delete_modal.dart
    ├── country_selector_modal.dart
    ├── course_item.dart
    ├── delete_account_modal.dart
    ├── notification_item.dart
    ├── overview_card.dart
    ├── overview_section.dart
    ├── profile_card.dart
    ├── profile_header.dart
    ├── reminder_time_modal.dart
    ├── settings_item.dart
    └── weekly_progress_chart.dart
```

### Fluxo de Telas

| Tela | Arquivo | Descrição |
|------|---------|-----------|
| Profile | `profile_page.dart` | Perfil próprio com overview |
| User Profile | `user_profile_page.dart` | Perfil de outro usuário |
| Settings | `settings_page.dart` | Menu de configurações |
| Edit Profile | `edit_profile_page.dart` | Edição de dados |
| Change Password | `change_password_page.dart` | Alteração de senha |
| Phone Number | `phone_number_page.dart` | Adicionar telefone |
| Verify Phone | `verify_phone_page.dart` | Verificar código SMS |
| Phone Linked | `phone_linked_page.dart` | Sucesso de vinculação |
| Notifications | `notifications_page.dart` | Config de notificações |
| Learning Controls | `learning_controls_page.dart` | Controles de aprendizado |
| Courses | `courses_page.dart` | Gerenciar cursos |

---

## Componentes por Tela

### Profile Page
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Header | `ProfileHeader` | SliverAppBar com card azul |
| Card | `ProfileCard` | Avatar, nome, stats |
| Complete | `CompleteProfileCard` | CTA para completar perfil |
| Overview | `OverviewSection` | XP, streak, level, badge |
| Bottom Bar | `AppBottombar` | Navegação principal |

### User Profile Page
| Componente | Widget | Descrição |
|------------|--------|-----------|
| AppBar | `AppBackButton` | Voltar |
| Card | `ProfileCard` | Com botão "Follow back" |
| Chart | `WeeklyProgressChart` | Gráfico comparativo |
| Overview | `OverviewSection` | Stats do usuário |

### Settings Page
| Componente | Widget | Descrição |
|------------|--------|-----------|
| AppBar | `AppBackButton` | Voltar + Save |
| Items | `SettingsItem` | Itens de menu |
| Logout | `AppButton` | Botão secundário |

### Edit Profile Page
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Avatar | Imagem + "Change avatar" | Troca de avatar |
| Fields | `AppTextField` | Nome, username, email |
| Phone | `AppTextField` | Navega para PhoneNumberPage |
| Buttons | `AppButton` | Change password, Delete |

### Notifications Page
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Items | `NotificationItem` | Toggle de notificações |
| Time | `ReminderTimeModal` | Seletor de horário |
| Restore | Botão customizado | Restaurar padrões |

### Learning Controls Page
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Items | `SettingsItem` | Toggles de controle |
| Cards | `_DisplayModeCard` | Seleção de modo |

### Courses Page
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Items | `CourseItem` | Bandeira + nome + delete |
| Modal | `ConfirmDeleteModal` | Confirmação de exclusão |

### Phone Flow
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Input | `mask_text_input_formatter` | Máscara de telefone |
| Country | `CountrySelectorModal` | Seletor de país |
| PIN | `AppPinput` | Código de verificação |
| Success | Mascote animado | Confirmação |

---

## Widgets Específicos

### ProfileCard
Card azul com avatar, nome, username e stats (following, followers, courses).

### ProfileHeader
SliverAppBar colapsável que contém o ProfileCard.

### OverviewCard (4 variações)
| Tipo | Conteúdo |
|------|----------|
| XP | Ícone + valor numérico |
| Streak | Ícone fogo + dias |
| Level | Bandeira + nível |
| Badge | Imagem do warrior |

### WeeklyProgressChart
Gráfico de linha com `syncfusion_flutter_charts` comparando progresso.

### SettingsItem
Item de menu com ícone, label e trailing (seta ou switch).

---

## Modais

| Modal | Arquivo | Descrição |
|-------|---------|-----------|
| Change Avatar | `change_avatar_modal.dart` | Grid de avatares |
| Delete Account | `delete_account_modal.dart` | Confirmação de exclusão |
| Confirm Delete | `confirm_delete_modal.dart` | Modal genérico de confirmação |
| Country Selector | `country_selector_modal.dart` | Lista de países |
| Reminder Time | `reminder_time_modal.dart` | CupertinoDatePicker |

---

## Widgets Globais Utilizados

| Widget | Arquivo | Uso |
|--------|---------|-----|
| `AppButton` | `shared/widgets/app_button.dart` | Botões de ação |
| `AppBackButton` | `shared/widgets/app_back_button.dart` | Voltar na AppBar |
| `AppTextField` | `shared/widgets/app_text_field.dart` | Campos de texto |
| `AppPinput` | `shared/widgets/app_pinput.dart` | Código de verificação |
| `AppBottombar` | `shared/widgets/app_bottombar.dart` | Navegação principal |
| `AppResendCode` | `shared/widgets/app_resend_code.dart` | Reenviar código |

---

## Packages Utilizados

| Package | Uso |
|---------|-----|
| `wolt_modal_sheet` | Modais (avatar, delete, country, time) |
| `syncfusion_flutter_charts` | Gráfico de progresso semanal |
| `mask_text_input_formatter` | Máscara de telefone |
| `flutter_svg` | Ícones SVG |

---

## Observações

- Profile Page usa `CustomScrollView` com `SliverAppBar`
- Navegação interna usa `Get.to()`
- Modais usam `wolt_modal_sheet` (padrão da empresa)
- Forms usam `StatefulWidget` com `TextEditingController`
- Dados mockados para fase de UI

