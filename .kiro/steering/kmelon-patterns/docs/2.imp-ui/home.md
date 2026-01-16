# UI Home - Pippo

> Tela principal com navegação por tabs

---

## Telas

| Tela | Arquivo | Status |
|------|---------|--------|
| Home | home_view.dart | ✅ UI Completa |
| Leaderboard | leaderboard_page.dart | ✅ UI Completa |
| Shop | shop_page.dart | ✅ UI Completa |
| Treasure | treasure_page.dart | ✅ UI Completa |
| Profile | profile_page.dart | ✅ UI Completa |

---

## home_view.dart

### Estrutura
```dart
Scaffold(
  appBar: HomeAppbar(),
  body: IndexedStack(
    index: currentNavIndex,
    children: [
      CoursesContent(),    // Tab 0
      LeaderboardPage(),   // Tab 1
      ShopPage(),          // Tab 2
      TreasurePage(),      // Tab 3
      ProfilePage(),       // Tab 4
    ],
  ),
  bottomNavigationBar: BottomNavBar(),
)
```

### Componentes
- HomeAppbar (stats: streak, energy, gems)
- IndexedStack (5 tabs)
- BottomNavigationBar customizado

---

## Tab 0: Courses (Trilha)

### Componentes
- Background com imagem
- UnitHeader (nome da unidade)
- Lista de AppLessonButton (lições)
- LessonPopover (ao clicar na lição)
- LessonTooltip (dica)

---

## Tab 1: Leaderboard

### Componentes
- LeaderboardHeader
- LeagueSelector (ligas)
- LeagueInfo (info da liga atual)
- Lista de RankItem (ranking)
- StatusModal (promoção/rebaixamento)

---

## Tab 2: Shop

### Componentes
- AppBar simples
- SectionTitle "Boosts"
- Lista de BoostItem
- SectionTitle "Collectibles"
- Lista de CollectibleItem
- ShopItemCard (item individual)

---

## Tab 3: Treasure

### Componentes
- TreasureHeader (mascote)
- Lista de ChallengeCard (missões)
- Progresso das missões

---

## Tab 4: Profile

### Componentes
- ProfileHeader (avatar, nome, stats)
- CompleteProfileCard (se incompleto)
- OverviewSection (estatísticas)
- OverviewCard (cards de stats)
- WeeklyProgressChart (gráfico)

---

## Widgets da Feature

### home_appbar.dart
AppBar com stats clicáveis (streak, energy, gems).

### courses_modal.dart
Modal para trocar de curso/idioma.

### energy_modal.dart
Modal com detalhes de energia.

### gems_modal.dart
Modal com detalhes de gems.

### streak_modal.dart
Modal com detalhes de streak.

### lesson_popover.dart
Popover ao clicar em uma lição.

### lesson_tooltip.dart
Tooltip com dica da lição.

### unit_header.dart
Header da unidade com nome e progresso.

---

## Widgets do Leaderboard

### leaderboard_header.dart
Header com título e filtros.

### league_info.dart
Informações da liga atual.

### league_selector.dart
Seletor de ligas.

### rank_item.dart
Item do ranking (posição, avatar, nome, XP).

### status_modal.dart
Modal de promoção/rebaixamento.

---

## Widgets do Shop

### boost_item.dart
Item de boost (elixir, etc).

### collectible_item.dart
Item colecionável.

### section_title.dart
Título de seção.

### shop_item_card.dart
Card de item da loja.

---

## Widgets do Treasure

### challenge_card.dart
Card de desafio/missão.

### treasure_header.dart
Header com mascote treasure hunter.
