# Checklist de Testes - Correções Aplicadas

> Use este checklist para validar todas as correções

---

## ✅ ETAPA 1: Onboarding e Navegação

### 1.1 Diálogo de Saída
- [ ] Iniciar onboarding
- [ ] Clicar em "Sair" no header
- [ ] Verificar se textos estão visíveis e legíveis
- [ ] Clicar em "Cancelar" → deve permanecer no onboarding
- [ ] Clicar em "Sair" → deve voltar para welcome

### 1.2 Validação de studyTime
- [ ] Completar onboarding até tela de tempo de estudo
- [ ] Selecionar tempo de estudo
- [ ] Continuar até verificação OTP
- [ ] Inserir código (00000 em debug)
- [ ] Verificar se não aparece erro "tempo de estudo inválido"

### 1.3 BackButton do Signin
- [ ] Acessar signin via "Já tenho conta" do welcome → botão voltar deve aparecer
- [ ] Acessar signin após erro de email duplicado → botão voltar deve aparecer
- [ ] Acessar signin diretamente (primeira tela) → botão voltar NÃO deve aparecer

### 1.4 Login com Onboarding Incompleto
- [ ] Criar conta mas não completar onboarding
- [ ] Fazer logout (ou fechar app)
- [ ] Fazer login com email/senha
- [ ] Verificar se vai para onboarding (não para welcome)
- [ ] Completar onboarding
- [ ] Verificar se vai para home

### 1.5 Login com Google
- [ ] Clicar em "Gmail" na tela de signin
- [ ] Verificar se mostra tela de seleção de contas do Google
- [ ] Selecionar uma conta
- [ ] Verificar se login é bem-sucedido

### 1.6 Emails Duplicados
**Teste 1: Email/Senha → Google**
- [ ] Criar conta com email/senha (ex: teste@gmail.com)
- [ ] Completar onboarding
- [ ] Fazer logout
- [ ] Tentar login com Google usando mesmo email
- [ ] Verificar erro: "Este e-mail já tem uma conta. Faça login com e-mail e senha."
- [ ] Verificar se botão "Fazer login com e-mail" aparece

**Teste 2: Google → Email/Senha**
- [ ] Criar conta com Google (ex: teste2@gmail.com)
- [ ] Completar onboarding
- [ ] Fazer logout
- [ ] Tentar criar conta com email/senha usando mesmo email
- [ ] Verificar erro: "Este e-mail já está sendo usado por outra conta."
- [ ] Verificar se botão "Já tenho uma conta" aparece

### 1.7 Keyboard Overflow
**user_name_page**
- [ ] Abrir tela de nome
- [ ] Clicar no campo de texto
- [ ] Verificar se não há overflow quando teclado sobe
- [ ] Verificar se botão "Continuar" permanece visível

**user_email_page**
- [ ] Abrir tela de email
- [ ] Clicar no campo de texto
- [ ] Verificar se não há overflow quando teclado sobe
- [ ] Verificar se botão "Continuar" permanece visível

**user_password_page**
- [ ] Abrir tela de senha
- [ ] Clicar no primeiro campo
- [ ] Verificar se não há overflow quando teclado sobe
- [ ] Clicar no segundo campo
- [ ] Verificar se não há overflow
- [ ] Verificar se botões permanecem visíveis

---

## ✅ ETAPA 2: Firestore

### 2.1 Criação de Documento
- [ ] Criar conta com email/senha
- [ ] Completar onboarding
- [ ] Verificar no Firebase Console se documento foi criado em `users/{uid}`
- [ ] Verificar se subcoleção `courses` foi criada
- [ ] Verificar se subcoleção `stats` foi criada

### 2.2 Login sem Documento
- [ ] Criar conta no Firebase Auth manualmente (sem Firestore)
- [ ] Tentar fazer login no app
- [ ] Verificar se documento é criado automaticamente
- [ ] Verificar se é redirecionado para onboarding

---

## ✅ ETAPA 3: Google Auth

### 3.1 Seleção de Conta
- [ ] Ter múltiplas contas Google no dispositivo
- [ ] Clicar em "Gmail" na tela de signin
- [ ] Verificar se mostra TODAS as contas disponíveis
- [ ] Selecionar uma conta diferente da última usada
- [ ] Verificar se login é bem-sucedido

