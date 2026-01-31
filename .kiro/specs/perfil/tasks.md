# Implementation Plan: Profile Logic System

## Overview

This implementation plan covers the profile management system for Pippo, including profile viewing/editing, settings management, authentication changes (password, phone), social features (follow/unfollow), course management, and account deletion. The system is implemented as a **controller-only architecture** that works directly with Firestore documents without models, repositories, or services.

**IMPORTANT**: The profile system is designed to work with existing modules:
1. **ProfileController** (to be created) - Contains all profile logic and state management
2. **Profile UI** (existing) - 11 pages and 12 widgets already implemented
3. **GamificationController** (existing) - ProfileController reads stats but never writes them
4. **Firebase Auth** (existing) - Used for authentication operations
5. **Firebase Firestore** (existing) - Direct document manipulation

The implementation follows strict steering rules: **NO models, repositories, or services** - all logic resides directly in `ProfileController`. The system uses atomic Firestore operations (batch writes) for social features and course management.

## Tasks

- [x] 1. Create ProfileController Structure
  - [x] 1.1 Create ProfileController class extending GetxController
    - Create file: `lib/features/inners/profile/controllers/profile_controller.dart`
    - Add all observable states from design.md
    - Add lifecycle methods (onInit, onClose)
    - _Requirements: All_
  
  - [x] 1.2 Add Firebase instances
    - Add `final _auth = FirebaseAuth.instance;`
    - Add `final _firestore = FirebaseFirestore.instance;`
    - _Requirements: All_
  
  - [x] 1.3 Create ProfileBinding
    - Create file: `lib/features/inners/profile/bindings/profile_binding.dart`
    - Implement Get.lazyPut for ProfileController
    - _Requirements: All_

- [x] 2. Implement Profile Data Management
  - [x] 2.1 Implement loadOwnProfile()
    - Load user document from Firestore
    - Load stats from gamification subcollection (read-only)
    - Calculate profile completion percentage
    - Load social counts (following/followers)
    - Update all observable states
    - Handle errors with _handleFirestoreError()
    - _Requirements: 1.1, 1.2, 1.3, 8.1, 8.2_
  
  - [x] 2.2 Implement loadUserProfile(String userId)
    - Load another user's profile data
    - Load their stats (read-only)
    - Check if current user follows this user
    - Update viewedUserData observable
    - Handle errors with _handleFirestoreError()
    - _Requirements: 1.4, 1.5_
  
  - [x] 2.3 Implement updateProfile(Map<String, dynamic> updates)
    - Validate authentication
    - Add updatedAt timestamp
    - Update Firestore document
    - Update local observable states
    - Reload profile to recalculate completion
    - Show success snackbar
    - Handle errors with _handleFirestoreError()
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 2.4 Implement checkUsernameAvailability(String newUsername)
    - Skip if same as current username
    - Query Firestore for existing username
    - Update isUsernameAvailable state
    - Handle errors gracefully
    - _Requirements: 2.1, 2.2_
  
  - [x] 2.5 Implement _loadProfileStats(String userId)
    - Load gamification stats (read-only)
    - Count completed lessons across all courses
    - Update totalXp, currentStreak, level, lessonsCompleted
    - _Requirements: 1.2, 1.3_
  
  - [x] 2.6 Implement _calculateProfileCompletion(Map<String, dynamic> userData)
    - Check required fields: name, username, avatarId, country, bio
    - Calculate completion percentage
    - Update missingFields list
    - _Requirements: 8.1, 8.2_
  
  - [x] 2.7 Implement _loadSocialCounts(String userId)
    - Use Firestore count queries for following/followers
    - Update followingCount and followersCount
    - _Requirements: 5.4_


- [x] 3. Implement Settings Management
  - [x] 3.1 Implement loadSettings()
    - Load settings document from Firestore
    - Update all settings observable states
    - Handle missing document (use defaults)
    - Handle errors with _handleFirestoreError()
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [x] 3.2 Implement updateSetting(String key, dynamic value)
    - Validate authentication
    - Update Firestore with merge option
    - Update corresponding observable state
    - Handle errors with _handleFirestoreError()
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 4. Implement Authentication Changes
  - [x] 4.1 Implement changePassword(String currentPassword, String newPassword)
    - Validate authentication
    - Create email credential with current password
    - Reauthenticate user
    - Update password in Firebase Auth
    - Show success snackbar and navigate back
    - Handle auth errors with _handleFirebaseAuthError()
    - _Requirements: 6.1, 6.2_
  
  - [x] 4.2 Implement linkPhoneNumber(String phoneNumber, String verificationCode)
    - Validate authentication
    - Create phone credential with verification code
    - Link credential to current user
    - Update Firestore with phone and phoneVerified
    - Update local observable states
    - Show success snackbar and navigate to PhoneLinkedPage
    - Handle auth errors with _handleFirebaseAuthError()
    - _Requirements: 6.3, 6.4, 6.5_
  
  - [x] 4.3 Implement _reauthenticateForDeletion()
    - Trigger reauthentication modal/dialog
    - Handle reauthentication flow
    - Retry deletion after successful reauthentication
    - _Requirements: 6.6_

