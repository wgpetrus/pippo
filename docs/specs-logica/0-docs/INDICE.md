# Índice - Specs de Lógica

> Navegação rápida por todos os arquivos

---

## 📋 Documentação Geral

- [README.md](../README.md) - Visão geral e como usar
- [ORDEM-IMPLEMENTACAO.md](../ORDEM-IMPLEMENTACAO.md) - Sequência de implementação
- [regras-criticas.md](regras-criticas.md) - Regras que NUNCA devem ser quebradas
- [traducao-idioma.md](traducao-idioma.md) - Sistema de tradução e idioma do app
- [packages-dados.md](packages-dados.md) - Packages de dados vs packages de UI

---

## 🔥 1. Firebase (Base)

- [estrutura-firestore.md](1-firebase/estrutura-firestore.md) - Estrutura completa de coleções e campos

---

## 🔐 2. Autenticação (Entrada no App)

- [splash-decisao.md](2-autenticacao/splash-decisao.md) - Ordem CRÍTICA de verificações ao abrir app
- [login.md](2-autenticacao/login.md) - Processo de login e recuperação de senha

---

## 🎯 3. Onboarding (Primeiro Acesso)

- [fluxo-completo.md](3-onboarding/fluxo-completo.md) - Processo de primeiro acesso e criação de conta

---

## 🎮 4. Gamificação (Sistema de Recompensas)

- [streak.md](4-gamificacao/streak.md) - Sistema de dias consecutivos
- [energia.md](4-gamificacao/energia.md) - Sistema de sparks/flashes
- [xp-niveis.md](4-gamificacao/xp-niveis.md) - Sistema de experiência e progressão
- [gems.md](4-gamificacao/gems.md) - Moeda virtual do jogo

---

## 📚 5. Lições (Core do App)

- [progressao.md](5-licoes/progressao.md) - Progressão linear e desbloqueio
- [fluxo-licao.md](5-licoes/fluxo-licao.md) - Processo completo de uma lição
- [tipos-exercicios.md](5-licoes/tipos-exercicios.md) - Validação de cada tipo de exercício

---

## 🎁 6. Desafios (Missões)

- [treasure.md](6-desafios/treasure.md) - Sistema de missões e desafios

---

## 🏆 7. Ranking (Competição)

- [leaderboard.md](7-ranking/leaderboard.md) - Competição semanal e ligas

---

## 🛒 8. Loja (Compras)

- [compras.md](8-loja/compras.md) - Sistema de compras e boosts

---

## 👤 9. Perfil (Social)

- [edicao.md](9-perfil/edicao.md) - Edição de perfil e configurações
- [social.md](9-perfil/social.md) - Sistema de follow/unfollow
- [cursos.md](9-perfil/cursos.md) - Gerenciar cursos

---

## 🔍 Busca Rápida

### Por Funcionalidade

**Autenticação:**
- Splash → [splash-decisao.md](2-autenticacao/splash-decisao.md)
- Login → [login.md](2-autenticacao/login.md)
- Onboarding → [fluxo-completo.md](3-onboarding/fluxo-completo.md)

**Gamificação:**
- Streak → [streak.md](4-gamificacao/streak.md)
- Energia → [energia.md](4-gamificacao/energia.md)
- XP → [xp-niveis.md](4-gamificacao/xp-niveis.md)
- Gems → [gems.md](4-gamificacao/gems.md)

**Lições:**
- Progressão → [progressao.md](5-licoes/progressao.md)
- Fluxo → [fluxo-licao.md](5-licoes/fluxo-licao.md)
- Exercícios → [tipos-exercicios.md](5-licoes/tipos-exercicios.md)

**Social:**
- Ranking → [leaderboard.md](7-ranking/leaderboard.md)
- Follow → [social.md](9-perfil/social.md)

**Compras:**
- Loja → [compras.md](8-loja/compras.md)
- Desafios → [treasure.md](6-desafios/treasure.md)

**Perfil:**
- Edição → [edicao.md](9-perfil/edicao.md)
- Cursos → [cursos.md](9-perfil/cursos.md)

---

## 📊 Estrutura de Dados

**Firebase:**
- Todas as coleções → [estrutura-firestore.md](1-firebase/estrutura-firestore.md)

**Principais coleções:**
- `users/{userId}` - Dados do usuário
- `users/{userId}/courses/{courseId}` - Cursos do usuário
- `users/{userId}/stats/gamification` - Stats de gamificação
- `users/{userId}/history/{date}` - Histórico diário
- `courses/{courseId}` - Cursos disponíveis
- `challenges/{challengeId}` - Desafios disponíveis

---

## ⚠️ Regras Críticas

**Ordem de verificações:**
- Splash → [splash-decisao.md](2-autenticacao/splash-decisao.md)
- Iniciar lição → [fluxo-licao.md](5-licoes/fluxo-licao.md)
- Completar lição → [fluxo-licao.md](5-licoes/fluxo-licao.md)

**Fórmulas exatas:**
- XP para nível → [xp-niveis.md](4-gamificacao/xp-niveis.md)
- Regeneração energia → [energia.md](4-gamificacao/energia.md)
- Streak → [streak.md](4-gamificacao/streak.md)

**Todas as regras:**
- [regras-criticas.md](regras-criticas.md)

---

## 🌍 Tradução

**Sistema de tradução:**
- [traducao-idioma.md](traducao-idioma.md)

**Pontos importantes:**
- Interface em português
- GetX Translate
- SelectLanguage é para idioma de aprendizado
- Idioma da interface segue sistema do usuário
