# UI Auth - Pippo

> Telas de autenticação implementadas

---

## Telas

| Tela | Arquivo | Status |
|------|---------|--------|
| Login | signin_view.dart | ✅ UI Completa |
| Esqueci Senha | forgot_password_view.dart | ✅ UI Completa |
| Verificar Código | verify_code_view.dart | ✅ UI Completa |
| Nova Senha | new_password_view.dart | ✅ UI Completa |

---

## signin_view.dart

### Componentes
- Logo Pippo (SVG)
- Título "Sign in"
- AppTextField (Email)
- AppTextField (Password) com toggle visibility
- Link "Forgot password?"
- AppButton "Sign in"
- Divider "Or"
- SocialButton (Google)
- SocialButton (Facebook)
- Link "Don't have an account? Sign up"

### Widgets Utilizados
- `AppTextField` (shared)
- `AppButton` (shared)
- `SocialButton` (feature)

---

## forgot_password_view.dart

### Componentes
- AppAppbar "Forgot Password"
- Texto explicativo
- AppTextField (Email)
- AppButton "Send Code"

### Widgets Utilizados
- `AppAppbar` (shared)
- `AppTextField` (shared)
- `AppButton` (shared)

---

## verify_code_view.dart

### Componentes
- AppAppbar "Verify Code"
- Texto com email mascarado
- AppPinput (6 dígitos)
- AppResendCode (timer)
- AppButton "Verify"

### Widgets Utilizados
- `AppAppbar` (shared)
- `AppPinput` (shared)
- `AppResendCode` (shared)
- `AppButton` (shared)

---

## new_password_view.dart

### Componentes
- AppAppbar "New Password"
- AppTextField (New Password)
- AppTextField (Confirm Password)
- AppButton "Reset Password"

### Widgets Utilizados
- `AppAppbar` (shared)
- `AppTextField` (shared)
- `AppButton` (shared)

---

## Widgets da Feature

### social_button.dart
Botão de login social (Google/Facebook).

```dart
SocialButton(
  icon: AppAssets.logoGoogle,
  label: 'Continue with Google',
  onPressed: () {},
)
```
