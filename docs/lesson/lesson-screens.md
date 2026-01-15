# Telas de Lição

> Documentação das telas de exercícios do app Pippo

---

## Visão Geral

A feature Lesson contém os exercícios de aprendizado:
1. **Sections** — Lista de seções de um curso
2. **Image Exercise** — Selecionar imagem correta
3. **Translation Exercise** — Selecionar tradução correta
4. **Word Exercise** — Ordenar palavras para formar frase
5. **Match Exercise** — Combinar pares (áudio + texto)
6. **Complete** — Tela de conclusão com recompensas

---

## Navegação

```
Home ──► Sections ──► Image Exercise ──► Translation Exercise ──► Word Exercise ──► Match Exercise ──► Complete ──► Home
```

**Navegação por `Get.to()` e `Get.off()`** entre exercícios.

---

## 1. Lesson (`features/core/lesson/`)

### Estrutura Atual

```
lesson/
├── views/
│   ├── sections_page.dart
│   ├── image_exercise_page.dart
│   ├── translation_exercise_page.dart
│   ├── word_exercise_page.dart
│   ├── match_exercise_page.dart
│   └── complete_page.dart
└── widgets/
    ├── audio_card.dart
    ├── audio_word_button.dart
    ├── exercise_header.dart
    ├── feedback_bottom_sheet.dart
    ├── image_option_card.dart
    ├── image_with_label.dart
    ├── lesson_option_card.dart
    ├── low_energy_modal.dart
    ├── mascot_bubble.dart
    ├── section_card.dart
    ├── translation_option_card.dart
    ├── word_chip.dart
    └── word_zone.dart
```

### Fluxo de Telas

| # | Tela | Arquivo | Descrição |
|---|------|---------|-----------|
| 1 | Sections | `sections_page.dart` | Lista de seções do curso |
| 2 | Image Exercise | `image_exercise_page.dart` | Selecionar imagem correta |
| 3 | Translation Exercise | `translation_exercise_page.dart` | Selecionar tradução |
| 4 | Word Exercise | `word_exercise_page.dart` | Ordenar palavras |
| 5 | Match Exercise | `match_exercise_page.dart` | Combinar pares |
| 6 | Complete | `complete_page.dart` | Conclusão com recompensas |

---

## Componentes por Tela

### Sections Page
| Componente | Widget | Descrição |
|------------|--------|-----------|
| AppBar | `AppBackButton` | Voltar + título do curso |
| Section Cards | `SectionCard` | Card com status e progresso |

### Exercise Pages (comum)
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Header | `ExerciseHeader` | Progresso + energia + voltar |
| Feedback | `FeedbackBottomSheet` | Modal correto/errado |
| Botão | `AppButton` | Botão "Check" |

### Image Exercise
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Áudio | `AudioWordButton` | Botão de áudio + palavra |
| Opções | `LessonOptionCard` | Grid 2x2 de imagens |

### Translation Exercise
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Imagem | `ImageWithLabel` | Imagem com balão de label |
| Opções | `LessonOptionCard` | Lista de traduções |
| Modal | `LowEnergyModal` | Aviso de energia baixa |

### Word Exercise
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Mascote | `MascotBubble` | Mascote com balão de áudio |
| Zona | `WordZone` | Área de resposta |
| Chips | `WordChip` | Palavras selecionáveis |

### Match Exercise
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Áudio | `AudioCard` | Card de áudio com waveform |
| Texto | `LessonOptionCard` | Card de texto |

### Complete Page
| Componente | Widget | Descrição |
|------------|--------|-----------|
| Mascote | Imagem | Mascote com estrelas |
| Stats | Cards customizados | XP, Accuracy, Time, Gems |
| Botão | `AppButton` | "Claim Reward" |

---

## Widgets Específicos

### SectionCard (4 estados)
| Status | Visual |
|--------|--------|
| `completed` | Barra verde 5/5, sparkles, troféu dourado |
| `inProgress` | Barra azul parcial, troféu cinza |
| `notStarted` | Sem barra, texto "START NOW" |
| `locked` | Fundo cinza, cadeado, mascote desbotado |

### LessonOptionCard (4 estados)
| Status | Visual |
|--------|--------|
| `normal` | Borda cinza, fundo branco |
| `selected` | Borda azul, fundo azul claro, sombra |
| `correct` | Borda verde, fundo verde claro, ícone ✓ |
| `wrong` | Borda vermelha, fundo vermelho claro, ícone ✗ |

### FeedbackBottomSheet (2 tipos)
| Tipo | Visual |
|------|--------|
| `correct` | Fundo verde, "Correct!", botão "Continue" |
| `wrong` | Fundo vermelho, mascote, resposta correta, botão "Got It" |

---

## Widgets Globais Utilizados

| Widget | Arquivo | Uso |
|--------|---------|-----|
| `AppButton` | `shared/widgets/app_button.dart` | Botão "Check" em todos exercícios |
| `AppBackButton` | `shared/widgets/app_back_button.dart` | Voltar na AppBar |

---

## Observações

- Todas as telas são `StatefulWidget` (gerenciam estado de seleção)
- Navegação entre exercícios usa `Get.off()` para não acumular stack
- Feedback usa `wolt_modal_sheet` (padrão da empresa)
- Dados mockados para fase de UI

