# Profile Feature - Requirements

## Overview

The Profile feature manages user profile data, settings, social interactions, and course management. It integrates with Firebase Authentication and Firestore to provide a complete user profile experience with social features, multi-course support, and comprehensive settings management.

**Note**: The UI is already fully implemented and matches the Figma design. This specification focuses exclusively on business logic, state management, and data flow.

---

## User Stories

### US-1: View Own Profile
**As a** user  
**I want to** view my profile with stats and progress  
**So that** I can track my learning journey

**Acceptance Criteria:**
- AC-1.1: Profile displays user's name, username, avatar, and bio
- AC-1.2: Profile shows following/followers counts
- AC-1.3: Profile displays active courses with flags
- AC-1.4: Profile shows weekly XP chart with 7 days of data
- AC-1.5: Profile displays overview cards (Total XP, Current Streak, Lessons Completed, Time Spent)
- AC-1.6: "Complete Profile" card appears if profile is incomplete (missing bio, phone, or using default avatar)
- AC-1.7: Settings button is visible in header
- AC-1.8: Stats are loaded from GamificationController reactively

### US-2: View Other User's Profile
**As a** user  
**I want to** view another user's profile  
**So that** I can see their progress and follow them

**Acceptance Criteria:**
- AC-2.1: Profile displays target user's public information (name, username, avatar, bio)
- AC-2.2: Profile shows following/followers counts
- AC-2.3: Profile displays active courses
- AC-2.4: Weekly XP chart shows comparison between current user and target user
- AC-2.5: Follow/Following button is displayed based on relationship status
- AC-2.6: Private data (gems, energy) is NOT displayed
- AC-2.7: Settings button is NOT displayed
- AC-2.8: "Complete Profile" card is NOT displayed

### US-3: Edit Profile
**As a** user  
**I want to** edit my profile information  
**So that** I can keep my profile up to date

**Acceptance Criteria:**
- AC-3.1: User can change name (2-50 characters)
- AC-3.2: User can change username (3+ characters, alphanumeric + underscore only)
- AC-3.3: Username uniqueness is validated before saving
- AC-3.4: User can change bio (max 150 characters)
- AC-3.5: User can change avatar from available options
- AC-3.6: User can change country
- AC-3.7: Changes are saved to Firestore with updatedAt timestamp
- AC-3.8: Success message is displayed after saving
- AC-3.9: User is navigated back to profile after successful save
- AC-3.10: Validation errors are displayed inline

### US-4: Change Avatar
**As a** user  
**I want to** change my avatar  
**So that** I can personalize my profile

**Acceptance Criteria:**
- AC-4.1: Modal displays all available avatars
- AC-4.2: Current avatar is highlighted
- AC-4.3: User can select a new avatar
- AC-4.4: Avatar is updated immediately in UI
- AC-4.5: Avatar change is saved to Firestore
- AC-4.6: Modal closes after selection

### US-5: Manage Settings
**As a** user  
**I want to** manage my app settings  
**So that** I can customize my experience

**Acceptance Criteria:**
- AC-5.1: User can toggle sound effects on/off
- AC-5.2: User can toggle listening exercises on/off
- AC-5.3: User can toggle speaking exercises on/off
- AC-5.4: User can toggle practice reminders on/off
- AC-5.5: User can set reminder time (when reminders are enabled)
- AC-5.6: User can toggle leaderboard updates on/off
- AC-5.7: User can toggle friend activity notifications on/off
- AC-5.8: Settings are saved to Firestore immediately on change
- AC-5.9: Settings are loaded from Firestore on page load

### US-6: Change Password
**As a** user  
**I want to** change my password  
**So that** I can maintain account security

**Acceptance Criteria:**
- AC-6.1: User must enter current password
- AC-6.2: User must enter new password (min 6 characters)
- AC-6.3: User must confirm new password
- AC-6.4: Current password is validated via Firebase reauthentication
- AC-6.5: New password and confirmation must match
- AC-6.6: Password is updated via Firebase Auth
- AC-6.7: Success message is displayed
- AC-6.8: User is navigated back to settings
- AC-6.9: Appropriate error messages for wrong current password or validation failures

