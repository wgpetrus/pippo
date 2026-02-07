# Requirements Document - Correção de Testes de Integração

## Introduction

A Correção de Testes de Integração é um projeto crítico de qualidade de código que visa resolver problemas identificados na suite de testes após a refatoração de controllers. Atualmente, temos 3 testes com @Skip que não executam, 3 testes de documentação que não testam código real, e vários testes que precisam ser atualizados para usar os novos controllers refatorados.

**Contexto**: Após a refatoração bem-sucedida de 7 controllers em 31 controllers menores, a suite de testes precisa ser atualizada para refletir a nova arquitetura e garantir que todos os testes executem corretamente.

## Glossary

- **@Skip**: Anotação que desabilita a execução de um teste
- **Firebase Mocks**: Implementações falsas de Firebase Auth e Firestore para testes
- **FirebaseTestHelper**: Classe helper que facilita setup de Firebase em testes
- **Teste de Documentação**: Teste que apenas verifica existência de código, não comportamento
- **Teste de Integração**: Teste que verifica interação entre múltiplos componentes
- **GetX Controller**: Classe que gerencia estado e lógica de negócio
- **Controller Registration**: Processo de registrar controllers no GetX para uso em testes
- **fake_cloud_firestore**: Package que simula Firestore em testes
- **firebase_auth_mocks**: Package que simula Firebase Auth em testes

## Requirements

### Requirement 1: Eliminar Testes com @Skip

**User Story:** Como desenvolvedor, quero que todos os testes executem sem @Skip, para que a suite de testes seja confiável e completa.

#### Acceptance Criteria

1. WHEN a suite de testes é executada, ZERO testes SHOULD ter anotação @Skip
2. THE sistema SHALL corrigir `social/friends_placeholder_test.dart` registrando ProfileSocialController
3. THE sistema SHALL corrigir `shop/shop_error_handling_integration_test.dart` usando mocks de FirebaseException
4. THE sistema SHALL corrigir `profile/settings_logout_integration_test.dart` usando firebase_auth_mocks
5. WHEN um teste anteriormente com @Skip é executado, IT SHALL passar sem erros
6. THE sistema SHALL documentar o setup necessário para cada teste corrigido

### Requirement 2: Converter Testes de Documentação em Testes Reais

**User Story:** Como desenvolvedor, quero que testes de documentação sejam convertidos em testes funcionais, para que validem comportamento real do código.

#### Acceptance Criteria

1. THE sistema SHALL converter `shop/shop_purchase_flow_integration_test.dart` em teste funcional
2. THE sistema SHALL converter `shop/shop_boost_application_integration_test.dart` em teste funcional completo
3. THE sistema SHALL descomentar e habilitar todos os testes em `auth/auth_flow_integration_test.dart`
4. WHEN um teste convertido é executado, IT SHALL testar comportamento real, não apenas existência de código
5. THE sistema SHALL usar Firebase mocks para simular operações de backend
6. THE sistema SHALL verificar estados, side effects e resultados esperados

### Requirement 3: Atualizar Testes para Novos Controllers

**User Story:** Como desenvolvedor, quero que testes usem os novos controllers refatorados, para que reflitam a arquitetura atual do código.

#### Acceptance Criteria

1. THE sistema SHALL atualizar testes de gamification para usar StreakController, EnergyController, XpLevelController, GemsController
2. THE sistema SHALL atualizar testes de profile para usar ProfileDataController, ProfileSettingsController, ProfileSocialController, ProfileCoursesController, ProfileAuthController
3. THE sistema SHALL atualizar testes de lesson para usar LessonFlowController, LessonExerciseController, LessonProgressController, LessonRewardsController
4. THE sistema SHALL atualizar testes de onboarding para usar OnboardingFlowController, OnboardingDataController, OnboardingValidationController
5. THE sistema SHALL atualizar testes de treasure para usar TreasureChallengesController, TreasureRewardsController
6. THE sistema SHALL atualizar testes de home para usar HomeNavigationController, HomeStatsController
7. THE sistema SHALL atualizar testes de auth para usar AuthCredentialsController, AuthProvidersController
8. WHEN um teste atualizado é executado, IT SHALL passar sem erros
9. THE sistema SHALL manter a mesma cobertura de testes após atualização

