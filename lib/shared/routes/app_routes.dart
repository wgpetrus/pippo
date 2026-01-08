import 'package:get/get.dart';

import '../../features/core/auth/bindings/auth_binding.dart';
import '../../features/core/auth/views/signin_view.dart';
import '../../features/core/onboarding/bindings/onboarding_binding.dart';
import '../../features/core/onboarding/views/welcome_view.dart';
import '../../features/inners/splash/bindings/splash_binding.dart';
import '../../features/inners/splash/views/splash_view.dart';

/// Rotas do app
class AppRoutes {
  // Nomes das rotas
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const auth = '/auth';

  // Lista de rotas
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
  ];
}
