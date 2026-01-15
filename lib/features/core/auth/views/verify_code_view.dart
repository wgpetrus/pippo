import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_pinput.dart';
import '../../../../shared/widgets/app_resend_code.dart';
import '../controllers/auth_controller.dart';

/// Tela de verificação de código do auth
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
  late final AuthController _controller;
  bool _isComplete = false;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
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

  // Build
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Confirme seu e-mail'),
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
                    Text(
                      'Um passo mais perto da sua sequência!',
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enviamos um código de 5 dígitos para seu e-mail. Digite abaixo para desbloquear sua próxima aventura!',
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: AppPinput(
                        controller: _pinController,
                        focusNode: _focusNode,
                        onCompleted: (pin) {
                          // TODO: Implementar validação do código
                          _controller.goToNewPassword();
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppResendCode(
                      isComplete: _isComplete,
                      onResend: () {
                        // TODO: Implementar reenvio de código
                        // _controller.resendCode();
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Botão sempre visível para melhor UX
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: AppButton(
                text: 'Verificar',
                onPressed: _isComplete
                    ? () {
                        // TODO: Implementar validação do código
                        _controller.goToNewPassword();
                      }
                    : null,
                isPrimary: _isComplete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
