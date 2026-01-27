# Requirements Document

## Introduction

O sistema de desafios (Treasure Challenges) é uma funcionalidade de gamificação que oferece missões diárias, semanais e especiais aos usuários do Pippo. Os desafios incentivam o engajamento contínuo através de recompensas (gems, XP, itens) ao completar objetivos específicos como completar lições, ganhar XP ou manter sequências de estudo.

## Glossary

- **Challenge**: Uma missão com objetivo numérico, progresso rastreável e recompensa
- **Daily_Challenge**: Desafio que expira à meia-noite do mesmo dia
- **Weekly_Challenge**: Desafio que expira no domingo às 23:59
- **Special_Challenge**: Desafio temporário com data de expiração customizada
- **Progress**: Valor atual do progresso do usuário em relação ao objetivo (ex: 1/3 lições)
- **Goal**: Valor numérico que o usuário deve atingir para completar o desafio
- **Reward**: Recompensa concedida ao completar um desafio (gems, XP ou item)
- **Claimed**: Estado indicando que a recompensa foi coletada pelo usuário
- **Expired**: Estado indicando que o desafio passou da data de expiração
- **System**: O sistema de gerenciamento de desafios do Pippo
- **User**: Usuário autenticado do aplicativo
- **Firestore**: Banco de dados Firebase usado para persistência

## Requirements

### Requirement 1: Gerenciar Tipos de Desafios

**User Story:** Como usuário, quero ter acesso a diferentes tipos de desafios (diários, semanais, especiais), para que eu tenha variedade de objetivos e prazos.

#### Acceptance Criteria

1. THE System SHALL support three challenge types: Daily, Weekly, and Special
2. WHEN a Daily_Challenge is created, THE System SHALL set expiration to midnight of the current day
3. WHEN a Weekly_Challenge is created, THE System SHALL set expiration to Sunday 23:59 of the current week
4. WHEN a Special_Challenge is created, THE System SHALL accept a custom expiration date
5. THE System SHALL store challenge type in Firestore for each challenge

### Requirement 2: Estrutura de Desafios

**User Story:** Como desenvolvedor, quero que cada desafio tenha uma estrutura completa de dados, para que todas as informações necessárias estejam disponíveis.

#### Acceptance Criteria

1. THE System SHALL store title, description, goal, progress, reward type, reward amount, expiration date, and icon for each challenge
2. WHEN creating a challenge, THE System SHALL validate that goal is a positive integer
3. WHEN creating a challenge, THE System SHALL validate that reward amount is a positive number
4. WHEN creating a challenge, THE System SHALL validate that reward type is one of: gems, xp, or item
5. THE System SHALL initialize progress to zero when creating a new challenge

### Requirement 3: Rastreamento de Progresso

**User Story:** Como usuário, quero que meu progresso nos desafios seja atualizado automaticamente, para que eu veja meu avanço em tempo real.

#### Acceptance Criteria

1. WHEN a User completes a lesson, THE System SHALL update progress for challenges tracking lesson completion
2. WHEN a User gains XP, THE System SHALL update progress for challenges tracking XP gain
3. WHEN a User completes an exercise correctly, THE System SHALL update progress for challenges tracking correct exercises
4. WHEN a User updates their streak, THE System SHALL update progress for challenges tracking streak maintenance
5. WHEN progress reaches or exceeds goal, THE System SHALL mark the challenge as completed
6. THE System SHALL persist progress updates to Firestore immediately

### Requirement 4: Detecção de Conclusão

**User Story:** Como usuário, quero ser notificado quando completar um desafio, para que eu saiba que posso coletar a recompensa.

#### Acceptance Criteria

1. WHEN progress equals goal, THE System SHALL mark challenge as completed
2. WHEN progress exceeds goal, THE System SHALL mark challenge as completed
3. WHEN a challenge is marked as completed, THE System SHALL enable the claim reward button
4. WHEN a challenge is marked as completed, THE System SHALL display a visual indicator (glow animation)
5. THE System SHALL not mark a challenge as completed if it is already claimed or expired

### Requirement 5: Coleta de Recompensas

