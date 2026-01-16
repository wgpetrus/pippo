# Configuração Inicial Firebase - Pippo

> Firebase configurado e testado com sucesso

---

## ✅ Status

- [x] Firebase CLI instalado
- [x] FlutterFire CLI instalado
- [x] Projeto configurado (`flutterfire configure`)
- [x] `firebase_options.dart` criado
- [x] `google-services.json` configurado
- [x] SHA-1 e SHA-256 adicionados
- [x] Authentication habilitado (Email/Password + Google)
- [x] Firestore Database criado (Test mode)
- [x] Conexão testada e funcionando

---

## 📋 Informações do Projeto

| Campo | Valor |
|-------|-------|
| **Project ID** | `pippo-5f543` |
| **Project Number** | `335019597433` |
| **Package Name (Android)** | `br.com.kmelon.dev.pippo` |
| **Bundle ID (iOS)** | `br.com.kmelon.dev.pippo` |

---

## 🔑 SHA Certificates (Debug)

```
SHA-1:   8F:53:6A:AD:2A:25:E3:93:27:A2:BC:72:AD:47:CB:A2:07:0F:F9:DF
SHA-256: E3:73:43:63:24:50:91:4A:EC:84:90:95:7C:44:60:D6:04:A7:00:59:F3:13:6A:5E:37:48:3C:40:4F:9F:09:2D
```

**Válido até**: 8 de junho de 2055

---

## 📦 Dependências Instaladas

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  google_sign_in: ^6.2.1
```

---

## 🔧 Configuração

### main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MainApp());
}
```

### android/app/build.gradle.kts

```kotlin
android {
    defaultConfig {
        minSdk = 23  // Firebase requer mínimo 21
    }
}
```

---

## 🔐 Authentication

### Métodos Habilitados

- ✅ **Email/Password** - Habilitado
- ✅ **Google Sign-In** - Habilitado (SHA configurado)
- ⏳ **Facebook** - Placeholder (aguardando configuração)

---

## 🗄️ Firestore Database

### Modo

- **Test mode** (desenvolvimento)
- Permite leitura/escrita por 30 dias
- Location: `southamerica-east1` (ou conforme escolhido)

### Security Rules (Básicas)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuário só pode ler/escrever seus próprios dados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Cursos são públicos (read-only)
    match /courses/{courseId} {
      allow read: if true;
      allow write: if false;
      
      match /{document=**} {
        allow read: if true;
      }
    }
    
    // Desafios são públicos (read-only)
    match /challenges/{challengeId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## ✅ Teste de Conexão

Teste realizado com sucesso:
- ✅ Firebase Auth conectado
- ✅ Firestore conectado
- ✅ Coleção `_test` criada com timestamp

---

## 📝 Próximos Passos

1. ✅ ~~Configurar Firebase~~ - COMPLETO
2. Implementar Autenticação (2-autenticacao/)
3. Implementar Onboarding (3-onboarding/)
4. Implementar Gamificação (4-gamificacao/)
5. etc.

---

## 🚨 Importante

### Para Produção

Antes de publicar, atualizar:

1. **Security Rules** - Trocar de Test mode para Production
2. **SHA Release** - Adicionar SHA da keystore de release
3. **Google Sign-In** - Configurar OAuth consent screen
4. **Facebook** - Completar configuração se necessário

### Comandos Úteis

```bash
# Gerar SHA de release
cd android
./gradlew signingReport

# Reconfigurar Firebase (se necessário)
flutterfire configure --project=pippo-5f543

# Ver logs do Firebase
flutter run --verbose
```

---

**Data de Configuração**: Janeiro 2026  
**Status**: ✅ Pronto para desenvolvimento