### US-7: Link Phone Number
**As a** user  
**I want to** link my phone number  
**So that** I can recover my account and complete my profile

**Acceptance Criteria:**
- AC-7.1: User can select country code
- AC-7.2: User can enter phone number with formatting mask
- AC-7.3: Phone number is validated before sending code
- AC-7.4: SMS verification code is sent via Firebase Phone Auth
- AC-7.5: User can enter 6-digit verification code
- AC-7.6: User can resend code after 60 seconds
- AC-7.7: Code is validated and phone is linked to account
- AC-7.8: Phone number is saved to Firestore with verified flag
- AC-7.9: Success screen is displayed after linking
- AC-7.10: User is navigated back to settings

### US-8: Delete Account
**As a** user  
**I want to** delete my account  
**So that** I can remove all my data from the platform

**Acceptance Criteria:**
- AC-8.1: User must confirm deletion in first modal
- AC-8.2: User must confirm again in final confirmation modal
- AC-8.3: All user data is deleted from Firestore (user document and subcollections)
- AC-8.4: User account is deleted from Firebase Auth
- AC-8.5: Local data is cleared (SharedPreferences)
- AC-8.6: User is navigated to auth screen
- AC-8.7: Deletion is irreversible
- AC-8.8: If user cancels at any step, no deletion occurs

### US-9: Follow/Unfollow Users
**As a** user  
**I want to** follow and unfollow other users  
**So that** I can track their progress

**Acceptance Criteria:**
- AC-9.1: User can follow another user from their profile
- AC-9.2: Following adds target user to current user's following list
- AC-9.3: Following adds current user to target user's followers list
- AC-9.4: Following increments both users' counts
- AC-9.5: User can unfollow a user they are following
- AC-9.6: Unfollowing removes from both lists and decrements counts
- AC-9.7: Follow button changes to "Following" when following
- AC-9.8: Follow status is checked on profile load
- AC-9.9: Follow/unfollow operations use Firestore batch writes
- AC-9.10: Optional: Follow notification is sent to target user

### US-10: Manage Courses
**As a** user  
**I want to** manage my active courses  
**So that** I can learn multiple languages

**Acceptance Criteria:**
- AC-10.1: User can view all their active courses
- AC-10.2: User can see progress for each course
- AC-10.3: User can set one course as primary
- AC-10.4: Only one course can be primary at a time
- AC-10.5: User can remove a course (with confirmation)
- AC-10.6: If primary course is removed, another course becomes primary automatically
- AC-10.7: User can add a new course via simplified onboarding flow
- AC-10.8: New course is created with Firestore auto-generated ID
- AC-10.9: Course list updates reactively

### US-11: View Friends List
**As a** user  
**I want to** view my following and followers lists  
**So that** I can manage my social connections

**Acceptance Criteria:**
- AC-11.1: User can view list of users they follow
- AC-11.2: User can view list of users who follow them
- AC-11.3: Each list item shows user's avatar, name, username, and XP
- AC-11.4: User can tap on a list item to view that user's profile
- AC-11.5: User can unfollow from the following list
- AC-11.6: Lists update reactively when follow status changes

### US-12: Complete Profile Tracking
**As a** user  
**I want to** see what's missing from my profile  
**So that** I can complete it

**Acceptance Criteria:**
- AC-12.1: Profile is considered complete when: bio is set, phone is verified, and avatar is not default
- AC-12.2: "Complete Profile" card shows number of steps remaining
- AC-12.3: Card is hidden when profile is complete
- AC-12.4: Tapping card navigates to edit profile page
- AC-12.5: Profile completion status is calculated reactively

---

## Functional Requirements

### FR-1: Profile Data Management
- FR-1.1: Load user profile data from Firestore on controller initialization
- FR-1.2: Update profile data in Firestore when changes are made
- FR-1.3: Maintain reactive state for all profile fields using GetX `.obs`
- FR-1.4: Handle loading and error states appropriately
- FR-1.5: Use Firebase Auth UID as user document ID
- FR-1.6: Work directly with Firestore documents as `Map<String, dynamic>` (no model classes)

