# Requirements Document

## Introduction

Este documento define os requisitos ESSENCIAIS para correção de bugs críticos, remoção de código duplicado e implementação de traduções no aplicativo Pippo. Foco em correções simples e diretas, sem adicionar complexidade desnecessária.

## Glossary

- **System**: O aplicativo Pippo (app Flutter de aprendizado de idiomas)
- **Controller**: Classe GetX responsável pela lógica de negócio de uma feature
- **ErrorHandler**: Classe centralizada em `shared/utils/error_handler.dart` para tratamento de erros Firebase
- **Firestore**: Banco de dados Firebase usado pelo app
- **Auth**: Firebase Authentication
- **Translation Key**: Chave de tradução usada com `.tr` do GetX
- **Hardcoded Text**: Texto literal em português no código ao invés de usar translation key

## Requirements

### Requirement 1: Correção de Bug Crítico - Usuário Não Autenticado ao Iniciar Lição

**User Story:** Como usuário, quero iniciar lições sem receber erro de "usuário não autenticado" quando estou logado.

#### Acceptance Criteria

1. WHEN o Lesson Flow Controller inicia uma lição, THE System SHALL verificar autenticação UMA ÚNICA VEZ no início do método
2. WHEN o usuário não está autenticado, THE System SHALL exibir mensagem traduzida e prevenir a operação
3. THE System SHALL remover delays artificiais de 100ms
4. THE System SHALL remover verificações repetidas de autenticação

### Requirement 2: Correção de Bug Crítico - Null Pointer em Splash

**User Story:** Como desenvolvedor, quero que o app não crashe no splash quando o usuário não está autenticado.

#### Acceptance Criteria

1. WHEN o Splash Controller verifica o usuário atual, THE System SHALL validar se o usuário existe ANTES de acessar suas propriedades
2. WHEN o usuário é null, THE System SHALL exibir mensagem traduzida e navegar para /auth
3. THE System SHALL nunca usar operador `!` sem verificação prévia

### Requirement 3: Tratamento de Erros Firestore

**User Story:** Como desenvolvedor, quero que operações Firestore não crashem o app silenciosamente.

#### Acceptance Criteria

1. WHEN uma operação Firestore é executada, THE System SHALL envolver a operação em try-catch
2. WHEN ocorre um FirebaseException, THE System SHALL usar ErrorHandler.getFirestoreErrorMessage()
3. WHEN ocorre um erro genérico, THE System SHALL exibir 'error_generic'.tr
4. THE System SHALL aplicar tratamento de erros em todos os controllers que fazem operações Firestore

### Requirement 4: Remoção de Handlers Duplicados

**User Story:** Como desenvolvedor, quero remover código duplicado para facilitar manutenção.

#### Acceptance Criteria

1. THE System SHALL remover métodos _handleFirebaseLoginError e _handleFirebaseRegisterError de auth_credentials_controller
2. THE System SHALL usar ErrorHandler.getLoginErrorMessage() e ErrorHandler.getRegisterErrorMessage() diretamente
3. THE System SHALL remover métodos _handleFirestoreError de todos os 18 controllers
4. THE System SHALL chamar ErrorHandler.getFirestoreErrorMessage() diretamente

### Requirement 5: Implementação de onClose() em Controllers

**User Story:** Como desenvolvedor, quero que controllers limpem recursos para evitar memory leaks.

#### Acceptance Criteria

1. WHEN um controller é destruído, THE System SHALL implementar método onClose()
2. WHEN onClose() é chamado, THE System SHALL limpar todas as listas observáveis
3. WHEN onClose() é chamado, THE System SHALL resetar estados (isLoading, errorMessage)
4. THE System SHALL chamar super.onClose() ao final

### Requirement 6: Substituição de Textos Hardcoded por Traduções

**User Story:** Como usuário, quero que o app esteja traduzido no meu idioma.

#### Acceptance Criteria

1. WHEN um controller exibe mensagem, THE System SHALL usar translation key com .tr
2. THE System SHALL substituir TODOS os textos hardcoded em português por keys de tradução
3. THE System SHALL adicionar keys aos arquivos pt_BR.dart, en_US.dart e es_ES.dart
4. THE System SHALL aplicar em: Search Users Page, Learning Controls Page, todos os controllers com mensagens hardcoded
