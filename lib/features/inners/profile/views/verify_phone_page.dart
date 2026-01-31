import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_pinput.dart';
import '../../../../shared/widgets/app_resend_code.dart';
import '../controllers/profile_controller.dart';
import 'phone_linked_page.dart';

/// Tela de verificação de código do telefone
class VerifyPhonePage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const VerifyPhonePage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<VerifyPhonePage> createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  // Form
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  late final ProfileController _controller;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Métodos
  void _verifyCode() {
    if (_pinController.text.length == 6) {
      _controller.linkPhoneNumber(
        widget.phoneNumber,
        _pinController.text,
      );
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Telefone'),
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
                    // Título
                    Text(
                      'OTP',
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    ),

                    const SizedBox(height: 12),

                    // Descrição
                    Text(
                      "Enviamos um código de 6 dígitos para seu telefone. Digite abaixo para desbloquear sua próxima aventura!",
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                    ),

                    const SizedBox(height: 32),

                    // Pin input
                    Center(
                      child: AppPinput(
                        controller: _pinController,
                        focusNode: _focusNode,
                        onCompleted: (pin) => _verifyCode(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Resend code
                    AppResendCode(isComplete: true, onResend: () {
                      // TODO: Implementar reenvio de código
                    }),

                    const SizedBox(height: 16),

                    // Error message
                    Obx(() {
                      if (_controller.errorMessage.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        _controller.errorMessage.value,
                        style: AppTheme.textSmMedium.copyWith(color: AppTheme.error),
                        textAlign: TextAlign.center,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Botão Verify
            if (isKeyboardVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Obx(() => AppButton(
                  text: 'Verificar',
                  isLoading: _controller.isLoading.value,
                  onPressed: _controller.isLoading.value ? null : _verifyCode,
                )),
              ),
          ],
        ),
      ),
    );
  }
}
