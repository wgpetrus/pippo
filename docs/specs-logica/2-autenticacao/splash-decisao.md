# Splash - Lógica de Decisão

> Ordem CRÍTICA de verificações ao abrir o app

---

## Ordem EXATA (NUNCA inverter!)

### 1. Verificar se está logado (Firebase Auth)

```dart
final user = FirebaseAuth.instance.currentUser;
```

- Se `user == null`: ir para passo 2
- Se `user != null`: ir para passo 3

---

### 2. Usuário NÃO logado

Verificar primeiro acesso via SharedPreferences:

```dart
final prefs = await SharedPreferences.getInstance();
final isFirstAccess = prefs.getBool('isFirstAccess') ?? true;
```

- Se `isFirstAccess == true`: navegar para `/onboarding`
- Se `isFirstAccess == false`: navegar para `/auth`

---

### 3. Usuário logado

Buscar dados do Firestore:

```dart
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();

final onboardingCompleted = doc.data()?['onboardingCompleted'] ?? false;
```

- Se `onboardingCompleted == false`: navegar para `/onboarding`
- Se `onboardingCompleted == true`: navegar para `/home`

---

## Tempo de Exibição

- **Mínimo**: 2 segundos (mostrar logo)
- **Máximo**: 5 segundos (timeout se Firestore demorar)

---

## Tratamento de Erros

**Erro ao buscar dados do Firestore:**
- Navegar para `/auth` (forçar novo login)

**Sem internet:**
- Mostrar mensagem: "Verifique sua conexão com a internet"
- Botão "Tentar novamente"
