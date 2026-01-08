# Definição do Projeto

> App de aprendizado de idiomas gamificado

---

## Informações Básicas

| Campo | Valor |
|-------|-------|
| **Nome do Projeto** | Pippo |
| **Descrição** | App de aprendizado de idiomas com gamificação, similar ao Duolingo |
| **Plataformas** | [x] Android [x] iOS [ ] Web |

---

## Objetivo

Ensinar idiomas de forma divertida e engajante através de lições curtas, exercícios interativos e mecânicas de gamificação (streak, gems, energia, ranking).

---

## Público-Alvo

- Pessoas que querem aprender um novo idioma
- Usuários que preferem aprendizado em pequenas doses diárias
- Faixa etária: 13+ anos

---

## Features Principais

1. **Lições gamificadas** — Exercícios variados (imagem, tradução, áudio, drag-drop)
2. **Sistema de Streak** — Sequência de dias de estudo para engajamento
3. **Gems e Energy** — Moedas virtuais e sistema de vidas
4. **Leaderboard** — Ranking semanal com ligas
5. **Treasure Hunt** — Missões especiais para ganhar recompensas
6. **Perfil social** — Seguidores, conquistas, estatísticas

---

## Como Funciona

### Fluxo de Aprendizado
1. Usuário escolhe idioma que quer aprender
2. App apresenta trilha de unidades/lições
3. Cada lição tem ~5-10 exercícios variados
4. Ao completar, ganha XP, gems e mantém streak
5. Progresso desbloqueia novas unidades

### Tipos de Exercícios
- **Selecionar imagem correta** — Mostra palavra, escolhe entre 4 imagens
- **Selecionar tradução** — Mostra imagem/palavra, escolhe tradução correta
- **Completar equação** — Para idiomas com caracteres especiais
- **Arrastar palavras** — Montar frase na ordem correta
- **Ouvir e selecionar** — Exercício de listening

### Sistema de Gamificação
- **Streak**: Dias consecutivos de estudo (perde se não estudar)
- **Gems**: Moeda para comprar itens na loja
- **Energy/Sparks**: Vidas que regeneram com tempo
- **Leaderboard**: Competição semanal, sobe/desce de liga

---

## Integrações

### Firebase
- [x] Authentication
- [x] Firestore
- [ ] Storage
- [ ] Analytics
- [ ] Crashlytics

### APIs Externas
| API | Descrição |
|-----|-----------|
| TTS | Text-to-speech para pronúncia |

---

## Design

| Campo | Valor |
|-------|-------|
| **Link do Figma** | https://www.figma.com/design/WcOkjqtenFTf802ZufPovx/Gemglot |
| **Fonte Principal** | (definir) |
| **Cor Primária** | (definir) |

---

## Fluxos Principais

### Autenticação
1. Splash → verifica se logado
2. Onboarding → seleção de idioma, nome
3. Auth → cadastro/login com email
4. OTP → verificação de email

### Fluxo Principal (Home)
- **Bottom nav** com 5 tabs: Courses, Leaderboard, Shop, Treasure, Profile
- **Header** com stats clicáveis: Streak, Energy, Gems
- Cada stat abre página de detalhes

### Fluxo de Lição
1. Seleciona unidade na trilha
2. Inicia lição (consome energia)
3. Completa exercícios com feedback imediato
4. Tela de conclusão com recompensas
5. Atualiza streak se primeiro do dia

---

## Observações

- App em inglês (interface e conteúdo)
- Mascote/personagem aparece em várias telas
- Design colorido e amigável
- Animações de feedback são importantes para UX
