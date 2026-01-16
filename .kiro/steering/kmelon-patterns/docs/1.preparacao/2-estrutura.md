# Estrutura de Pastas - Pippo

> Estrutura completa do projeto

---

## Visão Geral

```
lib/
├── main.dart
├── assets/
├── features/
│   ├── core/
│   ├── inners/
│   └── borders/
└── shared/
```

---

## Assets

```
lib/assets/
├── fonts/
│   └── Nunito/
│       ├── Nunito-VariableFont_wght.ttf
│       └── Nunito-Italic-VariableFont_wght.ttf
└── images/
    ├── auth/           # Logos sociais (Google, Facebook)
    ├── backgrounds/    # Backgrounds e efeitos
    ├── characters/     # Personagens do app
    ├── flags/          # Bandeiras dos idiomas
    ├── icons/          # Ícones organizados por contexto
    ├── lesson/         # Imagens dos exercícios
    ├── logo/           # Logo do Pippo
    ├── onboarding/     # Mascotes e avatares
    └── profile/        # Imagens do perfil
```

---

## Features Core

```
lib/features/core/
├── auth/
│   ├── bindings/
│   │   └── auth_binding.dart
│   ├── controllers/
│   │   └── auth_controller.dart
│   ├── views/
│   │   ├── signin_view.dart
│   │   ├── forgot_password_view.dart
│   │   ├── verify_code_view.dart
│   │   └── new_password_view.dart
│   └── widgets/
│       └── social_button.dart
│
├── lesson/
│   ├── controllers/
│   │   └── .gitkeep
│   ├── views/
│   │   ├── sections_page.dart
│   │   ├── image_exercise_page.dart
│   │   ├── translation_exercise_page.dart
│   │   ├── word_exercise_page.dart
│   │   ├── match_exercise_page.dart
│   │   └── complete_page.dart
│   └── widgets/
│       ├── audio_card.dart
│       ├── audio_word_button.dart
│       ├── exercise_header.dart
│       ├── feedback_bottom_sheet.dart
│       ├── image_with_label.dart
│       ├── lesson_option_card.dart
│       ├── low_energy_modal.dart
│       ├── mascot_bubble.dart
│       ├── section_card.dart
│       ├── word_chip.dart
│       └── word_zone.dart
│
└── onboarding/
    ├── bindings/
    │   └── onboarding_binding.dart
    ├── controllers/
    │   └── onboarding_controller.dart
    ├── navigation/
    │   └── onboarding_navigation.dart
    ├── views/
    │   ├── welcome_view.dart
    │   ├── language_view/
    │   │   ├── select_language_page.dart
    │   │   ├── language_level_page.dart
    │   │   └── learning_reason_page.dart
    │   ├── time_view/
    │   │   └── study_time_page.dart
    │   ├── profile_view/
    │   │   ├── user_name_page.dart
    │   │   ├── user_age_page.dart
    │   │   ├── user_email_page.dart
    │   │   ├── user_password_page.dart
    │   │   └── verify_code_page.dart
    │   └── transitions_view/
    │       ├── intro_page.dart
    │       ├── pause_one_page.dart
    │       ├── pause_two_page.dart
    │       └── conclusion_page.dart
    └── widgets/
        ├── bouncing_mascot.dart
        ├── onboarding_header.dart
        ├── onboarding_text_field.dart
        ├── option_card.dart
        └── progress_bar.dart
```

---

## Features Inners

```
lib/features/inners/
├── splash/
│   ├── bindings/
│   │   └── splash_binding.dart
│   ├── controllers/
│   │   └── splash_controller.dart
│   └── views/
│       └── splash_view.dart
│
├── home/
│   ├── bindings/
│   │   └── home_binding.dart
│   ├── controllers/
│   │   └── home_controller.dart
│   ├── views/
│   │   └── home_view.dart
│   └── widgets/
│       ├── courses_modal.dart
│       ├── energy_modal.dart
│       ├── gems_modal.dart
│       ├── home_appbar.dart
│       ├── lesson_popover.dart
│       ├── lesson_tooltip.dart
│       ├── streak_modal.dart
│       └── unit_header.dart
│
├── leaderboard/
│   ├── controllers/
│   ├── views/
│   │   └── leaderboard_page.dart
│   └── widgets/
│       ├── leaderboard_header.dart
│       ├── league_info.dart
│       ├── league_selector.dart
│       ├── rank_item.dart
│       └── status_modal.dart
│
├── shop/
│   ├── controllers/
│   ├── views/
│   │   └── shop_page.dart
│   └── widgets/
│       ├── boost_item.dart
│       ├── collectible_item.dart
│       ├── section_title.dart
│       └── shop_item_card.dart
│
├── treasure/
│   ├── controllers/
│   ├── views/
│   │   └── treasure_page.dart
│   └── widgets/
│       ├── challenge_card.dart
│       └── treasure_header.dart
│
├── profile/
│   ├── controllers/
│   │   └── .gitkeep
│   ├── views/
│   │   ├── profile_page.dart
│   │   ├── user_profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   ├── settings_page.dart
│   │   ├── notifications_page.dart
│   │   ├── learning_controls_page.dart
│   │   ├── courses_page.dart
│   │   ├── change_password_page.dart
│   │   ├── phone_number_page.dart
│   │   ├── verify_phone_page.dart
│   │   └── phone_linked_page.dart
│   └── widgets/
│       ├── change_avatar_modal.dart
│       ├── complete_profile_card.dart
│       ├── confirm_delete_modal.dart
│       ├── country_selector_modal.dart
│       ├── course_item.dart
│       ├── delete_account_modal.dart
│       ├── overview_card.dart
│       ├── overview_section.dart
│       ├── profile_card.dart
│       ├── profile_header.dart
│       ├── reminder_time_modal.dart
│       └── weekly_progress_chart.dart
│
└── friends/
    ├── controllers/
    ├── views/
    └── widgets/
```

---

## Shared

```
lib/shared/
├── routes/
│   └── app_routes.dart
├── theme/
│   └── theme.dart
├── utils/
│   ├── app_assets.dart
│   └── responsive_utils.dart
└── widgets/
    ├── app_appbar.dart
    ├── app_back_button.dart
    ├── app_button.dart
    ├── app_float_anim.dart
    ├── app_lesson_button.dart
    ├── app_list_item.dart
    ├── app_pinput.dart
    ├── app_resend_code.dart
    └── app_text_field.dart
```

---

## Features Borders

```
lib/features/borders/
└── (reservado para integrações futuras)
```
