import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/onboarding_data_controller.dart';
import '../controllers/onboarding_flow_controller.dart';

/// Tela de boas-vindas
class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  late final OnboardingFlowController _flowController;
  late final OnboardingDataController _dataController;

  // Lifecycle
  
  @override
  void initState() {
    super.initState();
    _flowController = Get.find<OnboardingFlowController>();
    _dataController = Get.find<OnboardingDataController>();
    
    // Verificar se veio com argumentos (login com onboarding incompleto)
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['skipWelcome'] == true) {
      _dataController.skipWelcome.value = true;
      
      // Configurar dados do usuário autenticado (lógica no controller)
      _flowController.configureAuthenticatedUser();
    }
    
    // Se skipWelcome = true, pular direto para próxima tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dataController.skipWelcome.value) {
        _flowController.handleSkipWelcome();
      }
    });
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: r.spacing24,
              vertical: r.spacing32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.mascotWelcome,
                  width: r.wp(85),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: r.spacing24),
                SvgPicture.asset(
                  AppAssets.logo,
                  width: r.wp(40),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: r.spacing12),
                Text(
                  'onboarding_welcome_title'.tr,
                  style: AppTheme.textLgRegular.copyWith(color: AppTheme.gray300),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: r.spacing32),
                AppButton(
                  text: 'onboarding_welcome_button_start'.tr,
                  onPressed: _flowController.nav.goToIntro,
                ),
                SizedBox(height: r.spacing16),
                AppButton(
                  text: 'onboarding_welcome_button_have_account'.tr,
                  isPrimary: false,
                  onPressed: _flowController.nav.goToAuth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
