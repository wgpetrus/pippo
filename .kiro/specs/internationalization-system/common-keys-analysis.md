# Common Keys Analysis

## Methodology

Analyzed all extracted JSON files to identify texts that appear in 3+ locations across different features. These texts should be consolidated into `common_` prefixed keys for consistency and maintainability.

## Identified Common Texts

### 1. Action Buttons

#### "Continuar" / Continue
**Occurrences: 10+ locations**
- `onboarding_welcome_button_start` → "Começar" (similar action)
- `onboarding_intro_button` → "Começar"
- `onboarding_pause_one_button` → "Próximo"
- `onboarding_pause_two_button` → "Vamos lá"
- `onboarding_conclusion_button` → "Vamos Aprender"
- `lesson_feedback_correct_button` → "Continuar"
- `onboarding_header_exit_dialog_cancel` → "Continuar Cadastro"
- `lesson_exit_confirmation_continue_button` → "Continuar Lição"
- `common_continue` → "Continuar" (already exists in onboarding)

**Recommendation:** Create `common_continue` = "Continuar"

#### "Cancelar" / Cancel
**Occurrences: 12+ locations**
- `auth_cancel_button` (appears 2x in auth)
- `onboarding_user_password_button_cancel` → "Cancelar"
- `onboarding_verify_code_button_cancel` → "Cancelar"
- `onboarding_conclusion_button_cancel` → "Cancelar"
- `shop_confirmation_cancel` → "Cancelar"
- `treasure_delete_cancel_button` → "Cancelar"
- `courses_delete_cancel` → "Cancelar"
- `confirm_delete_cancel` → "Cancelar"
- `delete_account_cancel` → "Cancelar"
- `reauthenticate_cancel` → "Cancelar"

**Recommendation:** Create `common_cancel` = "Cancelar"

#### "Salvar" / Save
**Occurrences: 5 locations**
- `profile_edit_save` → "Salvar"
- `change_avatar_save` → "Salvar"
- `change_password_save` → "Salvar"
- `phone_number_save` → "Salvar"
- `reminder_time_save` → "Salvar"

**Recommendation:** Create `common_save` = "Salvar"

#### "Verificar" / Verify
**Occurrences: 4 locations**
- `auth_verify_button` → "Verificar"
- `onboarding_verify_code_button_verify` → "Verify"
- `verify_phone_verify` → "Verificar"
- `lesson_*_check_button` → "Verificar" (4 exercise types)

**Recommendation:** Create `common_verify` = "Verificar"

#### "Próximo" / Next
**Occurrences: 3 locations**
- `onboarding_pause_one_button` → "Próximo"
- `phone_number_next` → "Próximo"
- Implicit in many continue flows

**Recommendation:** Create `common_next` = "Próximo"

### 2. Error Handling

#### "Tentar novamente" / Try Again
**Occurrences: 8 locations**
- `profile_try_again` → "Tentar novamente" (appears 2x)
- `leaderboard_try_again` → "Tentar novamente"
- `treasure_try_again` → "Tentar novamente"
- `courses_try_again` → "Tentar Novamente"
- `friends_retry_button` → "Tentar novamente"
- `splash_retry_button` → "Tentar novamente"

**Recommendation:** Create `common_try_again` = "Tentar novamente"

#### "Erro" / Error
**Occurrences: 10+ locations**
- `lesson_sections_error_snackbar_title` → "Erro"
- `home_energy_modal_error_title` → "Erro"
- `treasure_delete_error_title` → "Erro"
- `treasure_generate_error_title` → "Erro"
- Various error messages across features

**Recommendation:** Create `common_error` = "Erro"

#### "Sucesso" / Success
**Occurrences: 3 locations**
- `home_energy_modal_success_title` → "Sucesso"
- `treasure_delete_success_title` → "Sucesso"
- `treasure_generate_success_title` → "Sucesso"

**Recommendation:** Create `common_success` = "Sucesso"

### 3. Form Fields

#### "E-mail" Label and Hint
**Occurrences: 5+ locations**
- `auth_email_label` → "E-mail" / "Usuário / e-mail"
- `auth_email_hint` → "Digite seu e-mail" / "digite seu usuário / e-mail"
- `onboarding_user_email_label` → "E-mail"
- `onboarding_user_email_hint` → "digite seu e-mail"
- `profile_edit_email_label` → "E-mail"
- `profile_edit_email_hint` → "seu e-mail"

**Recommendation:** 
- `common_email_label` = "E-mail"
- `common_email_hint` = "digite seu e-mail"

#### "Senha" / Password Label and Hint
**Occurrences: 8+ locations**
- `auth_password_label` → "Senha"
- `auth_password_hint` → "digite sua senha"
- `auth_new_password_label` → "Nova senha"
- `auth_confirm_password_label` → "Confirmar senha"
- `onboarding_user_password_label` → "Senha"
- `onboarding_user_password_confirm_label` → "Confirmar Senha"
- `change_password_current_label` → "Senha Atual"
- `change_password_new_label` → "Nova Senha"
- `change_password_confirm_label` → "Confirmar senha"
- `reauthenticate_password_label` → "Senha"

**Recommendation:**
- `common_password_label` = "Senha"
- `common_password_hint` = "digite sua senha"
- `common_new_password_label` = "Nova senha"
- `common_confirm_password_label` = "Confirmar senha"
- `common_confirm_password_hint` = "repita sua senha"

#### "Nome" / Name Label and Hint
**Occurrences: 3 locations**
- `onboarding_user_name_label` → "Nome"
- `onboarding_user_name_hint` → "digite seu nome"
- `profile_edit_name_label` → "Nome"
- `profile_edit_name_hint` → "digite seu nome"