### Requirement 4: Padronizar Setup de Testes

**User Story:** Como desenvolvedor, quero que todos os testes usem um setup padronizado, para que sejam consistentes e fáceis de manter.

#### Acceptance Criteria

1. THE sistema SHALL usar FirebaseTestHelper.setupFirebase() em todos os testes de integração
2. THE sistema SHALL criar helpers específicos para cada feature quando necessário
3. THE sistema SHALL documentar padrões de setup em comentários
4. WHEN um novo teste é criado, IT SHALL seguir o padrão estabelecido
5. THE sistema SHALL usar setUp() e tearDown() consistentemente
6. THE sistema SHALL registrar controllers GetX no setUp() quando necessário
7. THE sistema SHALL limpar estado com Get.reset() no tearDown()

### Requirement 5: Corrigir Registro de Controllers GetX

**User Story:** Como desenvolvedor, quero que controllers GetX sejam registrados corretamente em testes, para que testes de widgets funcionem.

#### Acceptance Criteria

1. WHEN um teste precisa de um controller, THE sistema SHALL registrar o controller no setUp()
2. THE sistema SHALL usar Get.put() ou Get.lazyPut() para registro
3. THE sistema SHALL registrar dependências na ordem correta (dependências primeiro)
4. WHEN um teste termina, THE sistema SHALL limpar controllers com Get.reset()
5. THE sistema SHALL documentar dependências entre controllers em comentários
6. THE sistema SHALL usar Get.testMode = true em testes

### Requirement 6: Implementar Testes de Fluxo de Compra

**User Story:** Como desenvolvedor, quero testes completos do fluxo de compra na shop, para garantir que compras funcionem corretamente.

#### Acceptance Criteria

1. THE sistema SHALL testar compra de boost com gems suficientes
2. THE sistema SHALL testar compra de boost com gems insuficientes
3. THE sistema SHALL testar aplicação de boost após compra
4. THE sistema SHALL testar atualização de gems no AppBar após compra
5. THE sistema SHALL testar exibição de snackbar de sucesso
6. THE sistema SHALL testar exibição de snackbar de erro
7. THE sistema SHALL usar Firebase mocks para simular transações

### Requirement 7: Implementar Testes de Error Handling

**User Story:** Como desenvolvedor, quero testes de tratamento de erros do Firebase, para garantir que erros sejam tratados corretamente.

#### Acceptance Criteria

1. THE sistema SHALL testar erro `permission-denied` do Firestore
2. THE sistema SHALL testar erro `unavailable` do Firestore
3. THE sistema SHALL testar erro `deadline-exceeded` do Firestore
4. THE sistema SHALL testar TimeoutException
5. THE sistema SHALL testar retry logic quando aplicável
6. THE sistema SHALL testar rollback de transações em caso de erro
7. THE sistema SHALL usar mocks para simular erros específicos

### Requirement 8: Implementar Testes de Autenticação

**User Story:** Como desenvolvedor, quero testes completos de autenticação, para garantir que login, registro e recuperação de senha funcionem.

#### Acceptance Criteria

1. THE sistema SHALL testar login com email/senha válidos
2. THE sistema SHALL testar login com credenciais inválidas
3. THE sistema SHALL testar registro de novo usuário
4. THE sistema SHALL testar registro com email já existente
5. THE sistema SHALL testar recuperação de senha
6. THE sistema SHALL testar login com Google (mock)
7. THE sistema SHALL testar logout
8. THE sistema SHALL usar firebase_auth_mocks para simular autenticação

### Requirement 9: Implementar Testes de Logout

**User Story:** Como desenvolvedor, quero testes de logout, para garantir que logout limpe dados corretamente.

#### Acceptance Criteria

1. THE sistema SHALL testar logout limpa tokens de autenticação
2. THE sistema SHALL testar logout limpa cache local
3. THE sistema SHALL testar logout navega para tela de auth
4. THE sistema SHALL testar logout limpa controllers GetX
5. THE sistema SHALL usar firebase_auth_mocks para simular logout

### Requirement 10: Implementar Testes de Social Features

**User Story:** Como desenvolvedor, quero testes de features sociais, para garantir que seguir/deixar de seguir usuários funcione.

#### Acceptance Criteria