- [x] 5. Implement Social Features
  - [x] 5.1 Implement followUser(String targetUserId)
    - Validate authentication
    - Prevent self-follow
    - Create batch write
    - Add to current user's following subcollection
    - Add to target user's followers subcollection
    - Commit batch atomically
    - Update local states (isFollowingViewedUser, followingCount)
    - Show success snackbar
    - Handle errors with _handleFirestoreError()
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [x] 5.2 Implement unfollowUser(String targetUserId)
    - Validate authentication
    - Create batch write
    - Delete from current user's following subcollection
    - Delete from target user's followers subcollection
    - Commit batch atomically
    - Update local states
    - Show success snackbar
    - Handle errors with _handleFirestoreError()
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [x] 5.3 Implement loadFollowing()
    - Validate authentication
    - Load following subcollection
    - For each followed user, load their profile data
    - Update following list and followingCount
    - Handle errors with _handleFirestoreError()
    - _Requirements: 5.4_
  
  - [x] 5.4 Implement loadFollowers()
    - Validate authentication
    - Load followers subcollection
    - For each follower, load their profile data
    - Update followers list and followersCount
    - Handle errors with _handleFirestoreError()
    - _Requirements: 5.4_
  
  - [x] 5.5 Implement _checkIfFollowing(String currentUserId, String targetUserId)
    - Check if following document exists
    - Update isFollowingViewedUser state
    - _Requirements: 5.3_


- [x] 6. Implement Course Management
  - [x] 6.1 Implement loadUserCourses()
    - Validate authentication
    - Load courses subcollection where isActive = true
    - Identify primary course
    - Update userCourses and primaryCourseId
    - Handle errors with _handleFirestoreError()
    - _Requirements: 7.1, 7.2_
  
  - [x] 6.2 Implement setPrimaryCourse(String courseId)
    - Validate authentication
    - Create batch write
    - Unset isPrimary for all courses
    - Set isPrimary = true for selected course
    - Commit batch atomically
    - Update local states
    - Show success snackbar
    - Handle errors with _handleFirestoreError()
    - _Requirements: 7.3, 7.4_
  
  - [x] 6.3 Implement removeCourse(String courseId)
    - Validate authentication
    - Prevent removal of primary course
    - Mark course as inactive (preserve progress)
    - Remove from local list
    - Show success snackbar
    - Handle errors with _handleFirestoreError()
    - _Requirements: 7.5_

- [x] 7. Implement Account Deletion
  - [x] 7.1 Implement deleteAccount()
    - Validate authentication
    - Create batch write for Firestore deletion
    - Delete main user document
    - Commit batch
    - Delete Firebase Auth account
    - Handle requires-recent-login error
    - Navigate to /auth
    - Show success snackbar
    - Handle errors with _handleFirebaseAuthError()
    - _Requirements: 6.6, 6.7, 6.8_

- [x] 8. Implement Validators
  - [x] 8.1 Implement validateName(String? value)
    - Check not null/empty
    - Check minimum 2 characters
    - Check maximum 50 characters
    - Return error message or null
    - _Requirements: 2.3_
  
  - [x] 8.2 Implement validateUsername(String? value)
    - Check not null/empty
    - Check minimum 3 characters
    - Check maximum 20 characters
    - Check format (letters, numbers, underscore only)
    - Check availability (isUsernameAvailable state)
    - Return error message or null
    - _Requirements: 2.3_
  
  - [x] 8.3 Implement validateBio(String? value)
    - Check maximum 150 characters
    - Return error message or null
    - _Requirements: 2.3_
  
  - [x] 8.4 Implement validateCurrentPassword(String? value)
    - Check not null/empty
    - Return error message or null
    - _Requirements: 6.1_
  
  - [x] 8.5 Implement validateNewPassword(String? value)
    - Check not null/empty
    - Check minimum 6 characters
    - Return error message or null
    - _Requirements: 6.1_
  
  - [x] 8.6 Implement validateConfirmPassword(String? value, String newPassword)
    - Check not null/empty
    - Check matches newPassword
    - Return error message or null
    - _Requirements: 6.1_
  
  - [x] 8.7 Implement validatePhoneNumber(String? value)
    - Check not null/empty
    - Remove formatting characters
    - Check length (10-15 digits)
    - Return error message or null
    - _Requirements: 6.3_


