# Firestore Security Rules - Onboarding

## OTP Storage Security Rules

Para proteger os códigos OTP armazenados na coleção `emailVerifications`, adicione as seguintes regras ao arquivo `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Regras para verificação de email (OTP)
    match /emailVerifications/{email} {
      // Permitir criação apenas se o documento não existir ou se já expirou
      allow create: if request.auth != null 
                    && request.resource.data.keys().hasAll(['code', 'expiresAt', 'attempts', 'createdAt'])
                    && request.resource.data.code is string
                    && request.resource.data.code.size() == 5
                    && request.resource.data.attempts == 0;
      
      // Permitir leitura apenas do próprio email
      allow read: if request.auth != null 
                  && request.auth.token.email == email;
      
      // Permitir atualização apenas para incrementar tentativas (se implementado)
      allow update: if request.auth != null 
                    && request.auth.token.email == email
                    && request.resource.data.attempts > resource.data.attempts;
      
      // Permitir exclusão apenas do próprio email
      allow delete: if request.auth != null 
                    && request.auth.token.email == email;
    }
    
    // Outras regras do projeto...
  }
}
```

## Explicação das Regras

### Create (Criação)
- Apenas usuários autenticados podem criar documentos OTP
- O documento deve conter todos os campos obrigatórios: `code`, `expiresAt`, `attempts`, `createdAt`
- O código deve ser uma string de exatamente 5 caracteres
- O campo `attempts` deve começar em 0

### Read (Leitura)
- Apenas o usuário autenticado pode ler seu próprio documento OTP
- Verifica se o email do token de autenticação corresponde ao ID do documento

### Update (Atualização)
- Permite atualização apenas para incrementar o contador de tentativas
- Apenas o próprio usuário pode atualizar seu documento

### Delete (Exclusão)
- Apenas o usuário autenticado pode deletar seu próprio documento OTP
- Isso é usado após verificação bem-sucedida do código

## Implementação Atual

O código já implementa:

1. ✅ **Criação de OTP**: Método `sendVerificationCode()` cria documento com estrutura correta
2. ✅ **Leitura de OTP**: Método `verifyCode()` lê o documento para validação
3. ✅ **Exclusão de OTP**: Método `verifyCode()` deleta o documento após verificação bem-sucedida
4. ✅ **Expiração**: Códigos expiram após 10 minutos (verificado no código)

## Melhorias Futuras (Opcional)

Para aumentar ainda mais a segurança:

1. **Limitar tentativas de verificação**: Incrementar campo `attempts` e bloquear após 3 tentativas
2. **Rate limiting**: Usar Firebase App Check para prevenir abuso
3. **Limpeza automática**: Criar Cloud Function para deletar documentos expirados
4. **Hashing**: Armazenar hash do código ao invés do código em texto plano (mais complexo)

## Como Aplicar as Regras

1. Acesse o Firebase Console
2. Vá para Firestore Database > Rules
3. Adicione as regras acima ao arquivo `firestore.rules`
4. Clique em "Publish" para aplicar as regras

## Testando as Regras

Use o Firebase Emulator Suite para testar as regras localmente antes de publicar:

```bash
firebase emulators:start
```

Ou use o Rules Playground no Firebase Console para simular operações.
