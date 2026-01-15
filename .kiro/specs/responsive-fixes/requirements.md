# Requirements Document

## Introduction

Correção de problemas de responsividade em todo o app Pippo para garantir uma experiência consistente em diferentes tamanhos de tela e dispositivos móveis.

## Glossary

- **App**: Aplicativo Pippo de aprendizado de idiomas
- **Responsive_Utils**: Utilitário centralizado para cálculos de responsividade
- **Widget**: Componente visual reutilizável do Flutter
- **Modal**: Diálogo ou bottom sheet que aparece sobre o conteúdo
- **Overflow**: Quando o conteúdo excede o espaço disponível

## Requirements

### Requirement 1: Utilitário de Responsividade

**User Story:** As a developer, I want a centralized responsive utility, so that I can easily calculate responsive sizes across the app.

#### Acceptance Criteria

1. THE Responsive_Utils SHALL provide methods for calculating responsive width, height, and font sizes based on screen dimensions
2. THE Responsive_Utils SHALL use a base design width of 375 (iPhone SE) for calculations
3. THE Responsive_Utils SHALL provide a method to clamp values between min and max bounds
4. WHEN the app initializes, THE Responsive_Utils SHALL be available globally without requiring context in every call

---

### Requirement 2: Widgets Globais Responsivos

**User Story:** As a user, I want buttons and inputs to look proportional on my device, so that the app feels native to my screen size.

#### Acceptance Criteria

1. WHEN AppButton is rendered, THE App SHALL use responsive height instead of fixed 62px
2. WHEN AppPinput is rendered, THE App SHALL use responsive width/height instead of fixed 65px
3. WHEN AppLessonButton is rendered, THE App SHALL maintain proportional sizing based on screen width
4. THE App SHALL ensure minimum touch targets of 44px for accessibility compliance

---

### Requirement 3: Tratamento de Overflow em Textos

**User Story:** As a user, I want text to be readable without being cut off, so that I can understand all content.

#### Acceptance Criteria

1. WHEN a username or name is displayed, THE App SHALL apply maxLines and overflow ellipsis
2. WHEN a title exceeds available space, THE App SHALL truncate with ellipsis instead of overflowing
3. WHEN stats chips are displayed in HomeAppbar, THE App SHALL use Flexible widgets to prevent overlap
4. WHEN boost item titles are displayed, THE App SHALL handle long text gracefully

---

### Requirement 4: Modais Responsivos

**User Story:** As a user, I want modals to fit my screen properly, so that I can interact with all content.

#### Acceptance Criteria

1. WHEN a modal is displayed, THE App SHALL calculate max height based on screen height
2. WHEN CoursesModal is displayed, THE App SHALL use responsive padding
3. WHEN GemsModal is displayed, THE App SHALL scroll if content exceeds available height
4. WHEN EnergyModal is displayed, THE App SHALL adapt energy bolts size for smaller screens
5. IF screen height is less than 600px, THEN THE App SHALL reduce modal padding and spacing

---

### Requirement 5: Headers e AppBars Responsivos

**User Story:** As a user, I want headers to look proportional on my device, so that the app feels balanced.

#### Acceptance Criteria

1. WHEN ProfileHeader is rendered, THE App SHALL calculate expandedHeight based on screen height
2. WHEN LeaderboardHeader is rendered, THE App SHALL use responsive expandedHeight
3. WHEN TreasureHeader is rendered, THE App SHALL use responsive height instead of fixed 180px
4. WHEN WeeklyProgressChart is rendered, THE App SHALL use responsive chart height

---

### Requirement 6: Grids e Layouts Adaptativos

**User Story:** As a user, I want exercise grids to display properly on my device, so that I can complete lessons comfortably.

#### Acceptance Criteria

1. WHEN ImageExercisePage grid is rendered, THE App SHALL calculate childAspectRatio based on available space
2. WHEN LearningControlsPage cards are rendered, THE App SHALL wrap to column on narrow screens
3. WHEN CompletePage stat cards are rendered, THE App SHALL use responsive sizing
4. THE App SHALL maintain minimum spacing of 8px between grid items

---

### Requirement 7: Imagens e Ícones Proporcionais

**User Story:** As a user, I want images and icons to be appropriately sized, so that the visual hierarchy is maintained.

#### Acceptance Criteria

1. WHEN mascot images are displayed, THE App SHALL use responsive width/height
2. WHEN avatar images are displayed, THE App SHALL maintain aspect ratio while scaling
3. WHEN icons in bottom navigation are displayed, THE App SHALL use responsive sizing with minimum 24px
4. WHEN splash logo is displayed, THE App SHALL scale proportionally to screen width

---

### Requirement 8: Acessibilidade de Fontes

**User Story:** As a user with accessibility needs, I want text to respect my device font settings, so that I can read content comfortably.

#### Acceptance Criteria

1. WHEN text is rendered, THE App SHALL respect device textScaleFactor up to 1.3x
2. THE App SHALL provide minimum font sizes to ensure readability
3. IF textScaleFactor exceeds 1.3x, THEN THE App SHALL clamp to 1.3x to prevent layout breaks

---

### Requirement 9: Landscape Mode (Opcional)

**User Story:** As a user, I want the app to be usable in landscape mode, so that I can use it in different orientations.

#### Acceptance Criteria

1. WHEN device is in landscape, THE App SHALL adjust layouts to use horizontal space
2. WHEN CompletePage is in landscape, THE App SHALL display stat cards in a single row
3. WHEN exercise pages are in landscape, THE App SHALL adjust grid columns appropriately

