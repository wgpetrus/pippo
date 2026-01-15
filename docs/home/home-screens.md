# Telas da Home

> Documentação das telas principais do app Pippo

---

## Visão Geral

A Home é o hub central do app, contendo:
1. **Courses** — Trilha de lições (tela principal)
2. **Shop** — Loja de itens e gems
3. **Leaderboard** — Ranking semanal
4. **Treasure** — Missões e desafios
5. **Profile** — Perfil do usuário

---

## Navegação

```
Home (IndexedStack)
  │
  ├─► [0] Courses ──► Trilha de lições
  ├─► [1] Shop ──► Loja
  ├─► [2] Leaderboard ──► Ranking
  ├─► [3] Treasure ──► Missões
  └─► [4] Profile ──► Perfil
```

**Navegação por estado** (não por rotas), controlada por `currentNavIndex.obs`.

---

## 1. Home (`features/inners/home/`)

Tela principal com trilha de lições.

### Estrutura

```
home/
├── views/
│   └── home_view.dart
├── widgets/
│   ├── courses_modal.dart
│   ├── energy_modal.dart
│   ├── gems_modal.dart
│   ├── home_appbar.dart
│   ├── lesson_popover.dart
│   ├── lesson_tooltip.dart
│   ├── streak_modal.dart
│   └── unit_header.dart
├── controllers/
│   └── home_controller.dart
└── bindings/
    └── home_binding.dart
```

### Componentes da Tela

| Componente | Widget | Descrição |
|------------|--------|-----------|
| AppBar | `HomeAppbar` | Avatar, bandeira, stats (fire, gem, ray) |
| Unit Header | `UnitHeader` | Título da unidade + botão de lista |
| Lesson Buttons | `AppLessonButton` | Botões de lição com animação float |
| Mascote | `AppFloatAnim` | Mascote animado |
| Bottom Bar | `AppBottombar` | Navegação entre tabs |

### Modais da AppBar

| Stat | Modal | Descrição |
|------|-------|-----------|
| Flag | `CoursesModal` | Seleção de cursos, adicionar curso |
| Fire | `StreakModal` | Dias de streak (5 níveis visuais) |
| Gem | `GemsModal` | Compra de gems (3 packs) |
| Ray | `EnergyModal` | Energia (3 estados) |

### Estados do Controller

```dart
// Estados obrigatórios
final isLoading = false.obs;
final errorMessage = ''.obs;

// Estados de UI
final currentNavIndex = 0.obs;      // Tab atual
final selectedStat = Rxn<StatType>(); // Stat selecionada na appbar
final showContinue = false.obs;     // Tooltip "Continue" vs "Start"
```

---

## 2. Shop (`features/inners/shop/`)

Loja de itens, boosts e gems.

### Estrutura

```
shop/
├── views/
│   └── shop_page.dart
└── widgets/
    ├── boost_item.dart
    ├── collectible_item.dart
    ├── section_title.dart
    └── shop_item_card.dart
```

### Seções

- **Spatial Offers** — Ofertas especiais
- **Boosts** — Power-ups temporários
- **Collectibles** — Itens colecionáveis

---

## 3. Leaderboard (`features/inners/leaderboard/`)

Ranking semanal com sistema de ligas.

### Estrutura

```
leaderboard/
├── views/
│   └── leaderboard_page.dart
└── widgets/
    ├── leaderboard_header.dart
    ├── league_info.dart
    ├── league_selector.dart
    ├── rank_item.dart
    └── status_modal.dart
```

### Componentes

| Widget | Descrição |
|--------|-----------|
| `LeaderboardHeader` | Escudo da liga + nome |
| `LeagueSelector` | Seletor de liga (tabs) |
| `LeagueInfo` | Info de promoção/rebaixamento |
| `RankItem` | Item do ranking (posição, avatar, XP) |
| `StatusModal` | Modal de status do usuário |

---

## 4. Treasure (`features/inners/treasure/`)

Missões e desafios para ganhar recompensas.

### Estrutura

```
treasure/
├── views/
│   └── treasure_page.dart
└── widgets/
    ├── challenge_card.dart
    └── treasure_header.dart
```

### Componentes

| Widget | Descrição |
|--------|-----------|
| `TreasureHeader` | Header com mascote e título |
| `ChallengeCard` | Card de desafio com progresso |

---

## 5. Profile (`features/inners/profile/`)

Perfil do usuário com estatísticas.

### Estrutura

```
profile/
├── views/
│   ├── profile_page.dart
│   └── user_profile_page.dart
└── widgets/
    ├── change_avatar_modal.dart
    ├── complete_profile_card.dart
    ├── overview_card.dart
    ├── overview_section.dart
    ├── profile_card.dart
    ├── profile_header.dart
    └── weekly_progress_chart.dart
```

### Componentes

| Widget | Descrição |
|--------|-----------|
| `ProfileHeader` | Avatar, nome, settings |
| `ProfileCard` | Card com info do perfil |
| `OverviewSection` | Seção de estatísticas |
| `OverviewCard` | Card individual de stat |
| `WeeklyProgressChart` | Gráfico de progresso semanal |
| `CompleteProfileCard` | CTA para completar perfil |
| `ChangeAvatarModal` | Modal de troca de avatar |

---

## 6. Friends (`features/inners/friends/`)

Tela de amigos/seguidores (acessada via Profile).

### Estrutura

```
friends/
├── views/
└── widgets/
```

---

## Widgets Globais Utilizados

| Widget | Arquivo | Uso |
|--------|---------|-----|
| `AppBottombar` | `shared/widgets/app_bottombar.dart` | Navegação entre tabs |
| `AppButton` | `shared/widgets/app_button.dart` | Botões nos modais |
| `AppFloatAnim` | `shared/widgets/app_float_anim.dart` | Animação de flutuação |
| `AppLessonButton` | `shared/widgets/app_lesson_button.dart` | Botões de lição |

---

## Modais Detalhados

### CoursesModal
- Lista de cursos do usuário
- Bandeira + nome + barra de progresso
- Botão "Add course" → navega para onboarding (fluxo reduzido)

### StreakModal (5 níveis)
| Dias | Background | Borda | Mascote |
|------|------------|-------|---------|
| 0 | Cinza | Branca | mascot0 |
| 1 | Azul claro | Azul | mascot1 |
| 2-3 | Laranja | Branca | warrior4 |
| 4-6 | Azul escuro | Azul | warrior2 |
| 7+ | Laranja | Branca | warrior5 |

### GemsModal
- 3 packs de gems (100, 500, 1500)
- Pack do meio destacado com badge "DISCOUNT"
- Botão "Go to shop" → navega para tab Shop

### EnergyModal (3 estados)
| Energia | Mensagem |
|---------|----------|
| 5 (full) | "Fully charged ⚡ Ready to go?" |
| 1 | "Only one flash left... use it wisely!" |
| 0 | "No flashes left; Take a short break..." |

---

## Rotas

| Rota | Feature | Descrição |
|------|---------|-----------|
| `/home` | home | Tela principal (IndexedStack) |

**Nota:** As tabs internas (Shop, Leaderboard, etc.) não têm rotas próprias — navegação por estado.

---

## Observações

- Home usa `IndexedStack` para manter estado das tabs
- Cada tab é uma feature separada em `features/inners/`
- Modais usam `showDialog` padrão do Flutter
- Popover usa package `popover` para menu de lições
- Animações de float usam `AppFloatAnim` customizado
