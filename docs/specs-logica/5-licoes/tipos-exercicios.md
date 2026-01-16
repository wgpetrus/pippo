# Tipos de Exercícios

> Validação e lógica de cada tipo de exercício

---

## 1. Image Exercise (Selecionar Imagem)

### Validação

```dart
bool validateImageExercise(String selectedOptionId) {
  final correctOption = exercise.options.firstWhere(
    (opt) => opt.isCorrect,
  );
  
  return selectedOptionId == correctOption.id;
}
```

---

## 2. Translation Exercise (Selecionar Tradução)

### Validação

```dart
bool validateTranslationExercise(String selectedOptionId) {
  final correctOption = exercise.options.firstWhere(
    (opt) => opt.isCorrect,
  );
  
  return selectedOptionId == correctOption.id;
}
```

---

## 3. Word Exercise (Ordenar Palavras)

### Validação

```dart
bool validateWordExercise(List<String> selectedWords) {
  // 1. Verificar se quantidade está correta
  if (selectedWords.length != exercise.correctOrder.length) {
    return false;
  }
  
  // 2. Comparar ordem exata
  for (int i = 0; i < selectedWords.length; i++) {
    if (selectedWords[i] != exercise.correctOrder[i]) {
      return false;
    }
  }
  
  return true;
}
```

### Lógica de Interação

```dart
// Zona de resposta (palavras selecionadas)
final selectedWords = <String>[].obs;

// Adicionar palavra
void addWord(String word) {
  selectedWords.add(word);
  availableWords.remove(word);
}

// Remover palavra (clicar nela na zona)
void removeWord(String word) {
  selectedWords.remove(word);
  availableWords.add(word);
}

// Verificar se pode submeter
bool get canSubmit => selectedWords.length == exercise.correctOrder.length;
```

---

## 4. Match Exercise (Combinar Pares)

### Validação

```dart
bool validateMatchPair(String audioId, String textId) {
  final pair = exercise.pairs.firstWhere(
    (p) => p.audio == audioId,
  );
  
  return pair.text == textId;
}
```

### Lógica de Interação

```dart
// Estado
String? selectedAudio;
final matchedPairs = <String, String>{}.obs; // audioId -> textId

// Selecionar áudio
void selectAudio(String audioId) {
  selectedAudio = audioId;
}

// Selecionar texto
void selectText(String textId) {
  if (selectedAudio == null) return;
  
  // Validar par
  if (validateMatchPair(selectedAudio!, textId)) {
    // Correto: adicionar aos pares
    matchedPairs[selectedAudio!] = textId;
    selectedAudio = null;
    
    // Verificar se completou todos
    if (matchedPairs.length == exercise.pairs.length) {
      // Próximo exercício
      submitAnswer('completed');
    }
  } else {
    // Errado: mostrar feedback rápido
    showQuickFeedback('Tente novamente');
    selectedAudio = null;
  }
}

// Verificar se item já foi combinado
bool isMatched(String id) {
  return matchedPairs.containsKey(id) || 
         matchedPairs.containsValue(id);
}
```

---

## Feedback Visual

### Correto
- Background: Verde claro
- Título: "Correto!"
- Subtítulo: "Isso mesmo!"
- Botão: "Continuar" (verde)

### Errado
- Background: Vermelho claro
- Mascote: Triste
- Balão: "Ops! Boa tentativa, mas não é bem assim."
- Mostrar resposta correta
- Botão: "Entendi" (vermelho)
- Perder 1 coração

---

## Reutilização de Assets

**IMPORTANTE**: Usar mesma base de assets em múltiplos exercícios.

Exemplo:
- Exercício 1 (image): palavra "apple"
- Exercício 5 (translation): palavra "apple"
- Exercício 8 (match): palavra "apple"

Todos usam:
- Mesmo áudio: `apple.mp3`
- Mesma imagem: `apple.png`