### 3.2 Cancelamento
- [ ] Clicar em "Gmail"
- [ ] Cancelar seleção de conta
- [ ] Verificar se volta para tela de signin sem erro

---

## ✅ ETAPA 4: Reset de Senha

### 4.1 Fluxo Completo
- [ ] Clicar em "Esqueci minha senha"
- [ ] Digitar email válido
- [ ] Clicar em "Enviar link"
- [ ] Verificar mensagem de sucesso
- [ ] Verificar se volta para tela de signin
- [ ] Abrir email recebido
- [ ] Clicar no link
- [ ] Definir nova senha no navegador
- [ ] Fazer login no app com nova senha

### 4.2 Validações
- [ ] Tentar enviar link com email inválido → deve mostrar erro
- [ ] Tentar enviar link com email não cadastrado → deve mostrar erro
- [ ] Clicar em "Lembrei minha senha" → deve voltar para signin

---

## 🔍 Testes de Regressão

### Fluxo Completo de Onboarding (Email/Senha)
- [ ] Welcome → "Começar"
- [ ] Intro → "Continue"
- [ ] Select Language → escolher idioma
- [ ] Language Level → escolher nível
- [ ] Learning Reason → escolher motivo
- [ ] Study Time → escolher tempo
- [ ] Pause One → "Continue"
- [ ] User Name → digitar nome
- [ ] User Age → escolher idade
- [ ] Pause Two → "Continue"
- [ ] User Email → digitar email
- [ ] User Password → digitar senha
- [ ] Verify Code → inserir 00000 (debug)
- [ ] Conclusion → "Start Learning"
- [ ] Verificar se vai para home

### Fluxo Completo de Onboarding (Google)
- [ ] Welcome → "Começar"
- [ ] Intro → "Continue"
- [ ] Select Language → escolher idioma
- [ ] Language Level → escolher nível
- [ ] Learning Reason → escolher motivo
- [ ] Study Time → escolher tempo
- [ ] Pause One → "Continue"
- [ ] User Name → pré-preenchido (pode editar)
- [ ] User Age → escolher idade
- [ ] Pause Two → "Continue"
- [ ] Pula email e senha (já autenticado)
- [ ] Conclusion → "Start Learning"
- [ ] Verificar se vai para home

### Login Existente
- [ ] Welcome → "Já tenho uma conta"
- [ ] Signin → digitar email e senha
- [ ] Verificar se vai para home

---

## 📱 Testes em Diferentes Dispositivos

### Tamanhos de Tela
- [ ] Testar em dispositivo pequeno (iPhone SE)
- [ ] Testar em dispositivo médio (iPhone 14)
- [ ] Testar em dispositivo grande (iPhone 14 Pro Max)
- [ ] Testar em tablet (iPad)

### Orientações
- [ ] Testar em portrait
- [ ] Testar em landscape (se aplicável)

---

## 🐛 Casos de Erro

### Conexão
- [ ] Tentar criar conta sem internet → deve mostrar erro de conexão
- [ ] Tentar fazer login sem internet → deve mostrar erro de conexão
- [ ] Tentar enviar link de reset sem internet → deve mostrar erro

### Timeout
- [ ] Simular timeout no Firestore (se possível)
- [ ] Verificar se mensagem de erro é amigável

### Validações
- [ ] Tentar continuar sem preencher campos obrigatórios
- [ ] Tentar usar email inválido
- [ ] Tentar usar senha com menos de 6 caracteres
- [ ] Verificar se mensagens de erro são claras

---

## ✅ Checklist Final

- [ ] Todas as correções foram testadas
- [ ] Não há erros no console
- [ ] Não há warnings críticos
- [ ] Mensagens de erro estão em português
- [ ] Navegação funciona corretamente
- [ ] Dados são salvos no Firestore
- [ ] Não há overflow em nenhuma tela
- [ ] Botões voltar funcionam corretamente
- [ ] Loading states funcionam
- [ ] Validações funcionam

---

## 📝 Observações

Use este espaço para anotar problemas encontrados durante os testes:

```
[Espaço para anotações]
```
