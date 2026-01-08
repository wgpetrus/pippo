import 'package:get/get.dart';

// Transitions
import '../views/transitions_view/intro_page.dart';
import '../views/transitions_view/pause_one_page.dart';
import '../views/transitions_view/pause_two_page.dart';
import '../views/transitions_view/conclusion_page.dart';

// Language
import '../views/language_view/select_language_page.dart';
import '../views/language_view/language_level_page.dart';
import '../views/language_view/learning_reason_page.dart';

// Time
import '../views/time_view/study_time_page.dart';

// Profile
import '../views/profile_view/user_name_page.dart';
import '../views/profile_view/user_age_page.dart';
import '../views/profile_view/user_email_page.dart';
import '../views/profile_view/user_password_page.dart';
import '../views/profile_view/verify_code_page.dart';

/// Navegação do onboarding
class OnboardingNavigation {
  // Transitions
  void goToIntro() => Get.to(() => const IntroPage());
  void goToPauseOne() => Get.to(() => const PauseOnePage());
  void goToPauseTwo() => Get.to(() => const PauseTwoPage());
  void goToConclusion() => Get.to(() => const ConclusionPage());

  // Language
  void goToSelectLanguage() => Get.to(() => const SelectLanguagePage());
  void goToLanguageLevel() => Get.to(() => const LanguageLevelPage());
  void goToLearningReason() => Get.to(() => const LearningReasonPage());

  // Time
  void goToStudyTime() => Get.to(() => const StudyTimePage());

  // Profile
  void goToUserName() => Get.to(() => const UserNamePage());
  void goToUserAge() => Get.to(() => const UserAgePage());
  void goToUserEmail() => Get.to(() => const UserEmailPage());
  void goToUserPassword() => Get.to(() => const UserPasswordPage());
  void goToVerifyCode() => Get.to(() => const VerifyCodePage());

  // Finalização
  void finishOnboarding() => Get.offAllNamed('/home');
  void goToAuth() => Get.toNamed('/auth');
}
