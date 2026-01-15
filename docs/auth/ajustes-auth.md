# Ajustes de Conformidade - Projeto Pippo

> Documento atualizado após execução das correções.

---

## Decisões Aceitas (não corrigir)

| Item | Justificativa |
|------|---------------|
| Subpastas em `views/` | Organiza melhor com muitos arquivos |
| Pasta `navigation/` | Mantém controller enxuto, não é lógica na view |

---

## Correções Realizadas

### ✅ 1. Cores adicionadas ao theme
- `primaryDark` = `0xFF0099D4`
- `primaryLight` = `0xFF4DD0FF`

### ✅ 2. Assets adicionados ao AppAssets
- `logoFacebook`
- `logoGoogle`

### ✅ 3. Import corrigido em intro_page.dart
- Removido `OnboardingStep` inexistente

### ✅ 4. Widget movido para auth/widgets/
- `app_social_button.dart` → `social_button.dart`

### ✅ 5. Widget ProgressBar criado
- `lib/features/core/onboarding/widgets/progress_bar.dart`

### ✅ 6. Widget OnboardingTextField criado
- `lib/features/core/onboarding/widgets/onboarding_text_field.dart`

### ✅ 7. Widget AppResendCode criado
- `lib/shared/widgets/app_resend_code.dart`

### ✅ 8. Widget AppPinput criado
- `lib/shared/widgets/app_pinput.dart`

### ✅ 9. Arquivos refatorados para usar novos widgets
- `user_name_page.dart`
- `user_age_page.dart`
- `user_email_page.dart`
- `user_password_page.dart`
- `verify_code_page.dart` (onboarding)
- `verify_code_view.dart` (auth)

### ✅ 10. Ícones substituídos por FontAwesome
- Todos os `Icons.` substituídos por `FontAwesomeIcons.`

### ✅ 11. Splash corrigida
- `MediaQuery` → `Get.height`

### ✅ 12. Cores hardcoded substituídas
- `Color(0xFF0099D4)` → `AppTheme.primaryDark`
- `Color(0xFF4DD0FF)` → `AppTheme.primaryLight`

---

## Pendências (ação manual)

### 📁 Renomear arquivos de imagem
**Pasta:** `lib/assets/images/auth/`

| De | Para |
|----|------|
| `logo=facebook.svg` | `logo_facebook.svg` |
| `logo=google.svg` | `logo_google.svg` |

**Após renomear, atualizar `app_assets.dart`:**
```dart
static const String logoFacebook = 'lib/assets/images/auth/logo_facebook.svg';
static const String logoGoogle = 'lib/assets/images/auth/logo_google.svg';
```

---

## Checklist Final

- [x] Cores adicionadas ao theme
- [x] Assets adicionados ao AppAssets
- [x] Import corrigido em intro_page
- [x] `app_social_button.dart` movido para `auth/widgets/`
- [x] Widget ProgressBar criado
- [x] Widget OnboardingTextField criado
- [x] Widget AppResendCode criado
- [x] Widget AppPinput criado
- [x] Arquivos refatorados
- [x] Ícones substituídos por FontAwesome
- [x] Splash corrigida
- [x] Cores hardcoded substituídas
- [x] Arquivos de imagem renomeados (manual)