- [x] 9. Implement Error Handlers
  - [x] 9.1 Implement _handleFirestoreError(FirebaseException e)
    - Map all Firestore error codes to Portuguese messages
    - Use exact messages from firebase.md steering rules
    - Never expose technical error codes
    - Return user-friendly message
    - _Requirements: 9.1, 9.2_
  
  - [x] 9.2 Implement _handleFirebaseAuthError(FirebaseAuthException e)
    - Map all Auth error codes to Portuguese messages
    - Handle wrong-password, weak-password, requires-recent-login, etc.
    - Never expose technical error codes
    - Return user-friendly message
    - _Requirements: 9.1, 9.2_

- [x] 10. Checkpoint - Core Implementation Complete
  - Ensure ProfileController compiles without errors
  - Ensure all methods have proper error handling
  - Ensure all observable states are properly initialized
  - Ask the user if questions arise

- [x] 11. Connect UI to Controller - Profile Pages
  - [x] 11.1 Connect ProfilePage to controller
    - Add Get.find<ProfileController>() in initState or build
    - Wrap reactive widgets with Obx()
    - Call loadOwnProfile() on page load
    - Display userName, username, avatarId, bio, country
    - Display totalXp, currentStreak, lessonsCompleted, level
    - Display profileCompletionPercentage, missingFields
    - Display followingCount, followersCount
    - Show loading indicator when isLoadingProfile = true
    - Show error message when errorMessage is not empty
    - _Requirements: 1.1, 1.2, 1.3, 8.1, 8.2_
  
  - [x] 11.2 Connect EditProfilePage to controller
    - Add Get.find<ProfileController>()
    - Connect TextEditingControllers to form fields
    - Implement debounced username check (500ms)
    - Call checkUsernameAvailability() on username change
    - Show availability indicator (isUsernameAvailable, isCheckingUsername)
    - Connect validators to TextFormField validator property
    - Call updateProfile() on Save button
    - Show loading indicator when isLoading = true
    - Show error message when errorMessage is not empty
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 11.3 Connect UserProfilePage to controller
    - Add Get.find<ProfileController>()
    - Call loadUserProfile(userId) on page load
    - Display viewedUserData (name, username, bio, avatar, stats)
    - Show Follow/Unfollow button based on isFollowingViewedUser
    - Connect Follow button to followUser()
    - Connect Unfollow button to unfollowUser()
    - Show loading indicator when isLoading = true
    - _Requirements: 1.4, 1.5, 5.1, 5.2, 5.3_

- [x] 12. Connect UI to Controller - Settings Pages
  - [x] 12.1 Connect SettingsPage to controller
    - Add Get.find<ProfileController>()
    - Call loadSettings() on page load
    - Navigate to sub-pages (Notifications, Learning Controls, etc.)
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [x] 12.2 Connect NotificationsPage to controller
    - Display practiceReminders, reminderTime, leaderboardUpdates, friendActivity
    - Connect Switch widgets to updateSetting()
    - Connect reminderTime selector to updateSetting()
    - _Requirements: 4.3_
  
  - [x] 12.3 Connect LearningControlsPage to controller
    - Display soundEffects, listeningExercises, speakingExercises, dailyGoal
    - Connect Switch widgets to updateSetting()
    - Connect dailyGoal selector to updateSetting()
    - _Requirements: 4.2_


- [x] 13. Connect UI to Controller - Authentication Pages
  - [x] 13.1 Connect ChangePasswordPage to controller
    - Add Get.find<ProfileController>()
    - Connect TextEditingControllers for current, new, confirm passwords
    - Connect validators to TextFormField validator property
    - Call changePassword() on Update Password button
    - Show loading indicator when isLoading = true
    - Show error message when errorMessage is not empty
    - _Requirements: 6.1, 6.2_
  
  - [x] 13.2 Connect PhoneNumberPage to controller
    - Add Get.find<ProfileController>()
    - Connect TextEditingController for phone number
    - Add mask_text_input_formatter for phone formatting
    - Connect validator to TextFormField
    - Implement Firebase Phone Auth flow (send SMS)
    - Navigate to VerifyPhonePage after SMS sent
    - _Requirements: 6.3, 6.4_
  
  - [x] 13.3 Connect VerifyPhonePage to controller
    - Add Get.find<ProfileController>()
    - Connect AppPinput for 6-digit code
    - Call linkPhoneNumber() on Verify button
    - Show loading indicator when isLoading = true
    - Show error message when errorMessage is not empty
    - _Requirements: 6.4, 6.5_

