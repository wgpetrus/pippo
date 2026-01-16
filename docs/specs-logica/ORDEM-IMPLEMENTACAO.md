# Ordem de Implementação

> Sequência lógica para implementar as specs do Pippo

---

## 📋 Visão Geral

As pastas foram numeradas de **1 a 9** seguindo a ordem ideal de implementação, respeitando as dependências entre módulos.

---

## 🔢 Sequência de Implementação

### 1️⃣ Firebase (Base de Tudo)

**Pasta**: `1-firebase/`

**Por que primeiro?**
- É a base de dados de todo o app
- Todos os outros módulos dependem da estrutura Firestore
- Sem Firebase configurado, nada funciona

**O que implementar:**
- Configurar Firebase no projeto
- Criar estrutura de coleções no Firestore
- Configurar Security Rules básicas
- Testar conexão

**Arquivos:**
- [estrutura-firestore.md](1-firebase/estrutura-firestore.md)

**Tempo estimado**: 1-2 dias

---

### 2️⃣ Autenticação (Entrada no App)

**Pasta**: `2-autenticacao/`

**Por que agora?**
- Usuário precisa estar autenticado para usar o app
- Splash decide para onde navegar
- Base para onboarding e home

**O que implementar:**
- SplashController com lógica de decisão
- AuthController com login/logout
- Recuperação de senha
- Handlers de erro Firebase Auth

**Arquivos:**
- [splash-decisao.md](2-autenticacao/splash-decisao.md)
- [login.md](2-autenticacao/login.md)

**Dependências:**
- ✅ Firebase configurado

**Tempo estimado**: 2-3 dias

---

### 3️⃣ Onboarding (Primeiro Acesso)

**Pasta**: `3-onboarding/`

**Por que agora?**
- Usuário novo precisa criar conta
- Coleta dados iniciais do usuário
- Cria primeiro curso
- Inicializa stats de gamificação

**O que implementar:**
- OnboardingController
- Fluxo de 14 telas
- Criação de conta Firebase
- Inicialização de dados no Firestore

**Arquivos:**
- [fluxo-completo.md](3-onboarding/fluxo-completo.md)

**Dependências:**
- ✅ Firebase configurado
- ✅ Autenticação funcionando

**Tempo estimado**: 3-4 dias

---

### 4️⃣ Gamificação (Sistema de Recompensas)

**Pasta**: `4-gamificacao/`

**Por que agora?**
- Base para o sistema de lições
- Lições dependem de energia, XP, gems
- Streak precisa ser atualizado ao completar lições

**O que implementar:**
- Sistema de Streak
- Sistema de Energia (regeneração)
- Sistema de XP e Níveis
- Sistema de Gems

**Arquivos:**
- [streak.md](4-gamificacao/streak.md)
- [energia.md](4-gamificacao/energia.md)
- [xp-niveis.md](4-gamificacao/xp-niveis.md)
- [gems.md](4-gamificacao/gems.md)

**Dependências:**
- ✅ Firebase configurado
- ✅ Usuário autenticado
- ✅ Stats inicializadas no onboarding

**Tempo estimado**: 4-5 dias

---

### 5️⃣ Lições (Core do App)

**Pasta**: `5-licoes/`

**Por que agora?**
- É o core do app (aprendizado de idiomas)
- Depende de gamificação (energia, XP, gems)
- Base para desafios e ranking

**O que implementar:**
- Sistema de progressão e desbloqueio
- LessonController
- 4 tipos de exercícios
- Fluxo completo de lição
- Sistema de corações
- Recompensas ao completar

**Arquivos:**
- [progressao.md](5-licoes/progressao.md)
- [fluxo-licao.md](5-licoes/fluxo-licao.md)
- [tipos-exercicios.md](5-licoes/tipos-exercicios.md)

**Dependências:**
- ✅ Gamificação funcionando
- ✅ Energia disponível
- ✅ Sistema de XP e gems

**Tempo estimado**: 5-7 dias

---

### 6️⃣ Desafios (Missões)

**Pasta**: `6-desafios/`

**Por que agora?**
- Depende de lições (completar lições atualiza desafios)
- Depende de XP (ganhar XP atualiza desafios)
- Adiciona camada extra de gamificação

**O que implementar:**
- TreasureController
- Sistema de desafios diários/semanais
- Atualização de progresso
- Coleta de recompensas

**Arquivos:**
- [treasure.md](6-desafios/treasure.md)

**Dependências:**
- ✅ Lições funcionando
- ✅ Sistema de XP
- ✅ Sistema de gems

**Tempo estimado**: 2-3 dias

---

### 7️⃣ Ranking (Competição)

**Pasta**: `7-ranking/`

**Por que agora?**
- Depende de XP semanal (ganho em lições)
- Adiciona competição entre usuários
- Requer Cloud Function para reset semanal

**O que implementar:**
- LeaderboardController
- Sistema de ligas
- Zonas de promoção/rebaixamento
- Modal de status
- Cloud Function de reset semanal

**Arquivos:**
- [leaderboard.md](7-ranking/leaderboard.md)

**Dependências:**
- ✅ Sistema de XP funcionando
- ✅ Lições gerando XP semanal

**Tempo estimado**: 3-4 dias

---

### 8️⃣ Loja (Compras)

