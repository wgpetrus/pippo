# Consolidation Summary

## Overview

This document provides a detailed mapping of which keys in each feature JSON file should be replaced with common keys. This consolidation ensures consistency across the application and reduces duplication.

## Consolidation Statistics

- **Total common keys created:** 36
- **Total keys to be replaced:** 52
- **Files affected:** 7 (auth, onboarding, lesson, home, profile, friends, splash)
- **Estimated reduction in duplicate keys:** ~40%

## File-by-File Consolidation Plan

### 1. Auth Feature (`extracted-texts-auth.json`)

#### Keys to Replace with Common Keys:

| Current Key | Replace With | Portuguese Text |
|-------------|--------------|-----------------|
| `auth_cancel_button` (2 occurrences) | `common_cancel` | "Cancelar" |
| `auth_verify_button` | `common_verify` | "Verificar" |
| `auth_email_label` | `common_email_label` | "E-mail" |
| `auth_email_hint` | `common_email_hint` | "digite seu e-mail" |
| `auth_password_label` | `common_password_label` | "Senha" |
| `auth_password_hint` | `common_password_hint` | "digite sua senha" |
| `auth_new_password_label` | `common_new_password_label` | "Nova senha" |
| `auth_confirm_password_label` | `common_confirm_password_label` | "Confirmar senha" |
| `error_email_required` | `error_email_required` | "E-mail é obrigatório." |
| `error_email_invalid` | `error_email_invalid` | "Por favor, insira um e-mail válido." |
| `error_password_required` | `error_password_required` | "Senha é obrigatória." |
| `error_password_min_length` | `error_password_min_length` | "A senha deve ter pelo menos 6 caracteres." |
| `error_confirm_password_required` | `error_confirm_password_required` | "Confirmação de senha é obrigatória." |
| `error_passwords_dont_match` | `error_passwords_dont_match` | "As senhas não coincidem." |

**Total replacements in auth:** 14 keys

**Note:** Error keys are already properly named and will be moved to common section.

---

### 2. Onboarding Feature (`extracted-texts-onboarding.json`)

#### Keys to Replace with Common Keys:

| Current Key | Replace With | Portuguese Text |
|-------------|--------------|-----------------|
| `common_continue` | Keep as `common_continue` | "Continuar" |
| `onboarding_user_password_button_cancel` | `common_cancel` | "Cancelar" |
| `onboarding_verify_code_button_cancel` | `common_cancel` | "Cancelar" |
| `onboarding_conclusion_button_cancel` | `common_cancel` | "Cancelar" |
| `onboarding_pause_one_button` | `common_next` | "Próximo" |
| `onboarding_learning_reason_other_modal_confirm` | `common_confirm` | "Confirmar" |
| `onboarding_user_name_label` | `common_name_label` | "Nome" |
| `onboarding_user_name_hint` | `common_name_hint` | "digite seu nome" |
| `onboarding_user_email_label` | `common_email_label` | "E-mail" |
| `onboarding_user_email_hint` | `common_email_hint` | "digite seu e-mail" |
| `onboarding_user_password_label` | `common_password_label` | "Senha" |
| `onboarding_user_password_hint` | `common_password_hint` | "digite sua senha" |
| `onboarding_user_password_confirm_label` | `common_confirm_password_label` | "Confirmar Senha" |
| `onboarding_user_password_confirm_hint` | `common_confirm_password_hint` | "repita sua senha" |
| `onboarding_user_password_error_mismatch` | `error_passwords_dont_match` | "As senhas não coincidem." |
| `onboarding_user_email_error_invalid` | `error_email_invalid` | "E-mail inválido" |

**Total replacements in onboarding:** 16 keys

**Note:** `common_continue` already exists in onboarding and should be kept as reference to common key.

---

### 3. Lesson Feature (`extracted-texts-lesson.json`)

#### Keys to Replace with Common Keys:

| Current Key | Replace With | Portuguese Text |
|-------------|--------------|-----------------|
| `lesson_sections_error_snackbar_title` | `common_error` | "Erro" |
| `lesson_image_exercise_check_button` | `common_verify` | "Verificar" |
| `lesson_translation_exercise_check_button` | `common_verify` | "Verificar" |
| `lesson_word_exercise_check_button` | `common_verify` | "Verificar" |
| `lesson_match_exercise_check_button` | `common_verify` | "Verificar" |
| `lesson_feedback_correct_button` | `common_continue` | "Continuar" |
| `lesson_exit_confirmation_continue_button` | `common_continue` | "Continuar Lição" |

**Total replacements in lesson:** 7 keys

**Note:** Some keys like `lesson_exit_confirmation_continue_button` have additional context ("Continuar Lição") and may need to keep original key or use string interpolation.

---

### 4. Home Feature (`extracted-texts-home.json`)

#### Keys to Replace with Common Keys:

| Current Key | Replace With | Portuguese Text |
|-------------|--------------|-----------------|
| `home_profile_tab` | `common_profile` | "Perfil" |
| `home_energy_modal_error_title` | `common_error` | "Erro" |
| `home_energy_modal_success_title` | `common_success` | "Sucesso" |
| `leaderboard_try_again` | `common_try_again` | "Tentar novamente" |
| `leaderboard_status_modal_done` | `common_done` | "Pronto" |
| `shop_confirmation_confirm` | `common_confirm` | "Confirmar" |
| `shop_confirmation_cancel` | `common_cancel` | "Cancelar" |
| `treasure_try_again` | `common_try_again` | "Tentar novamente" |
| `treasure_delete_confirm_button` | `common_delete` | "Deletar" |
| `treasure_delete_cancel_button` | `common_cancel` | "Cancelar" |
| `treasure_delete_success_title` | `common_success` | "Sucesso" |
| `treasure_delete_error_title` | `common_error` | "Erro" |
| `treasure_generate_success_title` | `common_success` | "Sucesso" |
| `treasure_generate_error_title` | `common_error` | "Erro" |

