# Migração do Campo searchName

## Contexto

A funcionalidade de busca de usuários requer um campo `searchName` (versão lowercase do nome) para permitir buscas case-insensitive no Firestore.

## Implementação

### 1. Novos Usuários ✅

O campo `searchName` é automaticamente criado para:
- Novos usuários durante o onboarding (`onboarding_controller.dart`)
- Quando um usuário atualiza seu nome (`profile_controller.dart` - método `updateProfile()`)

### 2. Usuários Existentes

Para usuários que já existem no Firestore, é necessário executar uma migração única.

## Script de Migração

Execute este script no Firebase Console ou via Cloud Functions:

```javascript
// Firebase Console > Firestore > Executar consulta

const admin = require('firebase-admin');
const db = admin.firestore();

async function migrateSearchName() {
  const usersRef = db.collection('users');
  const snapshot = await usersRef.get();
  
  const batch = db.batch();
  let count = 0;
  
  snapshot.forEach((doc) => {
    const data = doc.data();
    
    // Verificar se já tem searchName
    if (!data.searchName && data.name) {
      batch.update(doc.ref, {
        searchName: data.name.toLowerCase()
      });
      count++;
    }
  });
  
  if (count > 0) {
    await batch.commit();
    console.log(`✅ Migração concluída: ${count} usuários atualizados`);
  } else {
    console.log('✅ Nenhum usuário precisa de migração');
  }
}

migrateSearchName();
```

## Alternativa: Cloud Function

Crie uma Cloud Function para executar a migração:

```javascript
// functions/index.js

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.migrateSearchName = functions.https.onRequest(async (req, res) => {
  const db = admin.firestore();
  const usersRef = db.collection('users');
  const snapshot = await usersRef.get();
  
  const batch = db.batch();
  let count = 0;
  
  snapshot.forEach((doc) => {
    const data = doc.data();
    
    if (!data.searchName && data.name) {
      batch.update(doc.ref, {
        searchName: data.name.toLowerCase()
      });
      count++;
    }
  });
  
  if (count > 0) {
    await batch.commit();
    res.json({ success: true, updated: count });
  } else {
    res.json({ success: true, updated: 0, message: 'Nenhum usuário precisa de migração' });
  }
});
```

Deploy e execute:
```bash
firebase deploy --only functions:migrateSearchName
# Acesse: https://YOUR_PROJECT.cloudfunctions.net/migrateSearchName
```

## Verificação

Após executar a migração, verifique no Firestore Console:

1. Abra qualquer documento de usuário
2. Confirme que o campo `searchName` existe
3. Confirme que o valor é lowercase do campo `name`

## Índices Necessários

O Firestore pode solicitar a criação de índices compostos. Se aparecer erro ao buscar, clique no link fornecido pelo Firebase ou crie manualmente:

**Índice 1:**
- Collection: `users`
- Fields: `username` (Ascending), `__name__` (Ascending)

**Índice 2:**
- Collection: `users`
- Fields: `searchName` (Ascending), `__name__` (Ascending)

## Testes

Após a migração, teste a busca:

1. Abra o app
2. Navegue para Profile > Buscar usuários
3. Digite parte de um nome (ex: "joão")
4. Verifique se usuários com "João", "JOÃO", "joão" aparecem nos resultados

## Notas

- A migração é **idempotente** (pode ser executada múltiplas vezes sem problemas)
- Usuários sem campo `name` serão ignorados
- O campo `searchName` será atualizado automaticamente em futuras edições de perfil