**User Story:** Como usuário, quero coletar recompensas dos desafios completados, para que eu receba gems, XP ou itens.

#### Acceptance Criteria

1. WHEN a User claims a reward, THE System SHALL verify the challenge is completed
2. WHEN a User claims a reward, THE System SHALL verify the challenge is not already claimed
3. WHEN a User claims a reward, THE System SHALL verify the challenge is not expired
4. WHEN claiming a gems reward, THE System SHALL add the reward amount to user gems in Firestore
5. WHEN claiming an XP reward, THE System SHALL add the reward amount to user XP in Firestore
6. WHEN a reward is claimed, THE System SHALL mark the challenge as claimed with timestamp
7. WHEN a reward is claimed, THE System SHALL show a reward animation to the user
8. WHEN a reward is claimed, THE System SHALL remove the challenge from the active list

### Requirement 6: Lógica de Expiração

**User Story:** Como usuário, quero que desafios expirados sejam removidos automaticamente, para que eu veja apenas desafios válidos.

#### Acceptance Criteria

1. WHEN loading challenges, THE System SHALL check expiration date against current time
2. WHEN a challenge is expired, THE System SHALL remove it from the active list
3. WHEN a challenge is expired and not claimed, THE System SHALL not allow reward collection
4. WHEN checking Daily_Challenge expiration, THE System SHALL compare against midnight of current day
5. WHEN checking Weekly_Challenge expiration, THE System SHALL compare against Sunday 23:59 of current week
6. WHEN checking Special_Challenge expiration, THE System SHALL compare against the custom expiration date
7. THE System SHALL perform expiration checks on app launch and when entering treasure page

### Requirement 7: Estados de Desafios

**User Story:** Como usuário, quero ver claramente o estado de cada desafio (em progresso, completado, coletado), para que eu saiba quais ações posso realizar.

#### Acceptance Criteria

1. WHEN a challenge has progress less than goal, THE System SHALL display it as "In Progress" with partial progress bar
2. WHEN a challenge has progress equal to or greater than goal and not claimed, THE System SHALL display it as "Completed" with full progress bar
3. WHEN a challenge is completed and not claimed, THE System SHALL enable the "Claim Reward" button
4. WHEN a challenge is completed and not claimed, THE System SHALL display a glow animation
5. WHEN a challenge is claimed, THE System SHALL remove it from the display list
6. WHEN a challenge is in progress, THE System SHALL disable the claim button

### Requirement 8: Integração com Sistemas Existentes

**User Story:** Como desenvolvedor, quero que o sistema de desafios se integre com lições e gamificação, para que o progresso seja rastreado corretamente.

#### Acceptance Criteria

1. WHEN the Lesson system reports lesson completion, THE System SHALL receive the event and update relevant challenges
2. WHEN the Gamification system reports XP gain, THE System SHALL receive the event and update relevant challenges
3. WHEN the Lesson system reports exercise completion, THE System SHALL receive the event and update relevant challenges
4. WHEN the Gamification system reports streak update, THE System SHALL receive the event and update relevant challenges
5. THE System SHALL update user gems in Firestore when gems rewards are claimed
6. THE System SHALL update user XP in Firestore when XP rewards are claimed

### Requirement 9: Persistência de Dados

**User Story:** Como usuário, quero que meu progresso nos desafios seja salvo, para que eu não perca meu avanço ao fechar o app.

#### Acceptance Criteria

1. THE System SHALL persist all challenge data to Firestore
2. WHEN progress is updated, THE System SHALL save the new progress value to Firestore immediately
3. WHEN a challenge is claimed, THE System SHALL save the claimed status and timestamp to Firestore
4. WHEN loading challenges, THE System SHALL retrieve all active challenges from Firestore for the authenticated user
5. THE System SHALL handle Firestore errors gracefully using standardized error handlers

### Requirement 10: Validação de Dados

**User Story:** Como desenvolvedor, quero que todos os dados de desafios sejam validados, para que o sistema mantenha integridade de dados.

#### Acceptance Criteria

