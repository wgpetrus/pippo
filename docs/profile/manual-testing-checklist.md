# Profile Logic - Manual Testing Checklist

> **Status:** Task 16 - UI Integration Complete Checkpoint
> 
> **Date:** 2026-01-30
>
> **Purpose:** Verify all profile pages, buttons, forms, loading states, and error messages work correctly

---

## Overview

This checklist covers manual testing of all 11 profile pages and their integration with ProfileController. All tasks 1-15 have been completed, and the controller is fully implemented with all methods, validators, and error handlers.

---

## Pre-Testing Setup

### Required Test Data

Before testing, ensure you have:

- [ ] Firebase project configured with Authentication and Firestore
- [ ] At least 2 test user accounts (for social features testing)
- [ ] Test user with complete profile data
- [ ] Test user with incomplete profile data
- [ ] Test courses data in Firestore

### Firebase Emulator (Optional but Recommended)

```bash
# Start Firebase emulators for safe testing
firebase emulators:start
```

---

## 1. Profile Page (Tab 4) - View Own Profile

**Location:** `lib/features/inners/profile/views/profile_page.dart`

### Test Cases

- [ ] **Load Profile Data**
  - Navigate to Profile tab
  - Verify profile loads automatically
  - Check loading indicator appears during load
  - Verify all fields display correctly:
    - Name
    - Username
    - Avatar
    - Bio
    - Country

- [ ] **Display Stats**
  - Verify Total XP displays correctly
  - Verify Current Streak displays correctly
  - Verify Lessons Completed displays correctly
  - Verify Level displays correctly
  - Check stats are read from GamificationController

- [ ] **Profile Completion**
  - If profile incomplete: Verify CompleteProfileCard shows
  - Verify completion percentage displays
  - Verify missing fields list is accurate
  - If profile complete: Verify card is hidden

- [ ] **Social Counts**
  - Verify Following count displays
  - Verify Followers count displays
  - Tap Following → should navigate to friends list
  - Tap Followers → should navigate to friends list

- [ ] **Settings Button**
  - Verify Settings button is visible in header
  - Tap Settings → should navigate to SettingsPage

- [ ] **Error Handling**
  - Test with no internet connection
  - Verify error message displays in Portuguese
  - Verify error message is user-friendly (no technical codes)

---

## 2. Edit Profile Page

**Location:** `lib/features/inners/profile/views/edit_profile_page.dart`

### Test Cases

- [ ] **Load Current Data**
  - Navigate to Edit Profile
  - Verify all fields pre-populate with current data:
    - Name
    - Username
    - Bio
    - Avatar
    - Country

- [ ] **Name Validation**
  - Clear name field → verify "Nome é obrigatório" error
  - Enter 1 character → verify "pelo menos 2 caracteres" error
  - Enter 51 characters → verify "no máximo 50 caracteres" error
  - Enter valid name → verify no error

