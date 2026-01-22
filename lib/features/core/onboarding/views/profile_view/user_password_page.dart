import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/responsive_utils.dart';
import '../../../../../shared/utils/validation_helper.dart';
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
  String? _passwordError;
  String? _confirmError;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    _passwordController.addListener(_validatePassword);
    _confirmController.addListener(_validateConfirmPassword);
    _passwordFocus.addListener(() => setState(() => _passwordFocused = _passwordFocus.hasFocus));
    _confirmFocus.addListener(() => setState(() => _confirmFocused = _confirmFocus.hasFocus));
  }

  // Validadores
  void _validatePassword() {
    setState(() {
      _passwordError = ValidationHelper.validatePassword(_passwordController.text);
      // Re-validar confirmação se já foi preenchida
      if (_confirmController.text.isNotEmpty) {
        _validateConfirmPassword();
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      if (_confirmController.text.isEmpty) {
        _confirmError = null;
      } else if (_confirmController.text != _passwordController.text) {
        _confirmError = 'As senhas não coincidem.';
      } else {
        _confirmError = null;
      }
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _confirmController.removeListener(_validateConfirmPassword);
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
      _passwordError == null &&
      _confirmError == null;

  // Widgets
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
              
              // Exibir mensagem de retry se houver
              Obx(() => _controller.retryMessage.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(bottom: r.spacing16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary,
                                ),
                              ),
                              SizedBox(width: r.spacing8),
                              Expanded(
                                child: Text(
                                  _controller.retryMessage.value,
                                  style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray600),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: r.spacing8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => _controller.cancelRetry(),
                              child: Text(
                                'Cancelar',
                                style: AppTheme.textSmBold.copyWith(color: AppTheme.error),
                              ),
                            ),
                          ),
                        ],
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
                errorText: _passwordError,
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
                errorText: _confirmError,
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
                        
                        _controller.setPassword(_passwordController.text);
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
