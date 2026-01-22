import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/validation_helper.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';
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

  late final OnboardingController _controller;

  // Estados
  bool _isFocused = false;
  String? _errorMessage;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    _emailController.addListener(_validateInput);
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  // Validação em tempo real
  void _validateInput() {
    setState(() {
      _errorMessage = ValidationHelper.validateEmail(_emailController.text);
    });
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
    final hasText = _emailController.text.isNotEmpty;
    final isValid = _errorMessage == null && hasText;

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
                errorText: _errorMessage,
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 200),
              AppButton(
                text: 'Continuar',
                onPressed: isValid
                    ? () {
                        _controller.userEmail.value = _emailController.text.trim();
                        _controller.nav.goToUserPassword();
                      }
                    : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
