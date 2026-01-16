# Navegação - Pippo

> Navegação implementada com telas funcionais

---

## Status

| Fluxo | Status | Observação |
|-------|--------|------------|
| Splash | ✅ Completo | Navega para /home (temporário) |
| Onboarding | ✅ UI Completa | 14 telas implementadas |
| Auth | ✅ UI Completa | 4 telas implementadas |
| Home | ✅ UI Completa | 5 tabs funcionando |
| Lesson | ✅ UI Completa | 6 telas de exercícios |
| Profile | ✅ UI Completa | 11 telas implementadas |

---

## Fluxo de Onboarding

### Telas Implementadas

1. **welcome_view.dart** - Tela inicial com mascote
2. **select_language_page.dart** - Escolha do idioma
3. **language_level_page.dart** - Nível de conhecimento
4. **learning_reason_page.dart** - Motivo do aprendizado
5. **intro_page.dart** - Transição animada
6. **study_time_page.dart** - Tempo de estudo diário
7. **pause_one_page.dart** - Transição com mascote
8. **user_name_page.dart** - Nome do usuário
9. **user_age_page.dart** - Idade do usuário
10. **pause_two_page.dart** - Transição com mascote
11. **user_email_page.dart** - Email do usuário
12. **user_password_page.dart** - Senha do usuário
13. **verify_code_page.dart** - Verificação OTP
14. **conclusion_page.dart** - Conclusão do onboarding

### Widgets do Onboarding
- `bouncing_mascot.dart` - Mascote com animação
- `onboarding_header.dart` - Header com progress bar
- `onboarding_text_field.dart` - Input customizado
- `option_card.dart` - Card de opção selecionável
- `progress_bar.dart` - Barra de progresso

---

## Fluxo de Auth

### Telas Implementadas

1. **signin_view.dart** - Login com email/senha
2. **forgot_password_view.dart** - Recuperação de senha
3. **verify_code_view.dart** - Verificação OTP
4. **new_password_view.dart** - Nova senha

### Widgets do Auth
- `social_button.dart` - Botão de login social

---

## Fluxo Home (Tabs)

### Telas Implementadas

1. **home_view.dart** - Container com IndexedStack
2. **leaderboard_page.dart** - Tab de ranking
3. **shop_page.dart** - Tab de loja
4. **treasure_page.dart** - Tab de missões
5. **profile_page.dart** - Tab de perfil

### Widgets do Home
- `home_appbar.dart` - AppBar com stats
- `courses_modal.dart` - Modal de cursos
- `energy_modal.dart` - Modal de energia
- `gems_modal.dart` - Modal de gems
- `streak_modal.dart` - Modal de streak
- `lesson_popover.dart` - Popover de lição
- `lesson_tooltip.dart` - Tooltip de lição
- `unit_header.dart` - Header de unidade

---

## Fluxo de Lesson

### Telas Implementadas

1. **sections_page.dart** - Lista de seções/unidades
2. **image_exercise_page.dart** - Exercício de imagem
3. **translation_exercise_page.dart** - Exercício de tradução
4. **word_exercise_page.dart** - Exercício de palavras
5. **match_exercise_page.dart** - Exercício de combinação
6. **complete_page.dart** - Tela de conclusão

### Widgets do Lesson
- `audio_card.dart` - Card com áudio
- `audio_word_button.dart` - Botão de palavra com áudio
- `exercise_header.dart` - Header do exercício
- `feedback_bottom_sheet.dart` - Feedback de resposta
- `image_with_label.dart` - Imagem com label
- `lesson_option_card.dart` - Card de opção
- `low_energy_modal.dart` - Modal sem energia
- `mascot_bubble.dart` - Balão do mascote
- `section_card.dart` - Card de seção
- `word_chip.dart` - Chip de palavra
- `word_zone.dart` - Zona de palavras

---

## Fluxo de Profile

### Telas Implementadas

1. **profile_page.dart** - Tab principal
2. **user_profile_page.dart** - Visualizar perfil
3. **edit_profile_page.dart** - Editar perfil
4. **settings_page.dart** - Configurações
5. **notifications_page.dart** - Notificações
6. **learning_controls_page.dart** - Controles de aprendizado
7. **courses_page.dart** - Gerenciar cursos
8. **change_password_page.dart** - Alterar senha
9. **phone_number_page.dart** - Adicionar telefone
10. **verify_phone_page.dart** - Verificar telefone
11. **phone_linked_page.dart** - Telefone vinculado

### Widgets do Profile
- `change_avatar_modal.dart` - Modal de avatar
- `complete_profile_card.dart` - Card de completar perfil
- `confirm_delete_modal.dart` - Confirmação de exclusão
- `country_selector_modal.dart` - Seletor de país
- `course_item.dart` - Item de curso
- `delete_account_modal.dart` - Modal de exclusão
- `overview_card.dart` - Card de overview
- `overview_section.dart` - Seção de overview
- `profile_card.dart` - Card do perfil
- `profile_header.dart` - Header do perfil
- `reminder_time_modal.dart` - Modal de lembrete
- `weekly_progress_chart.dart` - Gráfico semanal
