# Requirements Document

## Introduction

Este documento define os requisitos para correção de bugs críticos, remoção de código duplicado e implementação de traduções no aplicativo Pippo. A correção abrange 28 categorias de bugs identificados, incluindo 8 bugs críticos que podem crashar o app, 4 categorias de duplicação de código (20+ instâncias) e 16 categorias de textos hardcoded (60+ textos sem tradução).

## Glossary

- **System**: O aplicativo Pippo (app Flutter de aprendizado de idiomas)
- **Controller**: Classe GetX responsável pela lógica de negócio de uma feature
- **ErrorHandler**: Classe centralizada em `shared/utils/error_handler.dart` para tratamento de erros Firebase
- **Firestore**: Banco de dados Firebase usado pelo app
- **Auth**: Firebase Authentication
- **Translation Key**: Chave de tradução usada com `.tr` do GetX
- **Hardcoded Text**: Texto literal em português no código ao invés de usar translation key
- **Memory Leak**: Vazamento de memória causado por recursos não liberados
- **Race Condition**: Condição de corrida onde múltiplas operações concorrem pelo mesmo recurso
- **Transaction**: Operação atômica do Firestore que garante consistência de dados
- **Wrapper Method**: Método que apenas chama outro método sem adicionar lógica

## Requirements

### Requirement 1: Correção de Bugs Críticos de Autenticação

**User Story:** Como desenvolvedor, quero que o app não crashe por erros de autenticação, para que os usuários tenham uma experiência estável.

#### Acceptance Criteria

1. WHEN o Splash Controller verifica o usuário atual, THE System SHALL validar se o usuário existe antes de acessar suas propriedades
2. WHEN o Lesson Flow Controller inicia uma lição, THE System SHALL verificar autenticação uma única vez no início do método
3. WHEN ocorre um erro de autenticação, THE System SHALL exibir mensagem traduzida e navegar para tela apropriada
4. WHEN múltiplas verificações de autenticação são necessárias, THE System SHALL usar um método helper centralizado
5. IF o usuário não está autenticado, THEN THE System SHALL prevenir acesso a operações que requerem autenticação

### Requirement 2: Tratamento de Erros Firestore

**User Story:** Como desenvolvedor, quero que todas as operações Firestore tenham tratamento de erros, para que o app não crashe silenciosamente.

#### Acceptance Criteria

1. WHEN uma operação Firestore é executada, THE System SHALL envolver a operação em try-catch
2. WHEN ocorre um FirebaseException, THE System SHALL usar ErrorHandler.getFirestoreErrorMessage() para obter mensagem traduzida
3. WHEN ocorre um erro genérico, THE System SHALL exibir mensagem de erro genérica traduzida
4. WHEN um erro é capturado, THE System SHALL atualizar errorMessage.value com mensagem apropriada
5. THE System SHALL aplicar tratamento de erros em todos os controllers que fazem operações Firestore

### Requirement 3: Prevenção de Memory Leaks

**User Story:** Como desenvolvedor, quero que controllers limpem recursos ao serem destruídos, para que não haja vazamento de memória.

#### Acceptance Criteria

1. WHEN um controller é destruído, THE System SHALL implementar método onClose()
2. WHEN onClose() é chamado, THE System SHALL limpar todas as listas observáveis
3. WHEN onClose() é chamado, THE System SHALL resetar todos os estados para valores iniciais
4. WHEN onClose() é chamado, THE System SHALL cancelar timers e listeners ativos
5. THE System SHALL chamar super.onClose() ao final do método

### Requirement 4: Operações Atômicas em Gamificação

**User Story:** Como desenvolvedor, quero que atualizações simultâneas de stats não causem perda de dados, para que o progresso do usuário seja preservado.

#### Acceptance Criteria

1. WHEN múltiplos controllers atualizam o mesmo documento Firestore, THE System SHALL usar Firestore Transactions
2. WHEN uma transaction é executada, THE System SHALL atualizar todos os campos relacionados atomicamente
3. WHEN ocorre conflito de concorrência, THE System SHALL retentar a transaction automaticamente
4. THE System SHALL usar FieldValue.increment() para operações de incremento/decremento
5. WHEN uma transaction falha após retries, THE System SHALL exibir mensagem de erro apropriada

