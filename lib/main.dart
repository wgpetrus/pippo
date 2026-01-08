import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'shared/routes/app_routes.dart';
import 'shared/theme/theme.dart';

void main() {
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
