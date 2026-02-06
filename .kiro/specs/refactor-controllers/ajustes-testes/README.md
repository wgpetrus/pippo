# Ajustes de Testes - Controllers Refatorados

## Visão Geral

Esta pasta contém documentação sobre os ajustes necessários nos testes após a refatoração dos controllers. Cada controller refatorado tem um arquivo `.md` explicando:

- Estados e métodos migrados
- Testes que precisam ser atualizados
- Mudanças necessárias nos imports
- Dependências entre controllers
- Validações necessárias
- Checklist de atualização

## Controllers Refatorados

### ProfileController → 5 Controllers

| Controller | Arquivo | Status |
|------------|---------|--------|
| ProfileDataController | [profile-data-controller.md](./profile-data-controller.md) | ✅ Documentado |
| ProfileSettingsController | [profile-settings-controller.md](./profile-settings-controller.md) | ✅ Documentado |
| ProfileSocialController | [profile-social-controller.md](./profile-social-controller.md) | ✅ Documentado |
| ProfileCoursesController | [profile-courses-controller.md](./profile-courses-controller.md) | ✅ Documentado |
| ProfileAuthController | [profile-auth-controller.md](./profile-auth-controller.md) | ✅ Documentado |

### Outros Controllers (A Documentar)

| Controller Original | Novos Controllers | Status |
|---------------------|-------------------|--------|
| LessonController | 4 controllers | ⏳ Pendente |
| GamificationController | 4 controllers | ⏳ Pendente |
| OnboardingController | 3 controllers | ⏳ Pendente |
| TreasureController | 2 controllers | ⏳ Pendente |
| HomeController | 2 controllers | ⏳ Pendente |
| AuthController | 2 controllers | ⏳ Pendente |

## Estrutura dos Documentos

Cada documento de ajuste contém:

1. **Controller Refatorado**
   - Arquivo do novo controller
   - Responsabilidade do controller

2. **Estados Migrados**
   - Lista de todos os estados observáveis migrados

3. **Métodos Migrados**
   - Lista de todos os métodos públicos e privados migrados

4. **Testes que Precisam Ser Atualizados**
   - Testes unitários afetados
   - Testes de propriedade afetados
   - Testes de integração afetados
   - Exemplos de código antes/depois

5. **Dependências**
   - Controllers dos quais este depende
   - Como inicializar dependências

6. **Validações Necessárias**
   - Checklist de funcionalidades a validar

7. **Notas Importantes**
   - Informações específicas do controller
   - Regras de negócio críticas

8. **Checklist de Atualização**
   - Passos para atualizar os testes

## Como Usar Esta Documentação

### Para Atualizar Testes de um Controller

1. Abra o arquivo `.md` do controller refatorado
2. Leia a seção "Testes que Precisam Ser Atualizados"
3. Identifique os arquivos de teste afetados
4. Aplique as mudanças de import conforme exemplos
5. Execute os testes e verifique que passam
6. Marque os itens do checklist conforme completa

### Para Entender Dependências

1. Verifique a seção "Dependências" do controller
2. Se houver dependências, atualize os testes para mockar os controllers dependentes
3. Inicialize as dependências no `setUp()` dos testes

### Para Validar Funcionalidade

1. Use a seção "Validações Necessárias" como checklist
2. Execute cada tipo de teste (unitário, propriedade, integração)
3. Verifique que todas as validações passam

## Padrão de Atualização de Imports

### Antes (Controller Monolítico)
```dart
import 'package:pippo/features/inners/profile/controllers/profile_controller.dart';

void main() {
  late ProfileController controller;
  
  setUp(() {
    controller = ProfileController();
  });
}
```

### Depois (Controllers Refatorados)
```dart
import 'package:pippo/features/inners/profile/controllers/profile_data_controller.dart';
import 'package:pippo/features/inners/profile/controllers/profile_social_controller.dart';

void main() {
  late ProfileDataController dataController;
  late ProfileSocialController socialController;
  
  setUp(() {
    dataController = ProfileDataController();
    socialController = ProfileSocialController();
  });
}
```

## Tipos de Testes

### Testes Unitários
- Testam métodos individuais
- Usam mocks do Firebase
- Verificam lógica de negócio

### Testes de Propriedade
- Testam propriedades universais
- Usam geração de dados aleatórios
- Verificam invariantes do sistema

### Testes de Integração
- Testam fluxos completos
- Verificam interação entre controllers
- Testam navegação e UI

## Status Geral

### ProfileController
- ✅ Refatoração completa
- ✅ Documentação de ajustes criada
- ⏳ Testes pendentes de atualização

### Outros Controllers
- ⏳ Refatoração pendente
- ⏳ Documentação pendente
- ⏳ Testes pendentes

## Próximos Passos

1. Completar refatoração dos outros 6 controllers
2. Criar documentação de ajustes para cada um
3. Atualizar todos os testes
4. Executar suite completa de testes
5. Verificar cobertura de código mantida

## Notas Importantes

- **NÃO** modifique a lógica de negócio durante atualização de testes
- **SEMPRE** execute os testes após cada atualização
- **VERIFIQUE** que a cobertura de código não diminuiu
- **DOCUMENTE** qualquer problema encontrado
- **MANTENHA** os testes de propriedade - eles validam invariantes críticos

## Contato

Para dúvidas sobre os ajustes de testes, consulte:
- Design document: `.kiro/specs/refactor-controllers/design.md`
- Requirements: `.kiro/specs/refactor-controllers/requirements.md`
- Tasks: `.kiro/specs/refactor-controllers/tasks.md`
