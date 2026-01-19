# Requirements Document - Google Social Login

## Introduction

Este documento define os requisitos para implementação do login social com Google no aplicativo Pippo. O sistema permite que usuários façam login usando suas contas Google através do Firebase Authentication, simplificando o processo de autenticação e melhorando a experiência do usuário.

O login com Facebook será implementado futuramente e terá apenas um placeholder visual nesta fase.

## Glossary

- **System**: O módulo de autenticação social do aplicativo Pippo
- **User**: Pessoa usando o aplicativo
- **Firebase_Auth**: Serviço de autenticação do Firebase
- **Google_Sign_In**: Plugin Flutter para autenticação com Google
- **Firestore**: Banco de dados NoSQL do Firebase
- **Social_Button**: Widget de botão para login social
- **Onboarding**: Processo de configuração inicial do perfil do usuário

## Requirements

### Requirement 1: Login com Google

**User Story:** Como usuário, quero fazer login usando minha conta Google, para que eu possa acessar o app de forma rápida sem precisar criar uma nova conta.

#### Acceptance Criteria

1. WHEN the user taps the Google login button, THE System SHALL initiate the Google Sign-In flow
2. WHEN the Google Sign-In flow starts, THE System SHALL display the Google account picker
3. WHEN the user selects a Google account, THE System SHALL authenticate with Firebase using the Google credentials
4. IF the user cancels the Google Sign-In, THEN THE System SHALL return to the login screen without error message
5. WHEN authentication is successful and user document does not exist, THE System SHALL create a new user document in Firestore
6. WHEN creating a new user document, THE System SHALL set onboardingCompleted to false
7. WHEN creating a new user document, THE System SHALL store email, displayName, and photoURL from Google
8. WHEN authentication is successful and user document exists, THE System SHALL fetch the existing user document
9. WHEN onboardingCompleted is false, THE System SHALL navigate to /onboarding
10. WHEN onboardingCompleted is true, THE System SHALL update lastActiveAt with FieldValue.serverTimestamp()
11. WHEN lastActiveAt is updated, THE System SHALL navigate to /home using Get.offAllNamed
12. WHEN Google Sign-In is in progress, THE System SHALL display loading indicator and disable all login buttons

### Requirement 2: Tratamento de Erros do Google Sign-In

**User Story:** Como usuário, quero receber mensagens claras quando algo der errado no login com Google, para que eu saiba como resolver o problema.

#### Acceptance Criteria

1. IF Google Sign-In fails with network error, THEN THE System SHALL display "Verifique sua conexão com a internet."
2. IF Google Sign-In fails with sign_in_canceled, THEN THE System SHALL silently return to login screen
3. IF Google Sign-In fails with sign_in_failed, THEN THE System SHALL display "Não foi possível fazer login com Google. Tente novamente."
4. IF Firebase authentication fails with account-exists-with-different-credential, THEN THE System SHALL display "Este e-mail já está vinculado a outra conta. Tente fazer login de outra forma."
5. IF Firebase authentication fails with invalid-credential, THEN THE System SHALL display "Credenciais inválidas. Tente novamente."
6. IF Firebase authentication fails with operation-not-allowed, THEN THE System SHALL display "Login com Google não está habilitado. Entre em contato com o suporte."
7. IF Firebase authentication fails with user-disabled, THEN THE System SHALL display "Esta conta foi desativada. Entre em contato com o suporte."
8. IF an unknown error occurs, THEN THE System SHALL display "Ocorreu um erro inesperado. Tente novamente."
9. THE System SHALL log technical errors only to console, never to user

### Requirement 3: Placeholder do Facebook

**User Story:** Como usuário, quero ver a opção de login com Facebook, para que eu saiba que essa funcionalidade estará disponível no futuro.

#### Acceptance Criteria

1. THE System SHALL display a Facebook login button below the Google login button
2. WHEN the user taps the Facebook login button, THE System SHALL display message "Login com Facebook estará disponível em breve!"
3. THE System SHALL display the message using a SnackBar
4. THE System SHALL NOT initiate any authentication flow for Facebook
5. THE System SHALL style the Facebook button consistently with the Google button

### Requirement 4: Estados de Loading

**User Story:** Como usuário, quero ver indicadores visuais quando o app está processando meu login social, para que eu saiba que o sistema está respondendo.

#### Acceptance Criteria

1. WHEN Google Sign-In starts, THE System SHALL display loading indicator on the Google button
2. WHEN in loading state, THE System SHALL disable all login buttons (email, Google, Facebook)
3. WHEN in loading state, THE System SHALL disable the "Esqueci minha senha" link
4. WHEN the operation completes, THE System SHALL remove the loading indicator
5. WHEN the operation fails, THE System SHALL remove loading and display error message
6. THE System SHALL prevent multiple simultaneous login attempts

### Requirement 5: Integração com Fluxo Existente

**User Story:** Como usuário, quero que o login com Google funcione de forma consistente com o login por email, para ter uma experiência uniforme.

#### Acceptance Criteria

1. WHEN Google login is successful, THE System SHALL follow the same navigation logic as email login
2. WHEN Google login creates a new user, THE System SHALL navigate to /onboarding
3. WHEN Google login finds existing user with onboardingCompleted true, THE System SHALL navigate to /home
4. THE System SHALL use Get.offAllNamed for all post-login navigation
5. THE System SHALL clear the navigation stack after successful login
6. THE System SHALL use the same error message patterns as email login

### Requirement 6: Segurança de Dados

**User Story:** Como usuário, quero que meus dados do Google sejam tratados de forma segura, para proteger minha privacidade.

#### Acceptance Criteria

1. THE System SHALL never log Google access tokens to console
2. THE System SHALL never log Google ID tokens to console
3. THE System SHALL use HTTPS for all communications
4. THE System SHALL only request necessary Google scopes (email, profile)
5. THE System SHALL clear Google credentials from memory after authentication
6. THE System SHALL validate Google credentials before creating Firestore document

