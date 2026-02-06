# Requirements Document - Controllers Refactoring

## Introduction

The Controllers Refactoring is a critical code quality improvement that addresses technical debt by breaking down oversized controllers into smaller, focused components following the Single Responsibility Principle (SRP). Currently, 7 out of 10 controllers exceed the 500-line limit, with the largest reaching 2045 lines. This refactoring will improve maintainability, testability, and code comprehension without changing any business logic or user-facing behavior.

**Implementation Context**: This is a pure refactoring task - a migration of existing code into better-organized files. No new features are being added, no business logic is being changed, and no UI modifications are being made. The goal is to take working code and reorganize it for better long-term maintenance.

## Glossary

- **Controller**: A GetX controller class that manages state and business logic for a feature
- **SRP**: Single Responsibility Principle - each class should have one reason to change
- **Migration**: Moving existing code from one file to another without modification
- **Refactoring**: Restructuring code without changing its external behavior
- **Line_Limit**: Maximum 500 lines per controller file
- **Binding**: GetX dependency injection configuration that instantiates controllers
- **Observable_State**: Reactive variables using `.obs` suffix that trigger UI updates
- **Controller_Communication**: Pattern where one controller accesses another via `Get.find()`
- **Atomic_Migration**: Moving a complete method or state variable without splitting it
- **View_Update**: Changing `Get.find<OldController>()` to `Get.find<NewController>()` in UI files

## Requirements

### Requirement 1: Line Limit Compliance

**User Story:** As a developer, I want all controllers to be under 500 lines, so that they are easier to read, understand, and maintain.

#### Acceptance Criteria

1. WHEN the refactoring is complete, ALL controllers SHALL be 500 lines or fewer
2. THE refactoring SHALL reduce the number of oversized controllers from 7 to 0
3. THE refactoring SHALL create 21 new controller files from 7 existing controllers
4. WHEN measuring line count, THE system SHALL count all lines including comments and whitespace
5. THE refactoring SHALL maintain the existing 3 controllers that are already under the limit unchanged

### Requirement 2: Code Migration Integrity

**User Story:** As a developer, I want existing code to be moved without modification, so that we don't introduce bugs during refactoring.

#### Acceptance Criteria

1. WHEN migrating a method, THE method SHALL be copied exactly as-is with no logic changes
2. WHEN migrating an observable state, THE state SHALL maintain the same initial value and type
3. WHEN migrating code, ALL comments SHALL be preserved in their original form
4. WHEN migrating code, ALL formatting SHALL be preserved (indentation, spacing, line breaks)
5. THE refactoring SHALL NOT change any business logic, calculations, or algorithms
6. THE refactoring SHALL NOT change any error messages or user-facing text
7. THE refactoring SHALL NOT add new features or functionality

### Requirement 3: Controller Responsibility Separation

**User Story:** As a developer, I want each controller to have a single, clear responsibility, so that I know where to find and modify specific functionality.

#### Acceptance Criteria

1. WHEN dividing ProfileController, THE system SHALL create 5 controllers with distinct responsibilities: data management, settings, social features, courses, and authentication
2. WHEN dividing LessonController, THE system SHALL create 4 controllers with distinct responsibilities: flow control, exercise management, progress tracking, and rewards
3. WHEN dividing GamificationController, THE system SHALL create 4 controllers with distinct responsibilities: streak, energy, XP/levels, and gems
4. WHEN dividing OnboardingController, THE system SHALL create 3 controllers with distinct responsibilities: flow navigation, data collection, and validation
5. WHEN dividing TreasureController, THE system SHALL create 2 controllers with distinct responsibilities: challenges and rewards
6. WHEN dividing HomeController, THE system SHALL create 2 controllers with distinct responsibilities: navigation and stats display
7. WHEN dividing AuthController, THE system SHALL create 2 controllers with distinct responsibilities: credentials and providers
8. EACH new controller SHALL have a clear, single-purpose name that describes its responsibility

### Requirement 4: Observable States Migration

**User Story:** As a developer, I want observable states to be in the correct controller, so that UI reactivity continues to work correctly.

#### Acceptance Criteria

1. WHEN migrating observable states, THE system SHALL move `isLoading` and `errorMessage` to EVERY new controller
2. WHEN migrating observable states, THE system SHALL group related states together in the same controller
3. WHEN migrating observable states, THE system SHALL preserve the `.obs` suffix and initial values
4. WHEN a state is accessed by multiple controllers, THE system SHALL keep it in the most logical owner and use `Get.find()` for access
5. THE refactoring SHALL NOT create duplicate observable states across controllers

### Requirement 5: Method Migration

**User Story:** As a developer, I want methods to be in the controller that matches their responsibility, so that code organization is logical and predictable.

#### Acceptance Criteria

1. WHEN migrating methods, THE system SHALL move complete methods as atomic units (no splitting)
2. WHEN migrating methods, THE system SHALL preserve all method signatures (parameters, return types)
3. WHEN migrating methods, THE system SHALL preserve method visibility (public vs private)
4. WHEN migrating private methods, THE system SHALL keep them private in the new controller
5. WHEN migrating public methods, THE system SHALL update all callers to use the new controller
6. THE refactoring SHALL group related methods together in the same controller

### Requirement 6: Controller Communication

**User Story:** As a developer, I want controllers to communicate through well-defined interfaces, so that dependencies are clear and testable.

#### Acceptance Criteria

