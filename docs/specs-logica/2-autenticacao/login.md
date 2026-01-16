# Login - Lógica de Autenticação

> Processo de login de usuários existentes

---

## Processo de Login

### 1. Autenticar no Firebase

```dart
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

---

### 2. Verificar onboarding completo

```dart
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();

final onboardingCompleted = doc.data()?['onboardingCompleted'] ?? false;
```

- Se `false`: navegar para `/onboarding` (completar cadastro)
- Se `true`: continuar para passo 3

---

### 3. Atualizar lastActiveAt

```dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .update({'lastActiveAt': FieldValue.serverTimestamp()});
```

---

### 4. Navegar para Home

```dart
Get.offAllNamed('/home');
```

---

## Recuperação de Senha

### Fluxo: ForgotPassword → VerifyCode → NewPassword → SignIn

**ForgotPassword:**
1. Usuário digita email
2. Enviar código de verificação (5 dígitos) por email
3. Salvar `verificationId` temporariamente
4. Navegar para VerifyCode

**VerifyCode:**
1. Usuário digita código de 5 dígitos
2. Validar código
3. Se válido: navegar para NewPassword
4. Se inválido: mostrar erro

**NewPassword:**
1. Usuário digita nova senha
2. Atualizar senha no Firebase Auth
3. Navegar para SignIn

---

## Código OTP

- **Formato**: 5 dígitos
- **Expiração**: 10 minutos
- **Timer de reenvio**: 60 segundos