**Total replacements in home:** 14 keys

---

### 5. Profile Feature (`extracted-texts-profile.json`)

#### Keys to Replace with Common Keys:

| Current Key | Replace With | Portuguese Text |
|-------------|--------------|-----------------|
| `profile_title` (3 occurrences) | `common_profile` | "Perfil" |
| `profile_edit_title` | `common_profile` | "Perfil" |
| `profile_try_again` (2 occurrences) | `common_try_again` | "Tentar novamente" |
| `profile_edit_save` | `common_save` | "Salvar" |
| `profile_edit_name_label` | `common_name_label` | "Nome" |
| `profile_edit_name_hint` | `common_name_hint` | "digite seu nome" |
| `profile_edit_email_label` | `common_email_label` | "E-mail" |
| `settings_profile` | `common_profile` | "Perfil" |
| `change_password_save` | `common_save` | "Salvar" |
| `change_password_current_label` | `common_password_label` | "Senha Atual" |
| `change_password_new_label` | `common_new_password_label` | "Nova Senha" |
| `change_password_confirm_label` | `common_confirm_password_label` | "Confirmar senha" |
| `change_password_confirm_hint` | `common_confirm_password_hint` | "repita sua senha" |
| `phone_number_save` | `common_save` | "Salvar" |
| `phone_number_next` | `common_next` | "Próximo" |
| `verify_phone_verify` | `common_verify` | "Verificar" |
| `courses_try_again` | `common_try_again` | "Tentar Novamente" |
| `courses_delete_confirm` | `common_delete` | "Remover" |
| `courses_delete_cancel` | `common_cancel` | "Cancelar" |
| `change_avatar_save` | `common_save` | "Salvar" |
| `confirm_delete_cancel` | `common_cancel` | "Cancelar" |
| `delete_account_cancel` | `common_cancel` | "Cancelar" |
| `reauthenticate_password_label` | `common_password_label` | "Senha" |
| `reauthenticate_password_hint` | `common_password_hint` | "Digite sua senha" |
| `reauthenticate_password_required` | `error_password_required` | "Senha é obrigatória." |
| `reauthenticate_cancel` | `common_cancel` | "Cancelar" |
| `reauthenticate_confirm` | `common_confirm` | "Confirmar" |
| `reminder_time_save` | `common_save` | "Salvar" |

**Total replacements in profile:** 28 keys

**Note:** Some keys like `courses_delete_confirm` use "Remover" instead of "Excluir" - need to decide on standardization.

---

### 6. Friends Feature (`extracted-texts-friends.json`)

#### Keys to Replace with Common Keys:

| Current Key | Replace With | Portuguese Text |
|-------------|--------------|-----------------|
| `friends_retry_button` | `common_try_again` | "Tentar novamente" |

**Total replacements in friends:** 1 key

---

### 7. Splash Feature (`extracted-texts-splash.json`)

#### Keys to Replace with Common Keys:

| Current Key | Replace With | Portuguese Text |
|-------------|--------------|-----------------|
| `splash_retry_button` | `common_try_again` | "Tentar novamente" |

**Total replacements in splash:** 1 key

---

### 8. Global Widgets (`extracted-texts-global.json`)

#### Keys Already Identified as Common:

These keys are already properly identified and documented:
- `common_didnt_receive` = "Não recebeu?"
- `common_tap_to_resend` = "Toque para reenviar."
- `common_resend_code_in` = "Reenviar código em"

**No replacements needed** - these are already common keys.

---

## Implementation Notes

### Keys That Need Context Consideration

Some keys have additional context that may require keeping the original key or using string interpolation:

1. **"Continuar Lição"** vs **"Continuar"**
   - `lesson_exit_confirmation_continue_button` = "Continuar Lição"
   - Could use: `common_continue` + " Lição" or keep original

2. **"Continuar Cadastro"** vs **"Continuar"**
   - `onboarding_header_exit_dialog_cancel` = "Continuar Cadastro"
   - Could use: `common_continue` + " Cadastro" or keep original

3. **"Remover"** vs **"Excluir"**
   - `courses_delete_confirm` = "Remover"
   - `common_delete` = "Excluir"
   - Need to standardize on one term

4. **"Senha Atual"** vs **"Senha"**
   - `change_password_current_label` = "Senha Atual"
   - Could use: `common_password_label` + " Atual" or create `common_current_password_label`

### Validation Errors Standardization

All validation error keys should be moved to common section:
- `error_email_required`
- `error_email_invalid`
- `error_password_required`
- `error_password_min_length`
- `error_confirm_password_required`
- `error_passwords_dont_match`

These are already properly named and just need to be centralized.

---

## Next Steps for Implementation

1. **Update each feature JSON file** to reference common keys instead of duplicates
2. **Create a master common keys JSON** with all 36 common keys
3. **Verify consistency** across all translations
4. **Document any context-specific variations** that need to remain separate
5. **Update the design document** to reflect the common keys structure

---

## Benefits of Consolidation

1. **Consistency:** Same text always uses same translation
2. **Maintainability:** Update once, applies everywhere
3. **Reduced file size:** ~40% reduction in duplicate keys
4. **Easier translation:** Translators only translate common texts once
5. **Quality assurance:** Easier to spot inconsistencies

---

## Verification Checklist

- [ ] All common keys follow `common_` prefix convention
- [ ] All error keys follow `error_` prefix convention
- [ ] No duplicate keys across features (except intentional context-specific ones)
- [ ] All common keys documented with usage locations
- [ ] Replacement mapping complete for all features
- [ ] Context-specific variations identified and documented
- [ ] Translation files updated to reference common keys