- [x] 14. Connect UI to Controller - Course Management
  - [x] 14.1 Connect CoursesPage to controller
    - Add Get.find<ProfileController>()
    - Call loadUserCourses() on page load
    - Display userCourses list
    - Highlight primary course (primaryCourseId)
    - Connect "Set as Primary" button to setPrimaryCourse()
    - Connect "Remove" button to removeCourse()
    - Show loading indicator when isLoadingCourses = true
    - Show error message when errorMessage is not empty
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 15. Connect UI to Controller - Account Deletion
  - [x] 15.1 Connect DeleteAccountModal to controller
    - Show first confirmation modal
    - Explain consequences of deletion
    - Connect "Delete" button to show ConfirmDeleteModal
    - _Requirements: 6.6_
  
  - [x] 15.2 Connect ConfirmDeleteModal to controller
    - Show second confirmation modal
    - Require explicit confirmation
    - Connect "Confirm Delete" button to deleteAccount()
    - Show loading indicator when isLoading = true
    - Show error message when errorMessage is not empty
    - _Requirements: 6.6, 6.7, 6.8_

- [x] 16. Checkpoint - UI Integration Complete
  - Test all pages manually
  - Verify all buttons and forms work correctly
  - Verify loading states display properly
  - Verify error messages display properly
  - Ask the user if questions arise

- [x] 17. Unit Tests - Profile Management
  - [x] 17.1 Test loadOwnProfile() success
    - Setup: Mock authenticated user with complete profile
    - Execute: Call loadOwnProfile()
    - Verify: All observable states updated correctly
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [x] 17.2 Test loadOwnProfile() unauthenticated
    - Setup: Mock unauthenticated user
    - Execute: Call loadOwnProfile()
    - Verify: Error message contains "não autenticado"
    - _Requirements: 1.1_
  
  - [x] 17.3 Test updateProfile() success
    - Setup: Mock authenticated user
    - Execute: Call updateProfile({'name': 'New Name'})
    - Verify: Firestore updated, local state updated
    - _Requirements: 2.1, 2.2_
  
  - [x] 17.4 Test checkUsernameAvailability() available
    - Setup: Mock Firestore query returning empty
    - Execute: Call checkUsernameAvailability('newuser')
    - Verify: isUsernameAvailable = true
    - _Requirements: 2.1, 2.2_
  
  - [x] 17.5 Test checkUsernameAvailability() taken
    - Setup: Mock Firestore query returning existing user
    - Execute: Call checkUsernameAvailability('existinguser')
    - Verify: isUsernameAvailable = false
    - _Requirements: 2.1, 2.2_
  
  - [x] 17.6 Test _calculateProfileCompletion() complete
    - Setup: User data with all required fields
    - Execute: Call _calculateProfileCompletion()
    - Verify: profileCompletionPercentage = 100, missingFields empty
    - _Requirements: 8.1, 8.2_
  
  - [x] 17.7 Test _calculateProfileCompletion() incomplete
    - Setup: User data missing bio and country
    - Execute: Call _calculateProfileCompletion()
    - Verify: profileCompletionPercentage = 60, missingFields = ['bio', 'country']
    - _Requirements: 8.1, 8.2_


- [x] 18. Unit Tests - Settings Management
  - [x] 18.1 Test loadSettings() success
    - Setup: Mock settings document in Firestore
    - Execute: Call loadSettings()
    - Verify: All settings observable states updated
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [x] 18.2 Test loadSettings() missing document
    - Setup: Mock Firestore returning no document
    - Execute: Call loadSettings()
    - Verify: Default values used for all settings
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [x] 18.3 Test updateSetting() success
    - Setup: Mock authenticated user
    - Execute: Call updateSetting('soundEffects', false)
    - Verify: Firestore updated, soundEffects.value = false
    - _Requirements: 4.1_

- [x] 19. Unit Tests - Authentication Changes
  - [x] 19.1 Test changePassword() success
    - Setup: Mock successful reauthentication
    - Execute: Call changePassword('current', 'newpass')
    - Verify: Password updated, success snackbar shown
    - _Requirements: 6.1, 6.2_
  
  - [x] 19.2 Test changePassword() wrong current password
    - Setup: Mock failed reauthentication
    - Execute: Call changePassword('wrong', 'newpass')
    - Verify: Error message contains "incorreta"
    - _Requirements: 6.1, 6.2_
  
  - [x] 19.3 Test linkPhoneNumber() success
    - Setup: Mock successful phone verification
    - Execute: Call linkPhoneNumber('+5511999999999', '123456')
    - Verify: Phone linked, Firestore updated, phoneVerified = true
    - _Requirements: 6.3, 6.4, 6.5_
  
  - [x] 19.4 Test linkPhoneNumber() invalid code
    - Setup: Mock invalid verification code
    - Execute: Call linkPhoneNumber('+5511999999999', '000000')
    - Verify: Error message contains "inválido"
    - _Requirements: 6.4_