### Requirement 5: Remoção de Código Duplicado

**User Story:** Como desenvolvedor, quero remover código duplicado, para que o código seja mais fácil de manter.

#### Acceptance Criteria

1. WHEN um controller precisa tratar erro Firebase Auth, THE System SHALL usar ErrorHandler.getLoginErrorMessage() ou ErrorHandler.getRegisterErrorMessage()
2. WHEN um controller precisa tratar erro Firestore, THE System SHALL chamar ErrorHandler.getFirestoreErrorMessage() diretamente
3. THE System SHALL remover métodos _handleFirebaseLoginError e _handleFirebaseRegisterError de auth_credentials_controller
4. THE System SHALL remover métodos _handleFirestoreError de todos os 18 controllers que apenas fazem wrapper
5. THE System SHALL remover método _handleFirebaseAuthError de profile_auth_controller
6. THE System SHALL remover método _handleAuthError de leaderboard_controller

### Requirement 6: Implementação de Traduções em Search Users Page

**User Story:** Como usuário, quero que a página de busca de usuários esteja traduzida, para que eu possa usar o app no meu idioma.

#### Acceptance Criteria

1. WHEN a Search Users Page é exibida, THE System SHALL usar 'profile_search_title'.tr para o título
2. WHEN o campo de busca é exibido, THE System SHALL usar 'profile_search_hint'.tr para o hint
3. WHEN não há busca ativa, THE System SHALL usar 'profile_search_empty_state'.tr para o estado vazio
4. WHEN não há resultados, THE System SHALL usar 'profile_search_no_results'.tr para mensagem
5. THE System SHALL adicionar todas as keys de tradução ao arquivo de traduções

### Requirement 7: Implementação de Traduções em Learning Controls Page

**User Story:** Como usuário, quero que a página de controles de aprendizado esteja traduzida, para que eu possa entender as configurações.

#### Acceptance Criteria

1. WHEN minutos são exibidos, THE System SHALL usar 'learning_controls_minutes_format'.trParams() com parâmetro minutes
2. THE System SHALL formatar o texto como "{minutes} minutos"
3. THE System SHALL adicionar a key de tradução ao arquivo de traduções

### Requirement 8: Implementação de Traduções em Controllers

**User Story:** Como desenvolvedor, quero que todas as mensagens de erro em controllers usem traduções, para que o app seja internacionalizável.

#### Acceptance Criteria

1. WHEN um controller exibe mensagem de erro, THE System SHALL usar translation key com .tr
2. THE System SHALL substituir todas as mensagens hardcoded por keys de tradução
3. THE System SHALL adicionar keys para: erro de autenticação, erro de validação, erro de operação, erro de rede
4. THE System SHALL aplicar traduções em: TreasureChallengesController, ShopController, ProfileAuthController, ProfileSearchController, ProfileSettingsController, ProfileDataController, ProfileCoursesController
5. THE System SHALL manter consistência de nomenclatura nas keys de tradução

### Requirement 9: Implementação de Traduções de Dias da Semana

**User Story:** Como usuário, quero que os dias da semana estejam traduzidos, para que eu possa entender o calendário.

#### Acceptance Criteria

1. WHEN dias da semana são exibidos, THE System SHALL usar keys 'common_weekday_mon' até 'common_weekday_sun'
2. THE System SHALL criar método helper que mapeia número do dia para key de tradução
3. THE System SHALL aplicar tradução em ProfileSocialController
4. THE System SHALL adicionar todas as 7 keys de tradução ao arquivo de traduções

### Requirement 10: Implementação de Traduções de Tempo Restante

**User Story:** Como usuário, quero que o tempo restante de boosters esteja traduzido, para que eu possa entender quando expiram.

#### Acceptance Criteria

1. WHEN tempo restante é menor que 60 minutos, THE System SHALL usar 'common_time_minutes_remaining'.trParams()
2. WHEN tempo restante é 60 minutos ou mais, THE System SHALL usar 'common_time_hours_remaining'.trParams()
3. THE System SHALL aplicar tradução em XpLevelController e GemsController
4. THE System SHALL adicionar as keys de tradução ao arquivo de traduções

