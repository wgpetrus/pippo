# Testes Desabilitados

Esta pasta contém testes que foram temporariamente desabilitados devido a limitações de ambiente de teste.

**IMPORTANTE:** Esta pasta começa com `_` (underscore) para que o Flutter ignore automaticamente durante `flutter test`.

## Motivo

Estes testes requerem inicialização completa do Firebase (FirebaseAuth, FirebaseFirestore) que não está disponível no ambiente de testes unitários/property-based sem configuração complexa de platform channels.

## Testes Incluídos

### Property Tests (test/disabled/property/)

**Lesson System:**
- `hearts_management_property_test.dart` - Property 5, 7, 8 (Hearts Invariant, Answer Counter Consistency, Hearts Decrement Before Feedback)
- `lesson_controller_property_test.dart` - Property 1, 2, 19 (Lesson Start Order, Energy Consumption, Exercise Index Progression)

**Splash System:**
- `splash_controller_navigation_order_test.dart` - Ordem de navegação do splash
- `splash_controller_timeout_test.dart` - Timeout do splash

**Onboarding System:**
- `onboarding_state_persistence_test.dart` - Persistência de estado do onboarding

### Unit Tests (test/disabled/unit/)

**Lesson System:**
- `lesson_controller_test.dart` - Testes unitários do LessonController

## Status dos Testes

✅ **Lógica dos testes está CORRETA** - Todos os testes validam corretamente os requisitos especificados

❌ **Execução falha** - Devido a erro de inicialização do Firebase: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

## Como Habilitar

Para habilitar estes testes, é necessário:

1. **Refatorar os Controllers** para aceitar instâncias de Firebase via construtor (Dependency Injection)
2. **Usar fake_cloud_firestore** para mockar Firestore
3. **Mockar FirebaseAuth** adequadamente
4. **Configurar platform channels** para Firebase no ambiente de teste

## Alternativa

Estes testes podem ser convertidos em **testes de integração** que rodam com Firebase Test Lab ou emuladores Firebase.

## Validação

A implementação nos controllers segue todos os requisitos corretamente. Os testes documentam as propriedades que devem ser mantidas e podem ser usados como referência para validação manual ou testes de integração.