**Recommendation:**
- `common_name_label` = "Nome"
- `common_name_hint` = "digite seu nome"

### 4. Titles

#### "Perfil" / Profile
**Occurrences: 4 locations**
- `profile_title` → "Perfil" (appears 3x in profile pages)
- `profile_edit_title` → "Perfil"
- `settings_profile` → "Perfil"
- `home_profile_tab` → "Perfil"

**Recommendation:** Create `common_profile` = "Perfil"

#### "Configurações" / Settings
**Occurrences: 2 locations**
- `settings_title` → "Configurações"
- Implicit in navigation

**Note:** Only 2 occurrences, but it's a common navigation term. Consider for common keys.

### 5. Validation Errors

#### Email Validation
**Occurrences: 3+ locations**
- `error_email_required` → "E-mail é obrigatório."
- `error_email_invalid` → "Por favor, insira um e-mail válido."
- `onboarding_user_email_error_invalid` → "E-mail inválido"

**Recommendation:**
- `error_email_required` = "E-mail é obrigatório."
- `error_email_invalid` = "Por favor, insira um e-mail válido."

#### Password Validation
**Occurrences: 5+ locations**
- `error_password_required` → "Senha é obrigatória."
- `error_password_min_length` → "A senha deve ter pelo menos 6 caracteres."
- `error_confirm_password_required` → "Confirmação de senha é obrigatória."
- `error_passwords_dont_match` → "As senhas não coincidem."
- `onboarding_user_password_error_mismatch` → "As senhas não coincidem."

**Recommendation:**
- `error_password_required` = "Senha é obrigatória."
- `error_password_min_length` = "A senha deve ter pelo menos 6 caracteres."
- `error_confirm_password_required` = "Confirmação de senha é obrigatória."
- `error_passwords_dont_match` = "As senhas não coincidem."

### 6. Global Widget Texts (Already Identified)

From `extracted-texts-global.json`:
- `common_didnt_receive` = "Não recebeu?"
- `common_tap_to_resend` = "Toque para reenviar."
- `common_resend_code_in` = "Reenviar código em"

### 7. Confirmation Dialogs

#### Exit/Delete Confirmations
**Occurrences: 5+ locations**
- `onboarding_header_exit_dialog_title` → "Sair do Cadastro?"
- `lesson_exit_confirmation_title` → "Sair da lição?"
- `treasure_delete_confirm_title` → "Deletar Todos os Desafios?"
- `courses_delete_title` → "Dizer Adeus a Este Curso?"
- `delete_account_title` → "Excluir Conta"
- `confirm_delete_title` → "Confirmação Final"

**Note:** These are context-specific, but the pattern of confirmation dialogs is common.

### 8. Loading States

#### "Carregando..." / Loading
**Occurrences: Implicit in multiple locations**
- `treasure_deleting` → "Deletando..."
- `treasure_generating` → "Gerando desafios..."
- `confirm_delete_deleting` → "Excluindo..."

**Recommendation:** Create `common_loading` = "Carregando..."

### 9. Empty States

#### "Não encontrado" / Not Found
**Occurrences: 4 locations**
- `lesson_sections_loading` → "Exercício não encontrado"
- `lesson_image_exercise_not_found` → "Exercício não encontrado"
- `lesson_translation_exercise_not_found` → "Exercício não encontrado"
- `lesson_word_exercise_not_found` → "Exercício não encontrado"
- `lesson_match_exercise_not_found` → "Exercício não encontrado"
- `profile_user_not_found` → "Usuário não encontrado"

**Recommendation:** Create `common_not_found` = "não encontrado" (lowercase for composition)

## Summary of Common Keys to Create

### Action Buttons (9 keys)
1. `common_continue` = "Continuar"
2. `common_cancel` = "Cancelar"
3. `common_save` = "Salvar"
4. `common_verify` = "Verificar"
5. `common_next` = "Próximo"
6. `common_back` = "Voltar"
7. `common_done` = "Pronto"
8. `common_confirm` = "Confirmar"
9. `common_delete` = "Excluir"

### Error Handling (4 keys)
10. `common_try_again` = "Tentar novamente"
11. `common_error` = "Erro"
12. `common_success` = "Sucesso"
13. `common_loading` = "Carregando..."

### Form Fields (8 keys)
14. `common_email_label` = "E-mail"
15. `common_email_hint` = "digite seu e-mail"
16. `common_password_label` = "Senha"
17. `common_password_hint` = "digite sua senha"
18. `common_new_password_label` = "Nova senha"
19. `common_confirm_password_label` = "Confirmar senha"
20. `common_confirm_password_hint` = "repita sua senha"
21. `common_name_label` = "Nome"
22. `common_name_hint` = "digite seu nome"

### Validation Errors (4 keys)
23. `error_email_required` = "E-mail é obrigatório."
24. `error_email_invalid` = "Por favor, insira um e-mail válido."
25. `error_password_required` = "Senha é obrigatória."
26. `error_password_min_length` = "A senha deve ter pelo menos 6 caracteres."
27. `error_confirm_password_required` = "Confirmação de senha é obrigatória."
28. `error_passwords_dont_match` = "As senhas não coincidem."

### Global Widget Texts (3 keys)
29. `common_didnt_receive` = "Não recebeu?"
30. `common_tap_to_resend` = "Toque para reenviar."
31. `common_resend_code_in` = "Reenviar código em"

### Navigation/Titles (2 keys)
32. `common_profile` = "Perfil"
33. `common_settings` = "Configurações"

### Utility (1 key)
34. `common_not_found` = "não encontrado"

## Total Common Keys: 34

## Next Steps

1. Create consolidated common keys JSON file
2. Update all feature JSON files to replace duplicate keys with common key references
3. Verify all common keys are properly documented
4. Ensure consistency across all translations
