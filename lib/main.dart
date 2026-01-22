import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/core/auth/controllers/auth_controller.dart';
import 'features/inners/gamification/controllers/gamification_controller.dart';
import 'firebase_options.dart';
import 'shared/routes/app_routes.dart';
import 'shared/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register global controllers
  Get.put(AuthController(), permanent: true);
  Get.put(GamificationController(), permanent: true);

  runApp(const MainApp());
}

/// App principal
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      theme: ThemeData(fontFamily: AppTheme.fontFamily),
    );
  }
}