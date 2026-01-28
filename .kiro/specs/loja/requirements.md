# Shop System - Requirements

## Overview

The Shop System enables users to purchase in-game items and boosts using gems (virtual currency). The system integrates with the existing GamificationController and provides a seamless purchasing experience through the existing UI.

---

## User Stories

### US-1: View Shop Items
**As a** user  
**I want to** view available shop items with their prices and descriptions  
**So that** I can decide what to purchase

**Acceptance Criteria:**
- 1.1: Shop page displays current gem balance in the app bar
- 1.2: Learning boosts section shows 4 items: Energy Refill (100 gems), XP Booster (150 gems), Gem Multiplier (200 gems), Streak Freeze (200 gems)
- 1.3: Each boost item displays icon, title, description, and gem price
- 1.4: Active boosts show visual indicator (badge or different styling)
- 1.5: Gem balance updates reactively when purchases are made

### US-2: Purchase Energy Refill
**As a** user  
**I want to** purchase energy refill for 100 gems  
**So that** I can continue playing lessons immediately

**Acceptance Criteria:**
- 2.1: Tapping Energy Refill item validates sufficient gem balance
- 2.2: If insufficient gems, error message shows exact amount needed
- 2.3: If sufficient gems, 100 gems are deducted and 5 energy is added (capped at max 5)
- 2.4: Success message displays new energy count
- 2.5: Purchase is saved to Firestore atomically
- 2.6: On error, changes are reverted and error message is shown

### US-3: Purchase XP Booster
**As a** user  
**I want to** purchase XP booster for 150 gems  
**So that** I can earn double XP for 1 hour

**Acceptance Criteria:**
- 3.1: Tapping XP Booster validates sufficient gems and no active booster
- 3.2: If booster already active, error message indicates this
- 3.3: If sufficient gems, 150 gems are deducted and booster activates for 1 hour
- 3.4: Booster expiration time is stored in Firestore
- 3.5: Success message confirms activation
- 3.6: Active booster is indicated in UI

### US-4: Purchase Gem Multiplier
**As a** user  
**I want to** purchase gem multiplier for 200 gems  
**So that** I can earn double gems for 1 hour

**Acceptance Criteria:**
- 4.1: Tapping Gem Multiplier validates sufficient gems and no active multiplier
- 4.2: If multiplier already active, error message indicates this
- 4.3: If sufficient gems, 200 gems are deducted and multiplier activates for 1 hour
- 4.4: Multiplier expiration time is stored in Firestore
- 4.5: Success message confirms activation
- 4.6: Active multiplier is indicated in UI

### US-5: Purchase Streak Freeze
**As a** user  
**I want to** purchase streak freeze for 200 gems  
**So that** I can protect my streak for 1 day

**Acceptance Criteria:**
- 5.1: Tapping Streak Freeze validates sufficient gems and no active freeze
- 5.2: If freeze already available, error message indicates this
- 5.3: If sufficient gems, 200 gems are deducted and freeze becomes available
- 5.4: Freeze availability is stored in Firestore
- 5.5: Success message confirms activation
- 5.6: Available freeze is indicated in UI

### US-6: Handle Purchase Errors
**As a** user  
**I want to** receive clear error messages when purchases fail  
**So that** I understand what went wrong and can retry

**Acceptance Criteria:**
- 6.1: Insufficient gems shows message: "Você precisa de X gemas a mais."
- 6.2: Already active boost shows message: "Você já tem um [item] ativo."
- 6.3: Network errors show user-friendly message
- 6.4: Authentication errors prompt re-login
- 6.5: All errors are displayed via snackbar with red background
- 6.6: Failed purchases revert all state changes

### US-7: Display Active Boosts
**As a** user  
**I want to** see which boosts are currently active  
**So that** I don't purchase duplicates

**Acceptance Criteria:**
- 7.1: Active XP Booster shows badge or visual indicator
- 7.2: Active Gem Multiplier shows badge or visual indicator
- 7.3: Available Streak Freeze shows badge or visual indicator
- 7.4: Boost expiration times are checked on page load
- 7.5: Expired boosts are automatically cleared

---

## Non-Functional Requirements

### Performance
- NFR-1: Purchase operations complete within 3 seconds under normal network conditions
- NFR-2: UI updates are reactive and immediate after successful purchase
- NFR-3: Firestore operations use retry logic with exponential backoff

### Reliability
- NFR-4: All purchase operations are atomic (all-or-nothing)
- NFR-5: Failed purchases automatically revert state changes
- NFR-6: Network timeouts are handled gracefully with 30-second limit

### Usability
- NFR-7: Error messages are in Portuguese and user-friendly
- NFR-8: Success messages are clear and confirm the action taken
- NFR-9: Loading states prevent duplicate purchases

### Security
- NFR-10: User authentication is verified before all purchases
- NFR-11: Gem balance validation happens server-side (Firestore rules)
- NFR-12: No sensitive data is logged

---

## Technical Constraints

- TC-1: Must use existing GamificationController for all gem and boost operations
- TC-2: No models, repositories, or services - logic stays in controller
- TC-3: Must follow GetX patterns (`.obs`, `Obx()`, simple validators)
- TC-4: Must integrate with existing UI without modifications
- TC-5: Must use Firebase error handlers from steering rules
- TC-6: All dates must use Firestore Timestamp conversion helpers

---

## Dependencies

- Existing GamificationController with purchase methods
- Firebase Firestore for data persistence
- Firebase Auth for user authentication
- GetX for state management
- Existing UI widgets (BoostItem, ShopItemCard, etc.)

---

## Out of Scope

- In-App Purchases (IAP) for real money
- Special offers with time-limited discounts
- Collectibles and customization items
- Purchase history tracking
- Refund functionality
- Gift/transfer gems to other users
