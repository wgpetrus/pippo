import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/responsive_utils.dart';
import '../../../../../shared/utils/validation_helper.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_data_controller.dart';
import '../../controllers/onboarding_flow_controller.dart';
import '../../controllers/onboarding_validation_controller.dart';
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

  late final OnboardingDataController _dataController;
  late final OnboardingFlowController _flowController;
  late final OnboardingValidationController _validationController;

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
    _dataController = Get.find<OnboardingDataController>();
    _flowController = Get.find<OnboardingFlowController>();
    _validationController = Get.find<OnboardingValidationController>();
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Crie sua senha mágica',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
              SizedBox(height: r.spacing24),
              
              // Exibir erro se houver
              Obx(() => _validationController.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(bottom: r.spacing16),
                      child: Text(
                        _validationController.errorMessage.value,
                        style: AppTheme.textSmRegular.copyWith(color: AppTheme.error),
                      ),
                    )
                  : const SizedBox.shrink()),
              
              // Exibir mensagem de retry se houver
              Obx(() => _dataController.retryMessage.value.isNotEmpty
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
                                  _dataController.retryMessage.value,
                                  style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray600),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: r.spacing8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => _dataController.cancelRetry(),
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
              SizedBox(height: r.keyboardHeight > 0 ? r.spacing16 : r.spacing48),
              Obx(() => AppButton(
                text: 'Continuar',
                isLoading: _validationController.isLoading.value,
                onPressed: (_canContinue && !_validationController.isLoading.value)
                    ? () {
                        // Validar senha antes de prosseguir
                        final passwordError = _validationController.validatePassword(_passwordController.text);
                        if (passwordError != null) {
                          _validationController.errorMessage.value = passwordError;
                          return;
                        }
                        
                        _dataController.setUserPassword(_passwordController.text);
                        _validationController.createAccount();
                      }
                    : null,
              )),
              
              // Botão "Já tenho uma conta" quando email já existe
              Obx(() => _dataController.showLoginOption.value
                  ? Padding(
                      padding: EdgeInsets.only(top: r.spacing12),
                      child: AppButton(
                        text: 'Já tenho uma conta',
                        isPrimary: false,
                        onPressed: () => _flowController.nav.goToAuth(),
                      ),
                    )
                  : const SizedBox.shrink()),
              
              SizedBox(height: r.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}