1. WHEN creating a challenge, THE System SHALL validate that all required fields are present
2. WHEN updating progress, THE System SHALL validate that the new progress value is non-negative
3. WHEN claiming a reward, THE System SHALL validate that the user is authenticated
4. WHEN claiming a reward, THE System SHALL validate that the challenge belongs to the authenticated user
5. THE System SHALL reject invalid data with descriptive error messages in Portuguese

### Requirement 11: Interface de Usuário Funcional

**User Story:** Como usuário, quero uma interface completa e funcional para visualizar e interagir com desafios, para que eu possa acompanhar meu progresso e coletar recompensas.

#### Acceptance Criteria

1. THE System SHALL display the treasure page as Tab 3 in the home navigation
2. WHEN a User navigates to the treasure page, THE System SHALL display a header with the treasure mascot
3. WHEN a User navigates to the treasure page, THE System SHALL display all active challenges in a scrollable list
4. WHEN displaying a challenge, THE System SHALL show title, description, progress bar, goal text, reward icon, and reward amount
5. WHEN a challenge is in progress, THE System SHALL display a disabled "Claim Reward" button with gray color
6. WHEN a challenge is completed, THE System SHALL display an enabled "Claim Reward" button with primary color and glow animation
7. WHEN a User taps a completed challenge button, THE System SHALL show a reward animation modal
8. WHEN a reward animation completes, THE System SHALL update the UI to remove the claimed challenge
9. THE System SHALL use ResponsiveUtils for all dimensions and spacing
10. THE System SHALL follow AppTheme for all colors, fonts, and styles
11. THE System SHALL use AppButton for the claim reward button
12. THE System SHALL display loading state while fetching challenges from Firestore
13. WHEN no challenges are available, THE System SHALL display an empty state with mascot and message

### Requirement 12: Navegação e Fluxo do App

**User Story:** Como usuário, quero que a página de desafios esteja integrada ao fluxo principal do app, para que eu possa acessá-la facilmente.

#### Acceptance Criteria

1. THE System SHALL be accessible via Tab 3 (Treasure) in the home bottom navigation bar
2. WHEN a User taps the Treasure tab, THE System SHALL navigate to the treasure page without clearing navigation stack
3. WHEN a User is on the treasure page, THE System SHALL highlight the Treasure tab in the bottom navigation
4. WHEN a User completes a challenge in another tab, THE System SHALL update the treasure page data in real-time
5. WHEN a User returns to the treasure page, THE System SHALL refresh challenge data from Firestore
6. THE System SHALL maintain scroll position when navigating away and back to the treasure page

### Requirement 13: Animações e Feedback Visual

**User Story:** Como usuário, quero feedback visual claro ao interagir com desafios, para que eu entenda o resultado das minhas ações.

#### Acceptance Criteria

1. WHEN a challenge is completed, THE System SHALL display a subtle glow animation on the challenge card
2. WHEN a User claims a reward, THE System SHALL display a full-screen reward animation modal
3. WHEN displaying reward animation, THE System SHALL show the reward type icon, amount, and celebratory effects
4. WHEN reward animation completes, THE System SHALL automatically close the modal after 2 seconds
5. WHEN progress updates, THE System SHALL animate the progress bar smoothly
6. WHEN loading challenges, THE System SHALL display a loading spinner centered on the page
7. WHEN an error occurs, THE System SHALL display an error message using standardized Firebase error handlers

### Requirement 14: Responsividade e Acessibilidade

**User Story:** Como usuário, quero que a interface de desafios funcione bem em diferentes tamanhos de tela, para que eu tenha uma boa experiência em qualquer dispositivo.

#### Acceptance Criteria

1. THE System SHALL use ResponsiveUtils for all widget dimensions
2. THE System SHALL use ResponsiveUtils spacing constants (spacing8, spacing16, etc.)
3. THE System SHALL use ResponsiveUtils font sizes (fontSize14, fontSize16, etc.)
4. THE System SHALL wrap content in SafeArea to avoid notch and system UI
5. THE System SHALL use SingleChildScrollView to prevent overflow on small screens
6. THE System SHALL maintain proper aspect ratios for challenge card images
7. THE System SHALL ensure touch targets are at least 48x48 logical pixels
8. THE System SHALL test on mobile (375x667), tablet (820x1180), and desktop (1920x1080) breakpoints