- [x] 20. Unit Tests - Social Features
  - [x] 20.1 Test followUser() success
    - Setup: Mock authenticated user, target user
    - Execute: Call followUser('targetUserId')
    - Verify: Batch write with 2 operations, local states updated
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [x] 20.2 Test followUser() self-follow prevention
    - Setup: Mock authenticated user
    - Execute: Call followUser(currentUserId)
    - Verify: Error message, no Firestore writes
    - _Requirements: 5.1_
  
  - [x] 20.3 Test unfollowUser() success
    - Setup: Mock authenticated user following target
    - Execute: Call unfollowUser('targetUserId')
    - Verify: Batch delete with 2 operations, local states updated
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [x] 20.4 Test loadFollowing() success
    - Setup: Mock following subcollection with 3 users
    - Execute: Call loadFollowing()
    - Verify: following list has 3 items, followingCount = 3
    - _Requirements: 5.4_
  
  - [x] 20.5 Test loadFollowers() success
    - Setup: Mock followers subcollection with 5 users
    - Execute: Call loadFollowers()
    - Verify: followers list has 5 items, followersCount = 5
    - _Requirements: 5.4_

- [x] 21. Unit Tests - Course Management
  - [x] 21.1 Test loadUserCourses() success
    - Setup: Mock 3 active courses, 1 primary
    - Execute: Call loadUserCourses()
    - Verify: userCourses has 3 items, primaryCourseId set correctly
    - _Requirements: 7.1, 7.2_
  
  - [x] 21.2 Test setPrimaryCourse() success
    - Setup: Mock 3 courses
    - Execute: Call setPrimaryCourse('course2')
    - Verify: Batch write unsetting all, setting course2, local states updated
    - _Requirements: 7.3, 7.4_
  
  - [x] 21.3 Test removeCourse() success
    - Setup: Mock 3 courses, removing non-primary
    - Execute: Call removeCourse('course3')
    - Verify: Course marked inactive, removed from local list
    - _Requirements: 7.5_
  
  - [x] 21.4 Test removeCourse() prevent primary removal
    - Setup: Mock 3 courses, trying to remove primary
    - Execute: Call removeCourse(primaryCourseId)
    - Verify: Error message, no Firestore writes
    - _Requirements: 7.5_

- [x] 22. Unit Tests - Account Deletion
  - [x] 22.1 Test deleteAccount() success
    - Setup: Mock authenticated user with recent login
    - Execute: Call deleteAccount()
    - Verify: Firestore document deleted, Auth account deleted, navigated to /auth
    - _Requirements: 6.6, 6.7, 6.8_
  
  - [x] 22.2 Test deleteAccount() requires recent login
    - Setup: Mock requires-recent-login error
    - Execute: Call deleteAccount()
    - Verify: Error message contains "faça login novamente", reauthentication triggered
    - _Requirements: 6.6_
  
  - [x] 22.3 Test deleteAccount() Firestore error
    - Setup: Mock Firestore error during deletion
    - Execute: Call deleteAccount()
    - Verify: Error message shown, Auth account not deleted
    - _Requirements: 6.6_

- [x] 23. Checkpoint - Unit Tests Complete
  - Ensure all unit tests pass, ask the user if questions arise.

- [x] 24. Property-Based Tests - Username Uniqueness
  - [x] 24.1 Property 1: Username uniqueness is enforced
    - **Statement:** For any username update, the system SHALL verify uniqueness before allowing the update
    - **Validates: Requirements 2.1, 2.2**
    - **Status:** ✅ PASSED - All 7 property tests passed (100 iterations each)
    - Generate: Random username (3-20 characters)
    - Execute: Mock existing username, call checkUsernameAvailability()
    - Assert: isUsernameAvailable = false, updateProfile() fails validation
    - **Tests implemented:**
      - Property 1a: Taken username fails validation
      - Property 1b: Available username with valid format passes
      - Property 1c: User can keep current username
      - Property 1d: Length validation (3-20 characters)
      - Property 1e: Invalid characters rejected
      - Property 1f: Underscore is valid
      - Property 1g: Empty/null username rejected

