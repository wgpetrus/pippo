import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/responsive_utils.dart';
import '../../../../../shared/utils/validation_helper.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_data_controller.dart';
import '../../controllers/onboarding_flow_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/onboarding_text_field.dart';

/// Tela de inserção do email do usuário
class UserEmailPage extends StatefulWidget {
  const UserEmailPage({super.key});

  @override
  State<UserEmailPage> createState() => _UserEmailPageState();
}

class _UserEmailPageState extends State<UserEmailPage> {
  // Controllers
  final _emailController = TextEditingController();
  final _focusNode = FocusNode();

  late final OnboardingDataController _dataController;
  late final OnboardingFlowController _flowController;

  // Estados
  bool _isFocused = false;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _dataController = Get.find<OnboardingDataController>();
    _flowController = Get.find<OnboardingFlowController>();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const OnboardingHeader(progress: 77),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Qual é o seu e-mail?',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
              const SizedBox(height: 24),
              Text(
                'E-mail',
                style: AppTheme.textMdBold.copyWith(color: AppTheme.black),
              ),
              const SizedBox(height: 8),
              OnboardingTextField(
                controller: _emailController,
                focusNode: _focusNode,
                hint: 'digite seu e-mail',
                isFocused: _isFocused,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: r.isKeyboardOpen ? 16 : 200),
              AppButton(
                text: 'Continuar',
                onPressed: () {
                  final email = _emailController.text.trim();
                  final error = ValidationHelper.validateEmail(email);
                  
                  if (error != null) {
                    Get.snackbar(
                      'E-mail inválido',
                      error,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppTheme.error,
                      colorText: AppTheme.white,
                    );
                    return;
                  }
                  
                  _dataController.setUserEmail(email);
                  _flowController.nav.goToUserPassword();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