### Requirement 11: Implementação de Traduções de Botões de Lição

**User Story:** Como usuário, quero que os botões de lição estejam traduzidos, para que eu possa entender as ações disponíveis.

#### Acceptance Criteria

1. WHEN uma lição tem progresso, THE System SHALL usar 'home_lesson_button_continue'.tr
2. WHEN uma lição não tem progresso, THE System SHALL usar 'home_lesson_button_start'.tr
3. THE System SHALL aplicar tradução em HomeStatsController
4. THE System SHALL adicionar as keys de tradução ao arquivo de traduções

### Requirement 12: Otimização de Navegação entre Tabs

**User Story:** Como usuário, quero que a navegação entre tabs seja rápida, para que eu não veja loading desnecessário.

#### Acceptance Criteria

1. WHEN o usuário navega para uma tab, THE System SHALL verificar se os dados estão em cache
2. WHEN os dados estão em cache e não estão desatualizados, THE System SHALL usar dados do cache
3. WHEN os dados estão desatualizados, THE System SHALL recarregar em background
4. THE System SHALL remover reloads automáticos em HomeNavigationController
5. THE System SHALL implementar padrão stale-while-revalidate

### Requirement 13: Validação de Dados de Exercícios

**User Story:** Como desenvolvedor, quero que dados de exercícios sejam validados completamente, para que o app não crashe com dados inválidos.

#### Acceptance Criteria

1. WHEN dados de exercício são validados, THE System SHALL verificar se type não é null
2. WHEN dados de exercício são validados, THE System SHALL verificar se type está na lista de tipos válidos
3. WHEN dados de exercício são validados, THE System SHALL verificar se order é um número válido
4. WHEN dados de exercício são validados, THE System SHALL verificar estrutura completa conforme tipo
5. WHEN dados são inválidos, THE System SHALL retornar false e exibir mensagem de erro apropriada

### Requirement 14: Correção de Progress Display

**User Story:** Como usuário, quero ver o progresso real das seções, para que eu saiba quantas lições completei.

#### Acceptance Criteria

1. WHEN o progresso é exibido, THE System SHALL substituir placeholders {current} e {total} pelos valores reais
2. THE System SHALL verificar se os valores currentProgress e totalProgress estão sendo passados corretamente
3. THE System SHALL garantir que .trParams() está funcionando corretamente
4. WHEN os valores não estão disponíveis, THE System SHALL exibir "0/0" ao invés de "{current}/{total}"

### Requirement 15: Criação de Helper de Autenticação

**User Story:** Como desenvolvedor, quero um helper centralizado para verificação de autenticação, para que o código seja consistente.

#### Acceptance Criteria

1. THE System SHALL criar arquivo auth_helper.dart em shared/utils/
2. THE System SHALL implementar método getAuthenticatedUser() que retorna User? ou null
3. WHEN o usuário não está autenticado, THE System SHALL atualizar errorMessage com mensagem traduzida
4. THE System SHALL usar o helper em todos os controllers que verificam autenticação
5. THE System SHALL documentar o uso do helper

### Requirement 16: Documentação de Padrões

**User Story:** Como desenvolvedor, quero documentação clara dos padrões de error handling, para que eu possa seguir as melhores práticas.

#### Acceptance Criteria

1. THE System SHALL documentar uso correto do ErrorHandler centralizado
2. THE System SHALL documentar padrão de try-catch para operações Firestore
3. THE System SHALL documentar padrão de verificação de autenticação
4. THE System SHALL documentar padrão de uso de traduções
5. THE System SHALL documentar padrão de implementação de onClose()
6. THE System SHALL adicionar exemplos de código correto e incorreto

### Requirement 17: Testes de Validação

**User Story:** Como desenvolvedor, quero testes que validem o uso correto de traduções, para que novos bugs não sejam introduzidos.

#### Acceptance Criteria

1. THE System SHALL criar testes que verificam ausência de textos hardcoded em português
2. THE System SHALL criar testes que verificam uso correto de ErrorHandler
3. THE System SHALL criar testes que verificam implementação de onClose() em controllers
4. THE System SHALL criar testes que verificam try-catch em operações Firestore
5. THE System SHALL criar testes que verificam ausência de handlers duplicados
