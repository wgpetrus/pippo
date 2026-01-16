# UI Profile - Pippo

> Telas de perfil e configurações

---

## Telas

| Tela | Arquivo | Status |
|------|---------|--------|
| Profile | profile_page.dart | ✅ UI Completa |
| User Profile | user_profile_page.dart | ✅ UI Completa |
| Edit Profile | edit_profile_page.dart | ✅ UI Completa |
| Settings | settings_page.dart | ✅ UI Completa |
| Notifications | notifications_page.dart | ✅ UI Completa |
| Learning Controls | learning_controls_page.dart | ✅ UI Completa |
| Courses | courses_page.dart | ✅ UI Completa |
| Change Password | change_password_page.dart | ✅ UI Completa |
| Phone Number | phone_number_page.dart | ✅ UI Completa |
| Verify Phone | verify_phone_page.dart | ✅ UI Completa |
| Phone Linked | phone_linked_page.dart | ✅ UI Completa |

---

## profile_page.dart (Tab)

### Componentes
- ProfileHeader (avatar, nome, stats)
- CompleteProfileCard (se incompleto)
- OverviewSection
- OverviewCard (XP, streak, etc)
- WeeklyProgressChart

---

## user_profile_page.dart

### Componentes
- AppAppbar com botão Settings
- ProfileCard (avatar grande, nome, bio)
- Estatísticas detalhadas
- Lista de conquistas

---

## edit_profile_page.dart

### Componentes
- AppAppbar "Edit Profile" com Save
- Avatar com botão de editar
- AppTextField (Name)
- AppTextField (Username)
- AppTextField (Bio)
- CountrySelectorModal

---

## settings_page.dart

### Componentes
- AppAppbar "Settings"
- Seção "Account"
  - AppListItem "Profile"
  - AppListItem "Notifications"
  - AppListItem "Learning Controls"
  - AppListItem "Courses"
- Seção "Security"
  - AppListItem "Change Password"
  - AppListItem "Phone Number"
- Seção "Danger Zone"
  - AppListItem "Delete Account" (vermelho)

---

## notifications_page.dart

### Componentes
- AppAppbar "Notifications"
- AppListItem com Switch (Practice reminders)
- AppListItem (Reminder time) - abre ReminderTimeModal
- AppListItem com Switch (Leaderboard updates)
- AppListItem com Switch (Friend activity)

---

## learning_controls_page.dart

### Componentes
- AppAppbar "Learning Controls"
- AppListItem com Switch (Sound effects)
- AppListItem com Switch (Listening exercises)
- AppListItem com Switch (Speaking exercises)
- AppListItem (Daily goal) - abre modal

---

## courses_page.dart

### Componentes
- AppAppbar "Courses"
- Lista de CourseItem (cursos ativos)
- AppButton "Add Course"

---

## change_password_page.dart

### Componentes
- AppAppbar "Change Password"
- AppTextField (Current Password)
- AppTextField (New Password)
- AppTextField (Confirm Password)
- AppButton "Update Password"

---

## phone_number_page.dart

### Componentes
- AppAppbar "Phone Number"
- CountrySelectorModal (código do país)
- AppTextField (Phone number)
- AppButton "Send Code"

---

## verify_phone_page.dart

### Componentes
- AppAppbar "Verify Phone"
- Texto com número mascarado
- AppPinput (6 dígitos)
- AppResendCode
- AppButton "Verify"

---

## phone_linked_page.dart

### Componentes
- Ícone de sucesso
- Título "Phone Linked!"
- Texto de confirmação
- AppButton "Done"

---

## Widgets da Feature

### change_avatar_modal.dart
Modal para trocar avatar.

### complete_profile_card.dart
Card incentivando completar perfil.

### confirm_delete_modal.dart
Modal de confirmação final de exclusão.

### country_selector_modal.dart
Modal para selecionar país/código.

### course_item.dart
Item de curso na lista.

### delete_account_modal.dart
Modal de exclusão de conta.

### overview_card.dart
Card de estatística (XP, streak, etc).

### overview_section.dart
Seção de overview com título.

### profile_card.dart
Card principal do perfil.

### profile_header.dart
Header do perfil com avatar e stats.

### reminder_time_modal.dart
Modal para selecionar horário de lembrete.

### weekly_progress_chart.dart
Gráfico de progresso semanal.
