# Profile Controllers Tests

## Nova Estrutura (Após Refactoring)

O `ProfileController` foi dividido em 6 controllers menores seguindo o Single Responsibility Principle (SRP):

### Controllers e Seus Testes

| Controller | Arquivo de Teste | Responsabilidade |
|------------|------------------|------------------|
| `ProfileDataController` | `profile_data_controller_test.dart` | Gerenciar dados do perfil (nome, avatar, bio, stats) |
| `ProfileSettingsController` | `profile_settings_controller_test.dart` | Gerenciar configurações (notificações, controles de aprendizado) |
| `ProfileSocialController` | `profile_social_controller_test.dart` | Gerenciar recursos sociais (seguir, seguidores, busca) |
| `ProfileCoursesController` | `profile_courses_controller_test.dart` | Gerenciar cursos do usuário (adicionar, remover, definir primário) |
| `ProfileAuthController` | `profile_auth_controller_test.dart` | Gerenciar ações de autenticação (senha, telefone, deletar conta) |
| `ProfileSearchController` | (não tem testes ainda) | Gerenciar busca de usuários |

### Arquivos Obsoletos

Os seguintes arquivos foram marcados como obsoletos e devem ser ignorados:

- `_OBSOLETE_profile_controller_test.dart` - Testes do controller antigo (monolítico)
- `_OBSOLETE_profile_controller_search_test.dart` - Testes de busca do controller antigo

**Nota:** Estes arquivos foram mantidos apenas como referência histórica. Todos os testes foram migrados para os novos arquivos específicos de cada controller.

## Status dos Testes

### ✅ Testes de Validadores (Completos)

Todos os validadores foram migrados e estão funcionando:

- **ProfileDataController**: `validateName()`, `validateUsername()`, `validateBio()`
- **ProfileAuthController**: `validateCurrentPassword()`, `validateNewPassword()`, `validateConfirmPassword()`, `validatePhoneNumber()`

### ⏳ Testes de Integração (Estrutura Criada)

Os testes de integração foram estruturados mas requerem implementação de Dependency Injection (DI) para funcionar completamente:

- Testes de carregamento de perfil
- Testes de atualização de perfil
- Testes de configurações
- Testes de recursos sociais
- Testes de gerenciamento de cursos
- Testes de alterações de autenticação
- Testes de exclusão de conta

**Próximo Passo:** Implementar DI nos controllers para permitir injeção de mocks do Firebase nos testes.

## Como Executar os Testes

```bash
# Executar todos os testes do Profile
flutter test test/unit/features/inners/profile/controllers/

# Executar teste específico
flutter test test/unit/features/inners/profile/controllers/profile_data_controller_test.dart

# Executar apenas testes de validadores
flutter test test/unit/features/inners/profile/controllers/ --name "Validator"
```

## Referência

Para mais detalhes sobre a refatoração, consulte:
- `.kiro/specs/refactor-controllers/design.md`
- `.kiro/specs/refactor-controllers/tasks.md`
