import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/core/auth/controllers/auth_credentials_controller.dart';
import 'features/core/auth/controllers/auth_providers_controller.dart';
import 'features/inners/gamification/controllers/energy_controller.dart';
import 'features/inners/gamification/controllers/gems_controller.dart';
import 'features/inners/gamification/controllers/streak_controller.dart';
import 'features/inners/gamification/controllers/xp_level_controller.dart';
import 'firebase_options.dart';
import 'shared/routes/app_routes.dart';
import 'shared/theme/theme.dart';
import 'shared/translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register global auth controllers
  Get.put(AuthCredentialsController(), permanent: true);
  Get.put(AuthProvidersController(), permanent: true);
  
  // Register gamification controllers (order matters - dependencies first)
  Get.put(GemsController(), permanent: true);
  Get.put(EnergyController(), permanent: true);
  Get.put(StreakController(), permanent: true);
  Get.put(XpLevelController(), permanent: true);

  runApp(const MainApp());
}

/// App principal
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      
      // Translation Configuration
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('pt', 'BR'),
      
      // Routes Configuration
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      
      // Theme Configuration
      theme: ThemeData(fontFamily: AppTheme.fontFamily),
    );
  }
}