1. THE sistema SHALL testar seguir usuário
2. THE sistema SHALL testar deixar de seguir usuário
3. THE sistema SHALL testar carregar lista de seguindo
4. THE sistema SHALL testar carregar lista de seguidores
5. THE sistema SHALL testar buscar usuários
6. THE sistema SHALL testar carregar progresso semanal de usuário
7. THE sistema SHALL registrar ProfileSocialController e ProfileDataController no setUp()

### Requirement 11: Garantir Cobertura de Testes

**User Story:** Como desenvolvedor, quero garantir cobertura completa de funcionalidades críticas, para que bugs sejam detectados cedo.

#### Acceptance Criteria

1. THE sistema SHALL ter testes para todos os fluxos críticos de autenticação
2. THE sistema SHALL ter testes para todos os fluxos de gamification
3. THE sistema SHALL ter testes para todos os fluxos de lições
4. THE sistema SHALL ter testes para todos os fluxos de compra
5. THE sistema SHALL ter testes para todos os fluxos de social features
6. WHEN a suite de testes é executada, TODOS os testes SHOULD passar
7. THE sistema SHALL ter ZERO testes com @Skip após correções

### Requirement 12: Documentar Padrões de Teste

**User Story:** Como desenvolvedor, quero documentação clara de padrões de teste, para que novos testes sejam escritos corretamente.

#### Acceptance Criteria

1. THE sistema SHALL documentar estrutura padrão de teste de integração
2. THE sistema SHALL documentar como usar FirebaseTestHelper
3. THE sistema SHALL documentar como registrar controllers GetX
4. THE sistema SHALL documentar como mockar Firebase Auth
5. THE sistema SHALL documentar como mockar Firestore
6. THE sistema SHALL documentar como testar fluxos assíncronos
7. THE sistema SHALL criar exemplos de testes bem escritos

### Requirement 13: Validar Testes Após Correções

**User Story:** Como desenvolvedor, quero validar que todos os testes passam após correções, para garantir que nada foi quebrado.

#### Acceptance Criteria

1. WHEN a suite de testes é executada, TODOS os testes de integração SHOULD passar
2. WHEN a suite de testes é executada, TODOS os testes unitários SHOULD passar
3. WHEN a suite de testes é executada, TODOS os testes de propriedade SHOULD passar
4. THE sistema SHALL executar `flutter test test/integration/` sem erros
5. THE sistema SHALL executar `flutter test test/unit/` sem erros
6. THE sistema SHALL executar `flutter test test/property/` sem erros
7. THE sistema SHALL ter ZERO testes com @Skip
8. THE sistema SHALL ter ZERO testes comentados (exceto TODOs documentados)

### Requirement 14: Atualizar TEST_ISSUES_MAP.md

**User Story:** Como desenvolvedor, quero que TEST_ISSUES_MAP.md seja atualizado, para refletir o estado atual dos testes.

#### Acceptance Criteria

1. WHEN correções são feitas, THE sistema SHALL atualizar TEST_ISSUES_MAP.md
2. THE sistema SHALL marcar testes corrigidos como ✅ FUNCIONAL
3. THE sistema SHALL remover testes da seção 🔴 CRÍTICO quando corrigidos
4. THE sistema SHALL remover testes da seção 🟡 ATENÇÃO quando convertidos
5. THE sistema SHALL adicionar notas sobre correções aplicadas
6. THE sistema SHALL manter histórico de problemas resolvidos

### Requirement 15: Criar Testes para Novos Controllers

**User Story:** Como desenvolvedor, quero testes específicos para cada novo controller, para garantir que funcionem isoladamente.

#### Acceptance Criteria

1. THE sistema SHALL criar testes unitários para StreakController
2. THE sistema SHALL criar testes unitários para EnergyController
3. THE sistema SHALL criar testes unitários para XpLevelController
4. THE sistema SHALL criar testes unitários para GemsController
5. THE sistema SHALL criar testes de integração para interação entre controllers de gamification
6. THE sistema SHALL criar testes para ProfileSocialController
7. THE sistema SHALL criar testes para ProfileDataController
8. THE sistema SHALL criar testes para ProfileSettingsController
9. THE sistema SHALL criar testes para ProfileCoursesController
10. THE sistema SHALL criar testes para ProfileAuthController
