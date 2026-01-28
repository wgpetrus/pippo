# Firestore Security Rules Testing

## Overview

Este documento descreve como testar as regras de segurança do Firestore para o Shop System.

---

## Regras Implementadas

### 1. Autenticação (Requirement 6.4)
```javascript
request.auth != null && request.auth.uid == userId
```
- Usuário deve estar autenticado
- Usuário só pode acessar seus próprios dados

### 2. Gems Não-Negativos (Requirement 6.1)
```javascript
request.resource.data.gems.gems >= 0
```
- Gems nunca podem ser negativos
- Previne exploits de gems infinitos

### 3. Energy Cap (Requirement 2.3)
```javascript
request.resource.data.energy.currentEnergy >= 0 
&& request.resource.data.energy.currentEnergy <= 5
```
- Energy deve estar entre 0 e 5
- Previne overflow de energia

---

## Testes Unitários

Os testes conceituais estão em `test/security_rules/firestore_rules_test.dart`.

Para executar:
```bash
flutter test test/security_rules/firestore_rules_test.dart
```

### Cenários Testados

#### ✅ Autenticação
- [x] Usuário autenticado pode escrever seus dados
- [x] Usuário não autenticado não pode escrever
- [x] Usuário não pode escrever dados de outro usuário

#### ✅ Validação de Gems
- [x] Gems negativos são rejeitados
- [x] Gems zero são aceitos
- [x] Gems positivos são aceitos

#### ✅ Validação de Energy
- [x] Energy > 5 é rejeitado
- [x] Energy < 0 é rejeitado
- [x] Energy entre 0-5 é aceito
- [x] Energy = 0 é aceito
- [x] Energy = 5 é aceito

#### ✅ Cenários Combinados
- [x] Dados válidos com autenticação correta
- [x] Gems inválidos com energy válido
- [x] Gems válidos com energy inválido
- [x] Dados válidos sem autenticação

---

## Testando com Firebase Emulator

### Setup do Emulator

1. Instalar Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Fazer login:
```bash
firebase login
```

3. Inicializar emuladores:
```bash
firebase init emulators
```

Selecionar:
- [x] Firestore
- [x] Authentication

4. Configurar `firebase.json`:
```json
{
  "emulators": {
    "firestore": {
      "port": 8080
    },
    "auth": {
      "port": 9099
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

### Executar Emulator

```bash
firebase emulators:start
```

Acesse a UI em: http://localhost:4000

---

## Testes Manuais no Emulator

### 1. Teste de Autenticação

**Cenário 1: Usuário autenticado escreve seus dados**
```javascript
// No Firestore Emulator UI
// 1. Criar usuário no Auth Emulator (user123)
// 2. Tentar escrever em: users/user123/stats/gamification
// Resultado esperado: ✅ Sucesso
```

**Cenário 2: Usuário não autenticado**
```javascript
// 1. Não fazer login
// 2. Tentar escrever em: users/user123/stats/gamification
// Resultado esperado: ❌ permission-denied
```

**Cenário 3: Escrever dados de outro usuário**
```javascript
// 1. Login como user123
// 2. Tentar escrever em: users/user456/stats/gamification
// Resultado esperado: ❌ permission-denied
```

### 2. Teste de Gems Negativos

**Cenário 1: Gems negativos**
```javascript
// Login como user123
// Tentar salvar:
{
  gems: { gems: -50 },
  energy: { currentEnergy: 3 }
}
// Resultado esperado: ❌ Rejeitado
```

**Cenário 2: Gems zero**
```javascript
{
  gems: { gems: 0 },
  energy: { currentEnergy: 3 }
}
// Resultado esperado: ✅ Aceito
```

**Cenário 3: Gems positivos**
```javascript
{
  gems: { gems: 500 },
  energy: { currentEnergy: 3 }
}
// Resultado esperado: ✅ Aceito
```

### 3. Teste de Energy Cap

**Cenário 1: Energy > 5**
```javascript
{
  gems: { gems: 200 },
  energy: { currentEnergy: 6 }
}
// Resultado esperado: ❌ Rejeitado
```

**Cenário 2: Energy < 0**
```javascript
{
  gems: { gems: 200 },
  energy: { currentEnergy: -1 }
}
// Resultado esperado: ❌ Rejeitado
```

**Cenário 3: Energy válido (0-5)**
```javascript
{
  gems: { gems: 200 },
  energy: { currentEnergy: 3 }
}
// Resultado esperado: ✅ Aceito
```

---

## Testes Automatizados com @firebase/rules-unit-testing

Para testes mais robustos, use o pacote oficial do Firebase:

### Setup

```bash
npm install --save-dev @firebase/rules-unit-testing
```

### Exemplo de Teste

```javascript
const testing = require('@firebase/rules-unit-testing');

describe('Shop System Security Rules', () => {
  let testEnv;

  beforeAll(async () => {
    testEnv = await testing.initializeTestEnvironment({
      projectId: 'pippo-test',
      firestore: {
        rules: fs.readFileSync('firestore.rules', 'utf8'),
      },
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  test('Authenticated user can write valid data', async () => {
    const alice = testEnv.authenticatedContext('alice');
    await testing.assertSucceeds(
      alice.firestore()
        .collection('users').doc('alice')
        .collection('stats').doc('gamification')
        .set({
          gems: { gems: 200 },
          energy: { currentEnergy: 3 }
        })
    );
  });

  test('Negative gems are rejected', async () => {
    const alice = testEnv.authenticatedContext('alice');
    await testing.assertFails(
      alice.firestore()
        .collection('users').doc('alice')
        .collection('stats').doc('gamification')
        .set({
          gems: { gems: -50 },
          energy: { currentEnergy: 3 }
        })
    );
  });

  test('Energy > 5 is rejected', async () => {
    const alice = testEnv.authenticatedContext('alice');
    await testing.assertFails(
      alice.firestore()
        .collection('users').doc('alice')
        .collection('stats').doc('gamification')
        .set({
          gems: { gems: 200 },
          energy: { currentEnergy: 6 }
        })
    );
  });
});
```

---

## Checklist de Validação

Antes de fazer deploy para produção:

- [x] Regras de autenticação implementadas
- [x] Validação de gems não-negativos implementada
- [x] Validação de energy cap implementada
- [x] Testes unitários passando
- [ ] Testes manuais no emulator executados
- [ ] Testes automatizados com @firebase/rules-unit-testing (opcional)
- [ ] Code review das regras
- [ ] Deploy para staging testado
- [ ] Deploy para produção

---

## Troubleshooting

### Erro: permission-denied

**Causa:** Usuário não autenticado ou tentando acessar dados de outro usuário.

**Solução:** Verificar que `request.auth.uid == userId`.

### Erro: Validação falha silenciosamente

**Causa:** Regra de validação rejeitando dados.

**Solução:** Verificar logs do Firestore para ver qual validação falhou.

### Emulator não inicia

**Causa:** Porta já em uso.

**Solução:** 
```bash
# Matar processos na porta
npx kill-port 8080 9099 4000

# Ou especificar portas diferentes no firebase.json
```

---

## Referências

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Rules Unit Testing](https://firebase.google.com/docs/rules/unit-tests)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
