# Rotas - Pippo

> Rotas principais definidas em `shared/routes/app_routes.dart`

---

## Rotas Registradas

| Rota | View | Binding | Descrição |
|------|------|---------|-----------|
| `/splash` | SplashView | SplashBinding | Tela inicial |
| `/onboarding` | WelcomeView | OnboardingBinding | Fluxo de novo usuário |
| `/auth` | SigninView | AuthBinding | Login de usuário existente |
| `/home` | HomeView | HomeBinding | Tela principal com tabs |

---

## Código

```dart
class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const home = '/home';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => const WelcomeView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: auth,
      page: () => const SigninView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
```

---

## Navegação Interna

### Onboarding
Navegação via `OnboardingNavigation` (não usa rotas GetX):
- `nav.goToSelectLanguage()`
- `nav.goToLanguageLevel()`
- `nav.goToLearningReason()`
- `nav.goToIntro()`
- `nav.goToStudyTime()`
- `nav.goToPauseOne()`
- `nav.goToUserName()`
- `nav.goToUserAge()`
- `nav.goToPauseTow()`
- `nav.goToUserEmail()`
- `nav.goToUserPassword()`
- `nav.goToVerifyCode()`
- `nav.goToConclusion()`
- `nav.finishOnboarding()` → `/home`

### Auth
Navegação via `AuthController`:
- `goToForgotPassword()`
- `goToVerifyCode()`
- `goToNewPassword()`
- `backToSignin()` → `/auth`

### Home
Navegação por estado (IndexedStack):
- `currentNavIndex.value = 0` → Courses
- `currentNavIndex.value = 1` → Leaderboard
- `currentNavIndex.value = 2` → Shop
- `currentNavIndex.value = 3` → Treasure
- `currentNavIndex.value = 4` → Profile

### Profile
Navegação via `Get.to()`:
- `Get.to(() => UserProfilePage())`
- `Get.to(() => EditProfilePage())`
- `Get.to(() => SettingsPage())`
- etc.