1. WHEN a controller needs data from another controller, IT SHALL use `Get.find<OtherController>()` to access it
2. WHEN initializing controller dependencies, THE system SHALL use `onInit()` lifecycle method
3. WHEN a controller dependency is optional, THE system SHALL wrap `Get.find()` in try-catch
4. WHEN a controller dependency is required, THE system SHALL let `Get.find()` throw if not found
5. THE refactoring SHALL NOT create circular dependencies between controllers
6. THE refactoring SHALL document controller dependencies in code comments

### Requirement 7: Binding Updates

**User Story:** As a developer, I want bindings to instantiate all new controllers, so that dependency injection works correctly.

#### Acceptance Criteria

1. WHEN updating a binding, THE system SHALL add `Get.lazyPut()` for each new controller
2. WHEN updating a binding, THE system SHALL remove the old controller's `Get.lazyPut()`
3. WHEN updating a binding, THE system SHALL maintain the correct instantiation order (dependencies first)
4. THE refactoring SHALL update exactly 7 binding files (one per refactored feature)
5. THE refactoring SHALL NOT modify bindings for features that are not being refactored

### Requirement 8: View Updates

**User Story:** As a developer, I want views to reference the correct controllers, so that UI continues to display and update correctly.

#### Acceptance Criteria

1. WHEN updating a view, THE system SHALL change `Get.find<OldController>()` to `Get.find<NewController>()`
2. WHEN updating a view, THE system SHALL update all references to states and methods
3. WHEN updating a view, THE system SHALL preserve all `Obx()` wrappers and reactive logic
4. WHEN a view uses multiple controllers, THE system SHALL add multiple `Get.find()` calls
5. THE refactoring SHALL identify and update ALL views that use each refactored controller
6. THE refactoring SHALL NOT change any UI layout, styling, or visual behavior

### Requirement 9: Error Handler Migration

**User Story:** As a developer, I want error handlers to be available where needed, so that error messages remain consistent.

#### Acceptance Criteria

1. WHEN multiple controllers need the same error handler, THE system SHALL create a shared error handler file
2. WHEN only one controller needs an error handler, THE system SHALL keep it as a private method in that controller
3. WHEN migrating error handlers, THE system SHALL preserve all error messages exactly
4. THE refactoring SHALL follow the error handling patterns defined in `firebase.md`
5. THE refactoring SHALL NOT change any error message text or error handling logic

### Requirement 10: Testing Continuity

**User Story:** As a developer, I want existing tests to continue passing, so that I know the refactoring didn't break functionality.

#### Acceptance Criteria

1. WHEN the refactoring is complete, ALL existing unit tests SHALL pass without modification
2. WHEN the refactoring is complete, ALL existing property tests SHALL pass without modification
3. WHEN the refactoring is complete, ALL existing integration tests SHALL pass without modification
4. IF a test fails after refactoring, THE system SHALL revert the changes and investigate
5. THE refactoring SHALL NOT require writing new tests (tests are for new features, not refactoring)

### Requirement 11: File Organization

**User Story:** As a developer, I want new controller files to follow the project's naming and organization conventions, so that the codebase remains consistent.

#### Acceptance Criteria

1. WHEN creating new controller files, THE system SHALL use snake_case naming
2. WHEN creating new controller files, THE system SHALL use the `_controller.dart` suffix
3. WHEN creating new controller files, THE system SHALL place them in the correct feature's `controllers/` folder
4. WHEN creating new controller files, THE system SHALL follow the standard controller structure (states, lifecycle, public methods, private methods)
5. THE refactoring SHALL maintain the existing folder structure without creating new folders

### Requirement 12: Documentation Updates

**User Story:** As a developer, I want documentation to reflect the new controller structure, so that I can understand the system architecture.

#### Acceptance Criteria

1. WHEN the refactoring is complete, THE system SHALL update `lista-controllers.md` to mark refactored controllers as complete
2. WHEN the refactoring is complete, THE system SHALL update any architecture documentation that references old controllers
3. WHEN creating new controllers, THE system SHALL add clear comments explaining each controller's responsibility
4. THE refactoring SHALL maintain all existing code comments and documentation

### Requirement 13: Incremental Validation

**User Story:** As a developer, I want to validate each controller refactoring before moving to the next, so that issues are caught early.

#### Acceptance Criteria

1. WHEN completing a controller refactoring, THE system SHALL run all tests before proceeding
2. WHEN completing a controller refactoring, THE system SHALL verify all new controllers are under 500 lines
3. WHEN completing a controller refactoring, THE system SHALL verify the old controller is deleted
4. WHEN completing a controller refactoring, THE system SHALL verify all views are updated
5. THE refactoring SHALL proceed one controller at a time, not multiple in parallel

### Requirement 14: Rollback Safety

**User Story:** As a developer, I want the ability to rollback if issues are discovered, so that the codebase can be restored to a working state.

#### Acceptance Criteria

1. WHEN starting a controller refactoring, THE system SHALL ensure all changes are committed to git
2. WHEN a refactoring fails validation, THE system SHALL provide clear instructions for rollback
3. WHEN a refactoring is complete, THE system SHALL create a single commit with all changes for that controller
4. THE refactoring SHALL follow the commit message format defined in the README
5. THE refactoring SHALL NOT mix changes from multiple controllers in a single commit

### Requirement 15: Priority Order

**User Story:** As a developer, I want to refactor the largest controllers first, so that we get the biggest maintainability improvements early.

#### Acceptance Criteria

1. THE refactoring SHALL proceed in this order: ProfileController (2045 lines), LessonController (1810 lines), GamificationController (1367 lines), OnboardingController (1228 lines), TreasureController (897 lines), HomeController (764 lines), AuthController (718 lines)
2. WHEN a controller refactoring is blocked, THE system SHALL skip to the next controller and return later
3. THE refactoring SHALL NOT proceed to the next controller until the current one is validated and committed