### FR-2: Validation
- FR-2.1: Validate name: 2-50 characters, required
- FR-2.2: Validate username: 3+ characters, alphanumeric + underscore only, unique, required
- FR-2.3: Validate bio: max 150 characters, optional
- FR-2.4: Validate phone: valid format with country code
- FR-2.5: Validate password: min 6 characters
- FR-2.6: Validate password confirmation: must match new password

### FR-3: Settings Management
- FR-3.1: Load settings from Firestore subcollection on initialization
- FR-3.2: Save settings changes immediately to Firestore
- FR-3.3: Maintain reactive state for all settings
- FR-3.4: Create settings document if it doesn't exist

### FR-4: Social Features
- FR-4.1: Implement follow/unfollow with Firestore batch writes
- FR-4.2: Update following/followers arrays and counts atomically
- FR-4.3: Check follow status when viewing another user's profile
- FR-4.4: Load following/followers lists with pagination support
- FR-4.5: Maintain reactive state for follow status

### FR-5: Course Management
- FR-5.1: Load all user courses from Firestore subcollection
- FR-5.2: Calculate progress for each course
- FR-5.3: Set primary course with atomic operation (unset all others first)
- FR-5.4: Remove course with confirmation and handle primary course reassignment
- FR-5.5: Create new course with Firestore auto-generated ID
- FR-5.6: Maintain reactive state for course list

### FR-6: Authentication Operations
- FR-6.1: Reauthenticate user before password change
- FR-6.2: Update password via Firebase Auth
- FR-6.3: Link phone number via Firebase Phone Auth
- FR-6.4: Delete user account from Firebase Auth
- FR-6.5: Handle authentication errors appropriately

### FR-7: Data Deletion
- FR-7.1: Delete user document from Firestore
- FR-7.2: Delete all user subcollections (courses, stats, history, etc.)
- FR-7.3: Use Cloud Function for subcollection deletion if available
- FR-7.4: Clear local storage (SharedPreferences)
- FR-7.5: Navigate to auth screen after deletion

### FR-8: Statistics Integration
- FR-8.1: Integrate with GamificationController for stats display
- FR-8.2: Load weekly XP history for chart
- FR-8.3: Calculate total time spent from history
- FR-8.4: Display stats reactively using Obx

---

## Non-Functional Requirements

### NFR-1: Performance
- NFR-1.1: Profile data must load within 2 seconds
- NFR-1.2: Settings changes must save within 1 second
- NFR-1.3: Follow/unfollow operations must complete within 1 second
- NFR-1.4: Username uniqueness check must complete within 500ms

### NFR-2: Security
- NFR-2.1: Validate all user inputs before saving
- NFR-2.2: Reauthenticate before sensitive operations (password change, account deletion)
- NFR-2.3: Never expose private data (gems, energy) in other users' profiles
- NFR-2.4: Use Firestore security rules to protect user data

### NFR-3: Reliability
- NFR-3.1: Handle network errors gracefully with user-friendly messages
- NFR-3.2: Use Firestore batch writes for atomic operations
- NFR-3.3: Validate data before Firestore operations
- NFR-3.4: Implement proper error handling for all Firebase operations

### NFR-4: Usability
- NFR-4.1: Display loading indicators during async operations
- NFR-4.2: Show success messages after successful operations
- NFR-4.3: Display validation errors inline
- NFR-4.4: Provide clear confirmation dialogs for destructive actions

### NFR-5: Maintainability
- NFR-5.1: Follow project coding standards and patterns
- NFR-5.2: Use GetX for state management consistently
- NFR-5.3: Keep controllers focused on business logic only
- NFR-5.4: Document complex business rules in code comments
- NFR-5.5: **CRITICAL**: No model classes, repositories, or services - all logic in ProfileController
- NFR-5.6: Work directly with Firestore documents as `Map<String, dynamic>`

---

## Firestore Document Structures

**⚠️ CRITICAL**: No model classes, repositories, or services. Work directly with Firestore documents as `Map<String, dynamic>`.

