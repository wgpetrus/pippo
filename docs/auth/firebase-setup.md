# Configuração do Firebase

## Firestore Rules

Deploy das regras de segurança:

```bash
firebase deploy --only firestore:rules
```

## Índices Necessários

### Prevenir Emails Duplicados

**IMPORTANTE:** O Firestore não suporta constraints UNIQUE nativamente. A prevenção de emails duplicados é feita no código (app-side).

**Implementação atual:**
1. Antes de criar conta com email/senha: verifica se email existe no Firestore
2. Antes de criar conta com Google: verifica se email existe no Firestore
3. Se email existe com método diferente: mostra erro e botão para fazer login

**Índice recomendado para performance:**

Criar índice composto em `users`:
- Campo: `email` (Ascending)
- Campo: `authProvider` (Ascending)

**Como criar:**
1. Acessar Firebase Console
2. Firestore Database > Indexes
3. Create Index
4. Collection: `users`
5. Adicionar campos: `email` (Ascending), `authProvider` (Ascending)
6. Query scope: Collection

## Collections

### users

```
users/{userId}
  - id: string (UID do Firebase Auth)
  - email: string
  - name: string
  - username: string (único, gerado automaticamente)
  - age: string
  - authProvider: string ('email' | 'google')
  - onboardingCompleted: boolean
  - createdAt: timestamp
  - updatedAt: timestamp
  - lastActiveAt: timestamp (opcional)
```

### users/{userId}/courses

```
courses/{courseId}
  - id: string (auto-generated)
  - language: string (código do idioma)
  - languageName: string (nome do idioma)
  - level: string
  - reason: string
  - studyTime: number (minutos por dia)
  - isActive: boolean
  - createdAt: timestamp
```

### users/{userId}/stats

```
stats/gamification
  - xp: number
  - level: number
  - streak: number
  - energy: number
  - gems: number
  - hearts: number
  - lastActiveAt: timestamp
```

### emailVerifications (temporário)

```
emailVerifications/{email}
  - code: string (5 dígitos)
  - expiresAt: timestamp (10 minutos)
  - attempts: number
  - createdAt: timestamp
```

### passwordResets (temporário)

```
passwordResets/{email}
  - code: string (5 dígitos)
  - expiresAt: timestamp (10 minutos)
  - attempts: number
  - createdAt: timestamp
```

## Segurança

### Dados Sensíveis

- ❌ Nunca armazenar senhas no Firestore (Firebase Auth cuida disso)
- ❌ Nunca armazenar tokens de autenticação no Firestore
- ✅ Usar Firebase Auth para autenticação
- ✅ Usar Firestore apenas para dados do perfil e progresso

### Validação

- ✅ Validar dados no cliente antes de enviar
- ✅ Usar regras de segurança do Firestore
- ✅ Sanitizar inputs (email, nome, etc)