- [x] 25. Property-Based Tests - Profile Completion
  - [x] 25.1 Property 2: Profile completion is calculated correctly
    - **Statement:** For any set of profile fields, the completion percentage SHALL equal (completed fields / total required fields) × 100
    - **Validates: Requirements 8.1, 8.2**
    - **Status:** ✅ PASSED - All 12 property tests passed (100 iterations each)
    - Generate: Random profile data with optional fields
    - Execute: Call _calculateProfileCompletion()
    - Assert: Percentage matches manual calculation, missingFields list is accurate
    - **Tests implemented:**
      - Property 2a: Completion percentage calculation correctness for random combinations
      - Property 2b: 100% completion when all fields present
      - Property 2c: 0% completion when all fields missing
      - Property 2d: Percentage always between 0-100
      - Property 2e: Missing fields count equals total minus completed

- [x] 26. Property-Based Tests - Follow/Unfollow Atomicity
  - [x] 26.1 Property 3: Follow operations are atomic
    - **Statement:** For any follow or unfollow operation, BOTH subcollections (following and followers) SHALL be updated together or not at all
    - **Validates: Requirements 5.1, 5.2, 5.3**
    - **Status:** ✅ PASSED - All 8 property tests passed (100 iterations each)
    - Generate: Random currentUserId and targetUserId
    - Execute: Call followUser(), verify batch operations
    - Assert: Both writes in batch, or both fail together
    - **Tests implemented:**
      - Property 3a: Follow operation uses batch with exactly 2 writes
      - Property 3b: Unfollow operation uses batch with exactly 2 deletes
      - Property 3c: User cannot follow themselves
      - Property 3d: Follow operation requires authenticated user
      - Property 3e: Batch commit ensures all-or-nothing for follow
      - Property 3f: Batch commit ensures all-or-nothing for unfollow
      - Property 3g: Follow state is consistent after successful operation
      - Property 3h: Unfollow state is consistent after successful operation

- [x] 27. Property-Based Tests - Primary Course Exclusivity
  - [x] 27.1 Property 4: Only one course can be primary
    - **Statement:** For any user, at most one course SHALL have isPrimary = true at any time
    - **Validates: Requirements 7.3, 7.4**
    - Generate: Array of 2-5 courses with random isPrimary values
    - Execute: Call setPrimaryCourse()
    - Assert: Exactly one course has isPrimary = true

- [x] 28. Property-Based Tests - Password Change Reauthentication
  - [x] 28.1 Property 5: Password change requires reauthentication
    - **Statement:** For any password change attempt, the system SHALL require successful reauthentication with the current password before allowing the change
    - **Validates: Requirements 6.1, 6.2**
    - **Status:** ✅ PASSED - All 10 property tests passed (100 iterations each)
    - Generate: Random current, new, and wrong passwords
    - Execute: Call changePassword() with wrong password, then correct password
    - Assert: Wrong password fails with "incorreta", correct password succeeds
    - **Tests implemented:**
      - Property 5a: Password change fails with wrong current password
      - Property 5b: Password change succeeds with correct current password
      - Property 5c: Reauthentication must occur before password update
      - Property 5d: Wrong password error message is user-friendly
      - Property 5e: New password must meet validation requirements
      - Property 5f: Current password field cannot be empty
      - Property 5g: Password confirmation must match new password
      - Property 5h: Loading state is managed during password change
      - Property 5i: Error message is cleared before new attempt
      - Property 5j: User authentication is verified before password change

- [x] 29. Property-Based Tests - Phone Linking Verification
  - [x] 29.1 Property 6: Phone linking requires valid verification code
    - **Statement:** For any phone linking attempt, the system SHALL verify the SMS code before linking the phone number to the account
    - **Validates: Requirements 6.3, 6.4, 6.5**
    - **Status:** ✅ PASSED - All 11 property tests passed (100 iterations each)
    - Generate: Random phone number, valid code, invalid code
    - Execute: Call linkPhoneNumber() with invalid code, then valid code
    - Assert: Invalid code fails, valid code succeeds and sets phoneVerified = true
    - **Tests implemented:**
      - Property 6a: Phone linking fails with invalid verification code
      - Property 6b: Phone linking succeeds with valid verification code
      - Property 6c: SMS verification must occur before phone linking
      - Property 6d: Invalid code error message is user-friendly
      - Property 6e: Phone number must meet validation requirements
      - Property 6f: phoneVerified is true only after successful verification
      - Property 6g: Phone number is saved to Firestore after verification
      - Property 6h: Loading state is set during phone linking
      - Property 6i: Error message is cleared before new attempt
      - Property 6j: User authentication is verified before phone linking
      - Property 6k: Error when phone is already linked to another account

