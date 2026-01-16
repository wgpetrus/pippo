# 1. Firebase - Pippo

> Base de dados e autenticação

---

## 📁 Arquivos

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| [configuracao-inicial.md](configuracao-inicial.md) | Configuração completa do Firebase | ✅ Completo |
| [estrutura-firestore.md](estrutura-firestore.md) | Estrutura de coleções e documentos | 📖 Referência |

---

## ✅ Configuração Completa

Firebase está 100% configurado e testado:

- ✅ Firebase Core inicializado
- ✅ Authentication habilitado (Email/Password + Google)
- ✅ Firestore Database criado
- ✅ SHA certificates adicionados
- ✅ Conexão testada com sucesso

---

## 📖 Como Usar

### Configuração (Já Feita)

Consulte [configuracao-inicial.md](configuracao-inicial.md) para detalhes da configuração.

### Estrutura de Dados (Referência)

Consulte [estrutura-firestore.md](estrutura-firestore.md) para:
- Estrutura de coleções
- Campos de cada documento
- Tipos de dados
- Relacionamentos

Esta estrutura será **usada** nas próximas features:
- **2-autenticacao**: cria documento em `users/{userId}`
- **3-onboarding**: cria `courses/` e `stats/gamification`
- **4-gamificacao**: atualiza `stats/gamification`
- **5-licoes**: salva em `progress/` e `history/`
- etc.

---

## 🚀 Próximo Passo

Ir para **[2-autenticacao/](../2-autenticacao/)** e implementar:
- SplashController com lógica de decisão
- AuthController com login/registro
- Integração com Firebase Auth

---

**Status**: ✅ Pronto  
**Tempo gasto**: ~1 hora