- [ ] **Username Validation**
  - Clear username → verify "Nome de usuário é obrigatório" error
  - Enter 2 characters → verify "pelo menos 3 caracteres" error
  - Enter 21 characters → verify "no máximo 20 caracteres" error
  - Enter special characters (!, @, #) → verify "Use apenas letras, números e underscore" error
  - Enter valid username → verify no error

- [ ] **Username Availability Check**
  - Type new username
  - Wait 500ms (debounce)
  - Verify checking indicator appears
  - If available: Verify green checkmark or success indicator
  - If taken: Verify "Este nome de usuário já está em uso" error

- [ ] **Bio Validation**
  - Enter 151 characters → verify "no máximo 150 caracteres" error
  - Enter valid bio → verify no error

- [ ] **Avatar Selection**
  - Tap avatar → verify ChangeAvatarModal opens
  - Select new avatar → verify modal closes
  - Verify avatar updates in UI

- [ ] **Country Selection**
  - Tap country selector → verify CountrySelectorModal opens
  - Select new country → verify modal closes
  - Verify country updates in UI

- [ ] **Save Profile**
  - Make valid changes
  - Tap Save button
  - Verify loading indicator appears
  - Verify success snackbar: "Perfil atualizado com sucesso!"
  - Verify navigation back to ProfilePage
  - Verify changes persist on ProfilePage

- [ ] **Error Handling**
  - Try to save with invalid data → verify validation errors show
  - Test with no internet → verify error message in Portuguese
  - Try to save taken username → verify error message

---

## 3. User Profile Page - View Another User

**Location:** `lib/features/inners/profile/views/user_profile_page.dart`

### Test Cases

- [ ] **Load User Profile**
  - Navigate to another user's profile
  - Verify loading indicator appears
  - Verify user data displays:
    - Name
    - Username
    - Avatar
    - Bio
    - Stats (XP, Streak, Level)

- [ ] **Follow Status**
  - If not following: Verify "Follow" button shows
  - If following: Verify "Following" button shows
  - Verify follow status loads correctly

- [ ] **Follow User**
  - Tap Follow button
  - Verify loading indicator appears
  - Verify success snackbar: "Você está seguindo este usuário!"
  - Verify button changes to "Following"
  - Verify following count increments

- [ ] **Unfollow User**
  - Tap Following button
  - Verify loading indicator appears
  - Verify success snackbar: "Você deixou de seguir este usuário."
  - Verify button changes to "Follow"
  - Verify following count decrements

- [ ] **Privacy**
  - Verify private data NOT displayed:
    - Gems
    - Energy
    - Settings button
    - Complete Profile card

- [ ] **Error Handling**
  - Test with invalid user ID → verify "Usuário não encontrado" error
  - Test follow with no internet → verify error message

---

## 4. Settings Page

**Location:** `lib/features/inners/profile/views/settings_page.dart`

### Test Cases

- [ ] **Navigation**
  - Verify all menu items are clickable:
    - Profile
    - Notifications
    - Learning Controls
    - Courses
    - Change Password
    - Phone Number
    - Delete Account

- [ ] **Profile Navigation**
  - Tap Profile → verify navigates to EditProfilePage

- [ ] **Notifications Navigation**
  - Tap Notifications → verify navigates to NotificationsPage

- [ ] **Learning Controls Navigation**
  - Tap Learning Controls → verify navigates to LearningControlsPage

- [ ] **Courses Navigation**
  - Tap Courses → verify navigates to CoursesPage

- [ ] **Change Password Navigation**
  - Tap Change Password → verify navigates to ChangePasswordPage

- [ ] **Phone Number Navigation**
  - Tap Phone Number → verify navigates to PhoneNumberPage

- [ ] **Delete Account**
  - Tap Delete Account → verify DeleteAccountModal opens
  - Verify modal is styled in red (danger zone)

---

## 5. Notifications Page

**Location:** `lib/features/inners/profile/views/notifications_page.dart`

### Test Cases

- [ ] **Load Settings**
  - Navigate to Notifications
  - Verify loading indicator appears
  - Verify all settings load with correct values:
    - Practice Reminders (toggle)
    - Reminder Time (time selector)
    - Leaderboard Updates (toggle)
    - Friend Activity (toggle)

- [ ] **Practice Reminders Toggle**
  - Toggle Practice Reminders ON
  - Verify setting saves immediately
  - Verify Reminder Time becomes enabled
  - Toggle Practice Reminders OFF
  - Verify Reminder Time becomes disabled

- [ ] **Reminder Time Selection**
  - Tap Reminder Time
  - Verify ReminderTimeModal opens
  - Select new time
  - Verify modal closes
  - Verify time updates in UI
  - Verify setting saves to Firestore

- [ ] **Leaderboard Updates Toggle**
  - Toggle ON → verify saves
  - Toggle OFF → verify saves
  - Verify no loading delay (immediate update)

- [ ] **Friend Activity Toggle**
  - Toggle ON → verify saves
  - Toggle OFF → verify saves
  - Verify no loading delay (immediate update)

- [ ] **Error Handling**
  - Test with no internet → verify error message
  - Verify error message in Portuguese

---

## 6. Learning Controls Page

**Location:** `lib/features/inners/profile/views/learning_controls_page.dart`

### Test Cases

- [ ] **Load Settings**
  - Navigate to Learning Controls
  - Verify all settings load:
    - Sound Effects (toggle)
    - Listening Exercises (toggle)
    - Speaking Exercises (toggle)
    - Daily Goal (selector)

- [ ] **Sound Effects Toggle**
  - Toggle ON → verify saves
  - Toggle OFF → verify saves

- [ ] **Listening Exercises Toggle**
  - Toggle ON → verify saves
  - Toggle OFF → verify saves

- [ ] **Speaking Exercises Toggle**
  - Toggle ON → verify saves
  - Toggle OFF → verify saves

- [ ] **Daily Goal Selection**
  - Tap Daily Goal
  - Verify modal opens with options (5, 10, 15, 20 minutes)
  - Select new goal
  - Verify modal closes
  - Verify goal updates in UI
  - Verify setting saves to Firestore

- [ ] **Error Handling**
  - Test with no internet → verify error message

---

## 7. Courses Page

**Location:** `lib/features/inners/profile/views/courses_page.dart`

### Test Cases

- [ ] **Load Courses**
  - Navigate to Courses
  - Verify loading indicator appears
  - Verify all active courses display
  - Verify primary course is highlighted
  - Verify course data displays:
    - Language name
    - Flag
    - Progress
    - isPrimary indicator

- [ ] **Set Primary Course**
  - Tap "Set as Primary" on non-primary course
  - Verify loading indicator appears
  - Verify success snackbar: "Curso principal atualizado!"
  - Verify course becomes highlighted as primary
  - Verify previous primary course is no longer highlighted

- [ ] **Remove Course**
  - Tap "Remove" on non-primary course
  - Verify confirmation dialog appears
  - Confirm removal
  - Verify loading indicator appears
  - Verify success snackbar: "Curso removido!"
  - Verify course disappears from list

- [ ] **Prevent Primary Course Removal**
  - Try to remove primary course
  - Verify error message: "Não é possível remover o curso principal..."
  - Verify course is NOT removed

- [ ] **Add Course Button**
  - Tap "Add Course" button
  - Verify navigates to simplified onboarding flow

- [ ] **Error Handling**
  - Test with no internet → verify error message
  - Test with no courses → verify empty state

---

## 8. Change Password Page

**Location:** `lib/features/inners/profile/views/change_password_page.dart`

### Test Cases

- [ ] **Form Validation**
  - Leave Current Password empty → verify "Senha atual é obrigatória" error
  - Leave New Password empty → verify "Nova senha é obrigatória" error
  - Enter New Password < 6 chars → verify "pelo menos 6 caracteres" error
  - Leave Confirm Password empty → verify "Confirmação de senha é obrigatória" error
  - Enter mismatched passwords → verify "As senhas não coincidem" error

- [ ] **Change Password Success**
  - Enter correct current password
  - Enter valid new password (6+ chars)
  - Enter matching confirm password
  - Tap "Update Password"
  - Verify loading indicator appears
  - Verify success snackbar: "Senha alterada com sucesso!"
  - Verify navigation back to Settings

- [ ] **Wrong Current Password**
  - Enter wrong current password
  - Enter valid new password
  - Tap "Update Password"
  - Verify error message: "Senha incorreta. Verifique e tente novamente."
  - Verify password is NOT changed

- [ ] **Error Handling**
  - Test with no internet → verify error message
  - Verify all error messages in Portuguese

---

## 9. Phone Number Page

**Location:** `lib/features/inners/profile/views/phone_number_page.dart`

### Test Cases

- [ ] **Country Code Selection**
  - Tap country code selector
  - Verify CountrySelectorModal opens
  - Select country
  - Verify modal closes
  - Verify country code updates

- [ ] **Phone Number Input**
  - Enter phone number
  - Verify formatting mask applies (if implemented)
  - Verify input accepts only digits

- [ ] **Phone Number Validation**
  - Leave empty → verify "Número de telefone é obrigatório" error
  - Enter < 10 digits → verify "Número de telefone inválido" error
  - Enter > 15 digits → verify "Número de telefone inválido" error
  - Enter valid phone → verify no error

- [ ] **Send Code**
  - Enter valid phone number
  - Tap "Send Code"
  - Verify loading indicator appears
  - Verify SMS is sent (check phone)
  - Verify navigation to VerifyPhonePage

- [ ] **Error Handling**
  - Test with invalid phone → verify error message
  - Test with no internet → verify error message

---

## 10. Verify Phone Page

**Location:** `lib/features/inners/profile/views/verify_phone_page.dart`

### Test Cases

- [ ] **Display Phone Number**
  - Verify phone number displays (partially masked)
  - Example: "+55 (11) ***-**99"

- [ ] **Code Input**
  - Verify AppPinput displays 6 boxes
  - Enter 6-digit code
  - Verify each digit displays in separate box

- [ ] **Resend Code**
  - Verify AppResendCode displays countdown (60s)
  - Wait for countdown to finish
  - Tap "Resend Code"
  - Verify new SMS is sent
  - Verify countdown resets to 60s

- [ ] **Verify Code Success**
  - Enter correct 6-digit code
  - Tap "Verify"
  - Verify loading indicator appears
  - Verify success snackbar: "Telefone vinculado com sucesso!"
  - Verify navigation to PhoneLinkedPage

- [ ] **Invalid Code**
  - Enter wrong 6-digit code
  - Tap "Verify"
  - Verify error message: "Código de verificação inválido"
  - Verify phone is NOT linked

- [ ] **Error Handling**
  - Test with no internet → verify error message
  - Test with expired code → verify error message

---

## 11. Phone Linked Page

**Location:** `lib/features/inners/profile/views/phone_linked_page.dart`

### Test Cases

- [ ] **Success Display**
  - Verify success icon displays
  - Verify title: "Phone Linked!" (or Portuguese equivalent)
  - Verify confirmation message displays

- [ ] **Done Button**
  - Tap "Done" button
  - Verify navigation back to Settings or Profile

---

## 12. Delete Account Flow

**Modals:** `delete_account_modal.dart`, `confirm_delete_modal.dart`

### Test Cases

- [ ] **First Confirmation Modal**
  - From Settings, tap "Delete Account"
  - Verify DeleteAccountModal opens
  - Verify warning message displays
  - Verify consequences are explained
  - Tap "Cancel" → verify modal closes, no deletion
  - Tap "Delete" → verify ConfirmDeleteModal opens

- [ ] **Second Confirmation Modal**
  - Verify ConfirmDeleteModal opens
  - Verify final warning displays
  - Verify "This action cannot be undone" message
  - Tap "Cancel" → verify modal closes, no deletion
  - Tap "Confirm Delete" → verify deletion proceeds

- [ ] **Account Deletion Success**
  - Confirm deletion in both modals
  - Verify loading indicator appears
  - Verify Firestore document is deleted
  - Verify Firebase Auth account is deleted
  - Verify navigation to /auth
  - Verify success snackbar: "Sua conta foi excluída permanentemente."

- [ ] **Requires Recent Login**
  - Try to delete account after being logged in for a while
  - Verify error message: "Por segurança, faça login novamente..."
  - Verify reauthentication flow triggers (if implemented)

- [ ] **Error Handling**
  - Test with no internet → verify error message
  - Verify all error messages in Portuguese

---

## 13. Loading States

### Test All Pages

For each page, verify:

- [ ] **ProfilePage**
  - Loading indicator shows during `loadOwnProfile()`
  - Content hidden while loading
  - Loading indicator disappears when data loads

- [ ] **EditProfilePage**
  - Save button shows loading during `updateProfile()`
  - Username availability check shows loading indicator
  - Form disabled during save

- [ ] **UserProfilePage**
  - Loading indicator shows during `loadUserProfile()`
  - Follow/Unfollow button shows loading during operation

- [ ] **SettingsPage**
  - Loading indicator shows during `loadSettings()`

- [ ] **CoursesPage**
  - Loading indicator shows during `loadUserCourses()`
  - Set Primary button shows loading
  - Remove button shows loading

- [ ] **ChangePasswordPage**
  - Update Password button shows loading
  - Form disabled during operation

- [ ] **VerifyPhonePage**
  - Verify button shows loading
  - Form disabled during verification

- [ ] **DeleteAccount**
  - Confirm Delete button shows loading
  - Modals disabled during deletion

---

## 14. Error Messages

### Verify All Error Messages

For each error scenario, verify:

- [ ] **Error messages are in Portuguese**
  - No English error messages
  - No technical jargon

- [ ] **Error messages are user-friendly**
  - No Firebase error codes exposed
  - No stack traces shown
  - Clear, actionable messages

- [ ] **Error messages display correctly**
  - Visible to user
  - Properly formatted
  - Dismissible (if snackbar)

### Common Error Scenarios

- [ ] **No Internet Connection**
  - Verify: "Verifique sua conexão com a internet."

- [ ] **Unauthenticated**
  - Verify: "Usuário não autenticado. Faça login novamente."

- [ ] **Permission Denied**
  - Verify: "Erro de permissão. Verifique as configurações..."

- [ ] **Resource Not Found**
  - Verify: "Recurso não encontrado."

- [ ] **Too Many Requests**
  - Verify: "Muitas tentativas. Aguarde alguns minutos..."

---

## 15. Reactive State Updates

### Test Obx() Reactivity

- [ ] **Profile Stats**
  - Change XP in GamificationController
  - Verify ProfilePage updates automatically
  - No manual refresh needed

- [ ] **Username Availability**
  - Type in username field
  - Verify availability indicator updates automatically
  - Verify error message appears/disappears reactively

- [ ] **Loading States**
  - Verify loading indicators appear/disappear automatically
  - No manual state management needed

- [ ] **Error Messages**
  - Verify error messages appear automatically
  - Verify error messages clear automatically on success

- [ ] **Social Counts**
  - Follow a user
  - Verify following count increments immediately
  - Unfollow a user
  - Verify following count decrements immediately

---

## 16. Integration with Other Controllers

### GamificationController Integration

- [ ] **Read-Only Access**
  - Verify ProfileController reads stats from GamificationController
  - Verify ProfileController NEVER writes to gamification stats
  - Verify stats display correctly on ProfilePage

### HomeController Integration

- [ ] **Tab Navigation**
  - Navigate to Profile tab from Home
  - Verify profile loads automatically
  - Navigate away and back
  - Verify profile refreshes

---

## 17. Edge Cases

### Test Edge Cases

- [ ] **Empty Profile**
  - User with no bio, no phone, default avatar
  - Verify CompleteProfileCard shows
  - Verify completion percentage is low

- [ ] **Complete Profile**
  - User with all fields filled
  - Verify CompleteProfileCard is hidden
  - Verify completion percentage is 100%

- [ ] **No Courses**
  - User with no active courses
  - Verify empty state displays
  - Verify "Add Course" button works

- [ ] **Single Course**
  - User with only one course
  - Verify cannot remove primary course
  - Verify error message displays

- [ ] **Self-Follow Prevention**
  - Try to follow own profile
  - Verify error message: "Você não pode seguir a si mesmo."

- [ ] **Username Already Taken**
  - Try to save username that another user has
  - Verify error message displays
  - Verify save fails

---

## 18. Performance

### Test Performance

- [ ] **Username Availability Check**
  - Type quickly in username field
  - Verify debounce works (only checks after 500ms pause)
  - Verify not checking on every keystroke

- [ ] **Profile Load Time**
  - Measure time to load profile
  - Should be < 2 seconds on good connection

- [ ] **Settings Save Time**
  - Toggle a setting
  - Should save < 1 second

- [ ] **Follow/Unfollow Time**
  - Follow a user
  - Should complete < 1 second

---

## 19. Accessibility

### Test Accessibility

- [ ] **Text Scaling**
  - Increase device text size
  - Verify all text scales correctly
  - Verify no text overflow

- [ ] **Screen Reader**
  - Enable screen reader (TalkBack/VoiceOver)
  - Verify all buttons are labeled
  - Verify all form fields are labeled

- [ ] **Color Contrast**
  - Verify text is readable
  - Verify error messages are visible

---

## 20. Final Verification

### Complete System Check

- [ ] All 11 profile pages load correctly
- [ ] All buttons work as expected
- [ ] All forms validate correctly
- [ ] All loading states display properly
- [ ] All error messages display in Portuguese
- [ ] All error messages are user-friendly
- [ ] All reactive states update automatically
- [ ] No console errors or warnings
- [ ] No crashes or freezes
- [ ] ProfileController never writes to gamification stats
- [ ] All Firebase operations use proper error handlers

---

## Testing Notes

### Issues Found

Document any issues found during testing:

1. **Issue:** [Description]
   - **Page:** [Page name]
   - **Steps to Reproduce:** [Steps]
   - **Expected:** [Expected behavior]
   - **Actual:** [Actual behavior]
   - **Severity:** [Critical/High/Medium/Low]

2. **Issue:** [Description]
   - ...

### Test Environment

- **Device:** [Device name/model]
- **OS Version:** [iOS/Android version]
- **Flutter Version:** [Flutter version]
- **Firebase Project:** [Project ID]
- **Test Date:** [Date]
- **Tester:** [Name]

---

## Completion Criteria

Task 16 is complete when:

- ✅ All 11 profile pages have been tested manually
- ✅ All buttons and forms work correctly
- ✅ All loading states display properly
- ✅ All error messages display properly in Portuguese
- ✅ All error messages are user-friendly (no technical codes)
- ✅ All reactive states update automatically
- ✅ No critical or high-severity issues found
- ✅ User confirms testing is complete

---

## Next Steps

After completing this checkpoint:

1. **If issues found:** Fix issues and re-test
2. **If all tests pass:** Mark task 16 as complete
3. **Proceed to:** Task 17 - Unit Tests (Profile Management)

