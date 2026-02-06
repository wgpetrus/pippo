# Ajustes de Testes - ProfileCoursesController

## Controller Refatorado

**Arquivo**: `lib/features/inners/profile/controllers/profile_courses_controller.dart`

**Responsabilidade**: Gerenciar cursos do usuário (adicionar, remover, definir primário)

## Estados Migrados

- `userCourses`
- `primaryCourseId`
- `isLoading`, `errorMessage`

## Métodos Migrados

- `loadUserCourses()`
- `setPrimaryCourse(String courseId, {bool showSnackbar = true})`
- `removeCourse(String courseId)`
- `_getLanguageName(String code)`
- `_getLanguageFlag(String code)`

## Testes que Precisam Ser Atualizados

### Testes Unitários

**Arquivo**: `test/unit/features/inners/profile/controllers/profile_controller_test.dart`

**Grupos de teste afetados**:

1. **Course Management Tests**
   - `21.1 Test loadUserCourses() success`
   - `21.2 Test setPrimaryCourse() success`
   - `21.3 Test setPrimaryCourse() updates all courses`
   - `21.4 Test removeCourse() success`

**Mudanças necessárias**:
```dart
// ANTES
import 'package:pippo/features/inners/profile/controllers/profile_controller.dart';
controller = ProfileController();

// DEPOIS
import 'package:pippo/features/inners/profile/controllers/profile_courses_controller.dart';
controller = ProfileCoursesController();
```

### Testes de Propriedade

**Arquivo**: `test/property/features/inners/profile/controllers/profile_controller_property_test.dart`

**Propriedades afetadas**:

1. **Property 4: Primary Course Exclusivity**
   - Property 4a: Exactly one course is primary after setPrimaryCourse
   - Property 4b: Setting different course as primary updates correctly
   - Property 4c: Primary course ID matches the selected course
   - Property 4d: All other courses have isPrimary = false
   - Property 4e: Primary course exclusivity is maintained

**Mudanças necessárias**:
```dart
// ANTES
import 'package:pippo/features/inners/profile/controllers/profile_controller.dart';
final controller = ProfileController();

// DEPOIS
import 'package:pippo/features/inners/profile/controllers/profile_courses_controller.dart';
final controller = ProfileCoursesController();
```

### Testes de Integração

**Arquivos afetados**:
- `test/integration/course_management_flow_integration_test.dart`

**Mudanças necessárias**:
- Atualizar imports para `ProfileCoursesController`
- Atualizar `Get.find<ProfileController>()` para `Get.find<ProfileCoursesController>()`
- Verificar que gerenciamento de cursos funciona

## Validações Necessárias

Após atualizar os testes:

1. ✅ Carregamento de cursos do usuário funciona
2. ✅ Apenas um curso tem `isPrimary = true` por vez
3. ✅ Definir curso primário atualiza todos os cursos
4. ✅ Remoção de curso funciona corretamente
5. ✅ `primaryCourseId` é atualizado corretamente
6. ✅ Helpers de nome e bandeira de idioma funcionam

## Estrutura de Curso

```dart
{
  'id': String,
  'languageCode': String,
  'languageName': String,
  'level': String,
  'isActive': bool,
  'isPrimary': bool,
  'totalXp': int,
  'lessonsCompleted': int,
}
```

## Regra de Exclusividade do Curso Primário

**Invariante**: Para qualquer usuário, **no máximo um curso** deve ter `isPrimary = true` em qualquer momento.

**Implementação**:
```dart
Future<void> setPrimaryCourse(String courseId) async {
  // 1. Define todos os cursos como isPrimary = false
  for (final course in userCourses) {
    course['isPrimary'] = false;
  }
  
  // 2. Define o curso selecionado como isPrimary = true
  final selectedCourse = userCourses.firstWhere((c) => c['id'] == courseId);
  selectedCourse['isPrimary'] = true;
  
  // 3. Atualiza primaryCourseId
  primaryCourseId.value = courseId;
  
  // 4. Persiste no Firestore
  await _firestore.collection('users').doc(userId)
      .collection('courses').doc(courseId)
      .update({'isPrimary': true});
}
```

## Mapeamento de Idiomas

### Códigos de Idioma Suportados
- `en` → English (USA Flag)
- `es` → Spanish (Spanish Flag)
- `fr` → French (French Flag)
- `de` → German (Germany Flag)
- `pt` → Portuguese (Brazil Flag)
- `zh` → Chinese (China Flag)
- `ja` → Japanese (Japan Flag)
- `ar` → Arabic (Saudi Flag)

### Assets de Bandeiras

**NOTA**: Os assets de bandeiras precisam ser adicionados ao `AppAssets`:
- `usaFlag`
- `spanishFlag`
- `frenchFlag`
- `germanyFlag`
- `brazilFlag`
- `chinaFlag`
- `japanFlag`
- `sauditFlag`

## Notas Importantes

- Este controller **NÃO** tem dependências de outros controllers
- A regra de exclusividade do curso primário é crítica
- Todos os testes devem verificar que apenas um curso é primário
- Assets de bandeiras precisam estar definidos em `AppAssets`

## Checklist de Atualização

- [ ] Atualizar imports nos testes unitários
- [ ] Atualizar imports nos testes de propriedade
- [ ] Atualizar imports nos testes de integração
- [ ] Executar testes unitários e verificar que passam
- [ ] Executar testes de propriedade e verificar que passam
- [ ] Executar testes de integração e verificar que passam
- [ ] Verificar exclusividade do curso primário
- [ ] Adicionar assets de bandeiras faltantes em `AppAssets`
- [ ] Verificar que helpers de idioma funcionam
