import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/responsive_utils.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/onboarding_text_field.dart';

/// Tela de criação de senha do usuário
class UserPasswordPage extends StatefulWidget {
  const UserPasswordPage({super.key});

  @override
  State<UserPasswordPage> createState() => _UserPasswordPageState();
}

class _UserPasswordPageState extends State<UserPasswordPage> {
  // Controllers
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late final OnboardingController _controller;

  // Estados
  bool _passwordFocused = false;
  bool _confirmFocused = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() => _passwordFocused = _passwordFocus.hasFocus));
    _confirmFocus.addListener(() => setState(() => _confirmFocused = _confirmFocus.hasFocus));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // Getters
  bool get _canContinue =>
      _passwordController.text.isNotEmpty &&
      _confirmController.text.isNotEmpty &&
      _passwordController.text == _confirmController.text;

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const OnboardingHeader(
        currentScreen: 'user_password',
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crie sua senha mágica',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
              SizedBox(height: r.spacing24),
              
              // Exibir erro se houver
              Obx(() => _controller.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(bottom: r.spacing16),
                      child: Text(
                        _controller.errorMessage.value,
                        style: AppTheme.textSmRegular.copyWith(color: AppTheme.error),
                      ),
                    )
                  : const SizedBox.shrink()),
              
              Text(
                'Senha',
                style: AppTheme.textMdBold.copyWith(color: AppTheme.black),
              ),
              SizedBox(height: r.spacing8),
              OnboardingTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                hint: 'digite sua senha',
                isFocused: _passwordFocused,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: FaIcon(
                    _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                    color: AppTheme.gray400,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: r.spacing16),
              Text(
                'Confirmar Senha',
                style: AppTheme.textMdBold.copyWith(color: AppTheme.black),
              ),
              SizedBox(height: r.spacing8),
              OnboardingTextField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                hint: 'repita sua senha',
                isFocused: _confirmFocused,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: FaIcon(
                    _obscureConfirm ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                    color: AppTheme.gray400,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const Spacer(),
              Obx(() => AppButton(
                text: 'Continuar',
                isLoading: _controller.isLoading.value,
                onPressed: (_canContinue && !_controller.isLoading.value)
                    ? () {
                        // Validar senha antes de prosseguir
                        final passwordError = _controller.validatePassword(_passwordController.text);
                        if (passwordError != null) {
                          _controller.errorMessage.value = passwordError;
                          return;
                        }
                        
                        _controller.userPassword.value = _passwordController.text;
                        _controller.createAccount();
                      }
                    : null,
              )),
              SizedBox(height: r.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}