**Pasta**: `8-loja/`

**Por que agora?**
- Depende de gems (moeda)
- Depende de gamificação (boosts afetam XP/gems)
- Adiciona monetização

**O que implementar:**
- ShopController
- Sistema de compra com gems
- Boosts temporários (XP, Gem Multiplier)
- Streak Freeze
- Energy Refill
- IAP (In-App Purchase)

**Arquivos:**
- [compras.md](8-loja/compras.md)

**Dependências:**
- ✅ Sistema de gems
- ✅ Sistema de energia
- ✅ Sistema de streak

**Tempo estimado**: 3-4 dias

---

### 9️⃣ Perfil (Social e Configurações)

**Pasta**: `9-perfil/`

**Por que por último?**
- Depende de tudo (stats, cursos, progresso)
- Adiciona camada social
- Configurações afetam todo o app

**O que implementar:**
- ProfileController
- Edição de perfil
- Sistema de follow/unfollow
- Gerenciar cursos
- Configurações
- Alterar senha
- Vincular telefone
- Excluir conta

**Arquivos:**
- [edicao.md](9-perfil/edicao.md)
- [social.md](9-perfil/social.md)
- [cursos.md](9-perfil/cursos.md)

**Dependências:**
- ✅ Tudo implementado
- ✅ Stats de gamificação
- ✅ Sistema de cursos

**Tempo estimado**: 4-5 dias

---

## 📊 Resumo de Dependências

```
1. Firebase (base)
   ↓
2. Autenticação (entrada)
   ↓
3. Onboarding (primeiro acesso)
   ↓
4. Gamificação (recompensas)
   ↓
5. Lições (core) ←─────┐
   ↓                    │
6. Desafios ────────────┘
   ↓
7. Ranking (competição)
   ↓
8. Loja (monetização)
   ↓
9. Perfil (social)
```

---

## ⏱️ Tempo Total Estimado

| Módulo | Tempo |
|--------|-------|
| 1. Firebase | 1-2 dias |
| 2. Autenticação | 2-3 dias |
| 3. Onboarding | 3-4 dias |
| 4. Gamificação | 4-5 dias |
| 5. Lições | 5-7 dias |
| 6. Desafios | 2-3 dias |
| 7. Ranking | 3-4 dias |
| 8. Loja | 3-4 dias |
| 9. Perfil | 4-5 dias |
| **TOTAL** | **27-37 dias** |

**Nota**: Tempos são estimativas para 1 desenvolvedor trabalhando full-time.

---

## ✅ Checklist de Implementação

### Antes de Começar
- [ ] Ler [README.md](README.md)
- [ ] Ler [regras-criticas.md](0-docs/regras-criticas.md)
- [ ] Ler [traducao-idioma.md](0-docs/traducao-idioma.md)
- [ ] Configurar ambiente de desenvolvimento

### Durante a Implementação
- [ ] Seguir ordem numérica (1 → 9)
- [ ] Implementar testes para cada módulo
- [ ] Validar dependências antes de prosseguir
- [ ] Seguir regras críticas
- [ ] Usar português na interface

### Após Cada Módulo
- [ ] Testar funcionalidade completa
- [ ] Validar integração com Firebase
- [ ] Verificar se segue padrões da empresa
- [ ] Documentar decisões importantes
- [ ] Commit com mensagem descritiva

---

## 🚨 Regras Importantes

### NUNCA Pular Etapas

❌ **Não fazer:**
- Implementar lições antes de gamificação
- Implementar ranking antes de lições
- Implementar loja antes de gems

✅ **Sempre:**
- Seguir ordem numérica
- Validar dependências
- Testar antes de prosseguir

### NUNCA Inverter Ordem de Verificações

Consultar [regras-criticas.md](0-docs/regras-criticas.md) para:
- Ordem ao abrir app (Splash)
- Ordem ao iniciar lição
- Ordem ao completar lição

### SEMPRE Usar Fórmulas Exatas

- XP para nível: `nível × 100`
- Regeneração energia: `1 a cada 30 min`
- Próxima energia: `30 - (minutos % 30)`

---

## 💡 Dicas

### Para Cada Módulo

1. **Ler spec completa** antes de começar
2. **Criar controller** com estados obrigatórios
3. **Implementar lógica** seguindo spec
4. **Conectar com Firebase** 
5. **Testar fluxo completo**
6. **Validar regras críticas**

### Paralelização

Alguns módulos podem ser implementados em paralelo por desenvolvedores diferentes:

**Após Gamificação:**
- Lições (dev 1)
- Perfil básico (dev 2)

**Após Lições:**
- Desafios (dev 1)
- Ranking (dev 2)
- Loja (dev 3)

---

## 📖 Recursos

- **Navegação**: [INDICE.md](0-docs/INDICE.md)
- **Visão geral**: [RESUMO-EXECUTIVO.md](0-docs/RESUMO-EXECUTIVO.md)
- **Conclusão**: [CONCLUSAO.md](0-docs/CONCLUSAO.md)
- **Regras críticas**: [regras-criticas.md](0-docs/regras-criticas.md)
- **Tradução**: [traducao-idioma.md](0-docs/traducao-idioma.md)

---

**Última atualização**: Janeiro 2026  
**Versão**: 1.0  
**Status**: ✅ Pronto para implementação