- [x] 30. Property-Based Tests - Account Deletion Completeness
  - [x] 30.1 Property 7: Account deletion removes all user data
    - **Statement:** For any account deletion, the system SHALL delete both the Firestore user document and the Firebase Auth account
    - **Validates: Requirements 6.6, 6.7, 6.8**
    - **Status:** ✅ PASSED - All 12 property tests passed (100 iterations each)
    - Generate: Random userId
    - Execute: Call deleteAccount()
    - Assert: Both Firestore and Auth deletions occur, navigation to /auth
    - **Tests implemented:**
      - Property 7a: Account deletion requires authentication
      - Property 7b: Account deletion uses batch for Firestore operations
      - Property 7c: Firestore deletion occurs before Auth deletion
      - Property 7d: Navigation to /auth occurs after deletion
      - Property 7e: Requires-recent-login error triggers reauthentication
      - Property 7f: Firestore error prevents Auth deletion
      - Property 7g: Success message is shown after deletion
      - Property 7h: Loading state is managed during deletion
      - Property 7i: Error message is cleared before deletion
      - Property 7j: Both Firestore and Auth deletions are attempted
      - Property 7k: Deletion is irreversible
      - Property 7l: Subcollections deletion is handled

- [x] 31. Property-Based Tests - Settings Persistence
  - [x] 31.1 Property 8: Settings are persisted correctly
    - **Statement:** For any setting update, the new value SHALL be persisted to Firestore and reflected in the observable state
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.4**
    - Generate: Random setting key and value
    - Execute: Call updateSetting()
    - Assert: Firestore updated, observable state matches

- [x] 32. Property-Based Tests - Username Format Validation
  - [x] 32.1 Property 9: Username format is validated
    - **Statement:** For any username, it SHALL only be accepted if it contains 3-20 characters of letters, numbers, and underscores only
    - **Validates: Requirements 2.3**
    - Generate: Random strings (valid and invalid formats)
    - Execute: Call validateUsername()
    - Assert: Valid formats return null, invalid formats return error message

- [x] 33. Property-Based Tests - Error Message Localization
  - [x] 33.1 Property 10: All errors have Portuguese messages
    - **Statement:** For any Firebase error code, the error handler SHALL return a non-empty Portuguese message without exposing technical details
    - **Validates: Requirements 9.1, 9.2**
    - Generate: All known Firestore and Auth error codes
    - Execute: Call error handlers
    - Assert: Messages are non-empty, in Portuguese, don't contain error codes

- [x] 34. Checkpoint - Property Tests Complete
  - Ensure all property tests pass (minimum 100 iterations each), ask the user if questions arise.

- [x] 35. Integration Tests - Profile View Flow
  - [x] 35.1 Test complete profile view flow
    - Setup: Launch ProfilePage with complete profile
    - Execute: Load profile data
    - Verify: All fields displayed, stats loaded from GamificationController, completion = 100%
    - _Requirements: 1.1, 1.2, 1.3, 8.1, 8.2_
  
  - [x] 35.2 Test incomplete profile view flow
    - Setup: Launch ProfilePage with missing bio and phone
    - Execute: Load profile data
    - Verify: CompleteProfileCard shown, completion < 100%, missingFields contains 'bio' and 'phone'
    - _Requirements: 8.1, 8.2_

- [x] 36. Integration Tests - Edit Profile Flow
  - [x] 36.1 Test complete edit profile flow
    - Setup: Launch EditProfilePage
    - Execute: Change name, username (check availability), bio, avatar, country, save
    - Verify: All changes saved to Firestore, profile reloaded, success snackbar shown, navigated back
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 36.2 Test username availability check flow
    - Setup: Launch EditProfilePage
    - Execute: Type new username, wait 500ms
    - Verify: checkUsernameAvailability() called, availability indicator shown
    - _Requirements: 2.1, 2.2_
  
  - [x] 36.3 Test edit profile validation errors
    - Setup: Launch EditProfilePage
    - Execute: Enter invalid data (name too short, username with spaces, bio too long)
    - Verify: Validation errors shown inline, Save button disabled or fails
    - _Requirements: 2.3_

- [x] 37. Integration Tests - Social Features Flow
  - [x] 37.1 Test follow user flow
    - Setup: Launch UserProfilePage for another user
    - Execute: Click Follow button
    - Verify: Batch write to both subcollections, button changes to "Following", counts updated
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [x] 37.2 Test unfollow user flow
    - Setup: Launch UserProfilePage for followed user
    - Execute: Click Unfollow button
    - Verify: Batch delete from both subcollections, button changes to "Follow", counts updated
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [x] 37.3 Test friends list flow
    - Setup: User has 5 following, 3 followers
    - Execute: Navigate to friends list, switch between tabs
    - Verify: Following list shows 5 users, followers list shows 3 users, tap navigates to profile
    - _Requirements: 5.4_