### User Document (users/{userId})
```dart
// Firestore document structure (Map<String, dynamic>)
{
  'id': String,                    // Firebase Auth UID
  'email': String,
  'name': String,
  'username': String,              // Unique
  'avatarId': String,
  'bio': String?,
  'country': String,
  'phone': String?,
  'phoneVerified': bool,
  'createdAt': Timestamp,
  'updatedAt': Timestamp,
  'lastActiveAt': Timestamp,
  'onboardingCompleted': bool,
  'age': String,
  'following': List<String>,       // User IDs
  'followers': List<String>,       // User IDs
  'followingCount': int,
  'followersCount': int,
}
```

### Settings Document (users/{userId}/settings/preferences)
```dart
// Firestore document structure (Map<String, dynamic>)
{
  'soundEffects': bool,
  'listeningExercises': bool,
  'speakingExercises': bool,
  'practiceReminders': bool,
  'reminderTime': String,          // "HH:mm" format
  'leaderboardUpdates': bool,
  'friendActivity': bool,
}
```

### Course Document (users/{userId}/courses/{courseId})
```dart
// Firestore document structure (Map<String, dynamic>)
{
  'id': String,                    // Firestore auto-generated
  'languageCode': String,
  'languageName': String,
  'level': String,
  'learningReason': String,
  'dailyGoal': int,
  'currentUnitId': String,
  'currentLessonId': String,
  'totalXp': int,
  'lessonsCompleted': int,
  'startedAt': Timestamp,
  'lastPracticedAt': Timestamp,
  'isActive': bool,
  'isPrimary': bool,               // Only one can be true
}
```

---

## Business Rules

### BR-1: Username Uniqueness
- Usernames must be unique across all users
- Check Firestore before allowing username change
- Case-insensitive comparison

### BR-2: Primary Course
- Only one course can be primary at a time
- When setting a course as primary, unset all others first
- Use Firestore batch write for atomicity

### BR-3: Course Removal
- Confirm before removing a course
- If removing primary course, automatically set another course as primary
- If no courses remain, user must add a new course

### BR-4: Profile Completion
- Profile is complete when:
  - Bio is set and not empty
  - Phone is verified
  - Avatar is not default (not "avatar_01")

### BR-5: Follow/Unfollow
- Use Firestore batch writes for atomicity
- Update both users' following/followers arrays
- Update both users' counts
- Prevent following yourself

### BR-6: Account Deletion
- Require two confirmations
- Delete all user data (document and subcollections)
- Delete Firebase Auth account
- Clear local storage
- Navigate to auth screen

### BR-7: Password Change
- Require current password
- Reauthenticate before changing
- New password must be at least 6 characters
- Confirmation must match new password

### BR-8: Phone Verification
- Use Firebase Phone Auth
- Send SMS verification code
- Allow resend after 60 seconds
- Save phone with verified flag after successful verification

---

## Error Handling

### EH-1: Validation Errors
- Display inline validation errors
- Use Portuguese error messages
- Follow patterns from firebase.md steering rule

### EH-2: Network Errors
- Display user-friendly error messages
- Use error handlers from firebase.md
- Allow retry for failed operations

### EH-3: Authentication Errors
- Handle wrong password gracefully
- Handle account-not-found errors
- Handle too-many-requests errors
- Use Firebase error handlers from firebase.md

### EH-4: Firestore Errors
- Handle permission-denied errors
- Handle not-found errors
- Handle network errors
- Use Firestore error handlers from firebase.md

---

## Integration Points

### IP-1: GamificationController
- Read stats for profile display
- Use reactive state (Obx)
- Don't duplicate stat management

### IP-2: Firebase Auth
- Use current user UID
- Reauthenticate for sensitive operations
- Update password
- Link phone number
- Delete account

### IP-3: Firebase Firestore
- Read/write user document
- Read/write settings subcollection
- Read/write courses subcollection
- Query for username uniqueness
- Batch writes for atomic operations

### IP-4: OnboardingController
- Trigger simplified onboarding for new course
- Receive course data from onboarding
- Create course document

### IP-5: Navigation
- Navigate to settings pages
- Navigate to edit profile
- Navigate to friends list
- Navigate to other user profiles
- Navigate back after operations

---

## Success Metrics

- Profile load time < 2 seconds
- Settings save time < 1 second
- Follow/unfollow operation time < 1 second
- Username uniqueness check < 500ms
- Zero data loss during operations
- 100% error handling coverage
- User-friendly error messages in Portuguese
