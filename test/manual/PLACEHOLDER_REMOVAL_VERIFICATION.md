# Placeholder Removal Verification Guide

> **Task:** Verify placeholders removed when real data is implemented  
> **Requirement:** 5.2 - Clear Placeholders  
> **Status:** Verification checklist for future implementation

---

## Overview

This document provides a verification checklist to ensure that placeholder indicators are properly removed when real Firestore data replaces mock data in the application.

---

## Current Placeholder Locations

### 1. Leaderboard Page
**File:** `lib/features/inners/leaderboard/views/leaderboard_page.dart`

**Current State:**
- ✅ Mock data: `_players` list with hardcoded player data
- ✅ Placeholder banner: "🧪 Test data - Real leaderboard data will be loaded from Firestore"
- ✅ Code comment: `// TODO: Replace with real Firestore data from LeaderboardController`

**Verification Checklist:**
- [ ] LeaderboardController implemented with `loadStats()` method
- [ ] `loadStats()` fetches data from Firestore using current user's UID
- [ ] Placeholder banner removed from UI
- [ ] Mock `_players` list removed
- [ ] Real data displayed from controller observable
- [ ] Code comment removed

---

### 2. Friends View
**File:** `lib/features/inners/friends/views/friends_view.dart`

**Current State:**
- ✅ Mock data: `_friends` list with hardcoded friend data
- ✅ Placeholder banner: "🧪 Test data - Real friends data will be loaded from Firestore"
- ✅ Code comment: `// TODO: Replace with real Firestore data from FriendsController`

**Verification Checklist:**
- [ ] FriendsController implemented with `loadFriends()` method
- [ ] `loadFriends()` fetches data from Firestore using current user's UID
- [ ] Placeholder banner removed from UI
- [ ] Mock `_friends` list removed
- [ ] Real data displayed from controller observable
- [ ] Code comment removed

---

### 3. Courses Page
**File:** `lib/features/inners/profile/views/courses_page.dart`

**Current State:**
- ✅ Mock data: `_courses` list with hardcoded course data
- ✅ Code comment: `// TODO: Replace with real Firestore data from CoursesController`
- ⚠️ No placeholder banner (should be added for consistency)

**Verification Checklist:**
- [ ] CoursesController implemented with `loadCourses()` method
- [ ] `loadCourses()` fetches data from Firestore using current user's UID
- [ ] Mock `_courses` list removed
- [ ] Real data displayed from controller observable
- [ ] Code comment removed
- [ ] Placeholder banner added (if not already present)

---

## Verification Steps

### Step 1: Identify Real Data Implementation
When implementing real data loading for each feature:

1. Create/update the controller (e.g., `LeaderboardController`)
2. Implement data loading method (e.g., `loadStats()`)
3. Ensure method uses `FirebaseAuth.instance.currentUser?.uid`
4. Create observable for data (e.g., `stats.obs`)

### Step 2: Update View to Use Real Data
1. Replace mock data list with controller observable
2. Use `Obx()` to rebuild when data changes
3. Remove placeholder banner widget
4. Remove mock data list
5. Remove TODO comment

### Step 3: Verify Placeholder Removal
1. Run the app in debug mode
2. Navigate to each page (Leaderboard, Friends, Courses)
3. Verify no "🧪 Test data" banners are visible
4. Verify no mock data is displayed
5. Verify real Firestore data is loaded
6. Check code for any remaining TODO comments

### Step 4: Code Review
1. Search codebase for remaining "🧪" emoji
2. Search for "Test data" text in views
3. Search for "TODO: Replace with real Firestore data" comments
4. Verify all are removed

---

## Acceptance Criteria

✅ **All placeholders removed:**
- No "🧪 Test data" banners visible in UI
- No mock data lists in views
- No TODO comments about replacing mock data

✅ **Real data implemented:**
- Controllers load data from Firestore
- Data uses current user's UID
- Observable data properly displayed
- Loading states handled

✅ **Code quality:**
- No hardcoded test data in views
- No placeholder comments remaining
- Consistent error handling
- Proper null safety

---

## Testing Verification

### Manual Testing
1. Login with test account
2. Navigate to Leaderboard → verify real data or clear error message
3. Navigate to Friends → verify real data or clear error message
4. Navigate to Courses → verify real data or clear error message
5. Verify no placeholder banners appear

### Automated Testing
- Integration tests should verify real data is loaded
- Tests should mock Firestore to verify data binding
- Tests should verify placeholders are not present

---

## Files to Update

When implementing real data, update these files:

| File | Action |
|------|--------|
| `lib/features/inners/leaderboard/views/leaderboard_page.dart` | Remove mock data, placeholder banner, TODO comment |
| `lib/features/inners/friends/views/friends_view.dart` | Remove mock data, placeholder banner, TODO comment |
| `lib/features/inners/profile/views/courses_page.dart` | Remove mock data, TODO comment |
| `lib/features/inners/leaderboard/controllers/leaderboard_controller.dart` | Implement real data loading |
| `lib/features/inners/friends/controllers/friends_controller.dart` | Implement real data loading |
| `lib/features/inners/profile/controllers/profile_controller.dart` | Implement real data loading |

---

## Related Requirements

- **Requirement 5.1:** Individual User Data Loading
- **Requirement 5.2:** Clear Placeholders
- **Requirement 7.1:** Load User-Specific Data in Controllers

---

## Notes

- This is a **verification task** for future implementation
- Placeholders are intentionally kept during development
- Real data implementation will be done in a separate task
- This checklist ensures proper cleanup when real data is added

---

## Sign-Off

When all items in the verification checklist are complete:

- [ ] All placeholders removed from code
- [ ] All mock data replaced with real Firestore data
- [ ] All TODO comments removed
- [ ] Code review completed
- [ ] Manual testing passed
- [ ] Automated tests passing

**Verified by:** _______________  
**Date:** _______________  
**Notes:** _______________