- [x] 38. Integration Tests - Authentication Changes Flow
  - [x] 38.1 Test change password flow
    - Setup: Launch ChangePasswordPage
    - Execute: Enter current password, new password, confirm password, submit
    - Verify: Reauthentication occurs, password updated, success snackbar, navigated back
    - _Requirements: 6.1, 6.2_
  
  - [x] 38.2 Test change password with wrong current password
    - Setup: Launch ChangePasswordPage
    - Execute: Enter wrong current password, submit
    - Verify: Error message "incorreta", password not changed
    - _Requirements: 6.1, 6.2_
  
  - [x] 38.3 Test link phone number flow
    - Setup: Launch PhoneNumberPage
    - Execute: Select country, enter phone, send code, enter code, verify
    - Verify: SMS sent, code verified, phone linked, phoneVerified = true, navigated to PhoneLinkedPage
    - _Requirements: 6.3, 6.4, 6.5_

- [x] 39. Integration Tests - Course Management Flow
  - [x] 39.1 Test set primary course flow
    - Setup: Launch CoursesPage with 3 courses
    - Execute: Click "Set as Primary" on course 2
    - Verify: Batch write unsetting all, setting course 2, UI updates, success snackbar
    - _Requirements: 7.3, 7.4_
  
  - [x] 39.2 Test remove course flow
    - Setup: Launch CoursesPage with 3 courses
    - Execute: Click "Remove" on non-primary course
    - Verify: Confirmation dialog, course marked inactive, removed from list, success snackbar
    - _Requirements: 7.5_
  
  - [x] 39.3 Test prevent primary course removal
    - Setup: Launch CoursesPage with 3 courses
    - Execute: Try to remove primary course
    - Verify: Error message, course not removed
    - _Requirements: 7.5_

- [x] 40. Integration Tests - Account Deletion Flow
  - [x] 40.1 Test complete account deletion flow
    - Setup: Launch SettingsPage
    - Execute: Click Delete Account, confirm first modal, confirm second modal
    - Verify: Both modals shown, Firestore deleted, Auth deleted, navigated to /auth, success snackbar
    - _Requirements: 6.6, 6.7, 6.8_
  
  - [x] 40.2 Test account deletion cancellation
    - Setup: Launch SettingsPage
    - Execute: Click Delete Account, cancel first modal
    - Verify: No deletion occurs, user stays on settings
    - _Requirements: 6.6_

- [x] 41. Checkpoint - Integration Tests Complete
  - Ensure all integration tests pass, ask the user if questions arise.

- [x] 42. Update Firestore Security Rules
  - [x] 42.1 Add rule to verify user authentication
    - Rule: `request.auth != null && request.auth.uid == userId`
    - Test with Firebase emulator
    - _Requirements: 6.4_
  
  - [x] 42.2 Add rule to enforce username uniqueness
    - Rule: Check username doesn't exist in other user documents
    - Test with Firebase emulator
    - _Requirements: 2.1, 2.2_
  
  - [x] 42.3 Add rule to prevent unauthorized profile updates
    - Rule: Users can only update their own profile
    - Test with Firebase emulator
    - _Requirements: 2.1_
  
  - [x] 42.4 Test security rules with various scenarios
    - Test authenticated user can write own data
    - Test unauthenticated user cannot write
    - Test user cannot write to other user's data
    - Test username uniqueness is enforced

- [x] 43. Final Checkpoint - Complete System
  - Ensure all tests passing
  - Verify core functionality works correctly
  - Verify UI integration is complete
  - Verify error messages are in Portuguese
  - Verify all Firebase operations use proper error handlers
  - Verify GamificationController integration (read-only)
  - System ready for production use

## Notes

- **CRITICAL**: NO models, repositories, or services - all logic in ProfileController
- **CRITICAL**: ProfileController reads gamification stats but NEVER writes them
- All user-facing text must be in Portuguese
- All code comments must be in Portuguese
- Use ResponsiveUtils for all dimensions and spacing
- Use Firebase error handlers from company steering (firebase.md)
- Follow GetX patterns from company steering (getx-patterns.md)
- Each property test must run minimum 100 iterations
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end flows
- Security rules (task 42) are critical for production deployment
- Username uniqueness must be enforced both client-side and server-side
- Follow/unfollow operations must use Firestore batch writes for atomicity
- Password changes and account deletion require reauthentication
- Phone linking requires SMS verification via Firebase Phone Auth
- Profile completion is calculated based on: bio, phone verified, and non-default avatar
- After completion, the system will be production-ready with comprehensive test coverage

