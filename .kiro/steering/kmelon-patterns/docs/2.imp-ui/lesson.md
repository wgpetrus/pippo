# UI Lesson - Pippo

> Telas de exercícios e lições

---

## Telas

| Tela | Arquivo | Status |
|------|---------|--------|
| Sections | sections_page.dart | ✅ UI Completa |
| Image Exercise | image_exercise_page.dart | ✅ UI Completa |
| Translation Exercise | translation_exercise_page.dart | ✅ UI Completa |
| Word Exercise | word_exercise_page.dart | ✅ UI Completa |
| Match Exercise | match_exercise_page.dart | ✅ UI Completa |
| Complete | complete_page.dart | ✅ UI Completa |

---

## sections_page.dart

### Componentes
- AppAppbar com nome do curso
- Lista de SectionCard (unidades)
- Progresso de cada seção

---

## image_exercise_page.dart

### Componentes
- ExerciseHeader (progress, close, hearts)
- MascotBubble (pergunta)
- Grid de ImageWithLabel (4 opções)
- FeedbackBottomSheet (resposta)

### Tipo de Exercício
Mostra palavra, usuário escolhe imagem correta.

---

## translation_exercise_page.dart

### Componentes
- ExerciseHeader
- AudioCard (palavra com áudio)
- Lista de LessonOptionCard (traduções)
- FeedbackBottomSheet

### Tipo de Exercício
Ouve/vê palavra, escolhe tradução correta.

---

## word_exercise_page.dart

### Componentes
- ExerciseHeader
- MascotBubble (instrução)
- WordZone (área de resposta)
- Lista de WordChip (palavras disponíveis)
- FeedbackBottomSheet

### Tipo de Exercício
Arrastar palavras para formar frase.

---

## match_exercise_page.dart

### Componentes
- ExerciseHeader
- Duas colunas de AudioWordButton
- Linhas conectando pares
- FeedbackBottomSheet

### Tipo de Exercício
Conectar palavras com suas traduções.

---

## complete_page.dart

### Componentes
- Mascote celebrando
- Título "Lesson Complete!"
- Estatísticas (XP, accuracy, time)
- AppButton "Continue"

---

## Widgets da Feature

### audio_card.dart
Card com palavra e botão de áudio.

### audio_word_button.dart
Botão de palavra com áudio (match exercise).

### exercise_header.dart
Header com progresso, botão fechar e corações.

### feedback_bottom_sheet.dart
Bottom sheet de feedback (certo/errado).

### image_with_label.dart
Imagem com label embaixo (image exercise).

### lesson_option_card.dart
Card de opção selecionável.

### low_energy_modal.dart
Modal quando não tem energia.

### mascot_bubble.dart
Balão de fala do mascote.

### section_card.dart
Card de seção/unidade.

### word_chip.dart
Chip de palavra arrastável.

### word_zone.dart
Zona onde as palavras são colocadas.
