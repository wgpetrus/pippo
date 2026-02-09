import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_pinput.dart';
import '../../../../shared/widgets/app_resend_code.dart';
import '../controllers/auth_providers_controller.dart';

/// Tela de verificação de código de recuperação de senha
class VerifyCodeView extends StatefulWidget {
  const VerifyCodeView({super.key});

  @override
  State<VerifyCodeView> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  // Controllers
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  // Estados
  late final AuthProvidersController _controller;
  bool _isComplete = false;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthProvidersController>();
    _pinController.addListener(() {
      setState(() => _isComplete = _pinController.text.length == 5);
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Métodos
  void _verifyCode() {
    if (_pinController.text.length == 5) {
      _controller.verifyResetCode(_pinController.text);
    }
  }

  void _resendCode() {
    _controller.resendPasswordResetCode();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(title: 'auth_verify_code_title'.tr),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Texto com email mascarado
                    Text(
                      'auth_verify_code_description'.tr,
                      style: AppTheme.textMd.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Input de PIN (5 dígitos)
                    Center(
                      child: AppPinput(
                        controller: _pinController,
                        focusNode: _focusNode,
                        length: 5,
                        onCompleted: (pin) => _verifyCode(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Componente de reenvio com timer de 60 segundos
                    Center(
                      child: Obx(() => AppResendCode(
                        isComplete: _controller.resendTimer.value == 0,
                        secondsRemaining: _controller.resendTimer.value,
                        onResend: _controller.resendTimer.value == 0
                            ? _resendCode
                            : null,
                      )),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Mensagem de erro
                    Obx(() {
                      if (_controller.errorMessage.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _controller.errorMessage.value,
                          style: AppTheme.textSm.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // Botão verificar (desabilitado até 5 dígitos serem digitados)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  Obx(() => AppButton(
                    text: 'auth_verify_button'.tr,
                    isLoading: _controller.isLoading.value,
                    onPressed: _controller.isLoading.value
                        ? null
                        : (_isComplete ? _verifyCode : null),
                  )),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'auth_cancel_button'.tr,
                    isPrimary: false,
                    onPressed: _controller.isLoading.value
                        ? null
                        : _controller.cancelPasswordReset,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
