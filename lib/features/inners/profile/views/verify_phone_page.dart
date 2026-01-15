import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_pinput.dart';
import '../../../../shared/widgets/app_resend_code.dart';
import 'phone_linked_page.dart';

/// Tela de verificação de código do telefone
class VerifyPhonePage extends StatefulWidget {
  const VerifyPhonePage({super.key});

  @override
  State<VerifyPhonePage> createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  // Form
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  // Lifecycle
  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
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
                      "Enviamos um código de 5 dígitos para seu telefone. Digite abaixo para desbloquear sua próxima aventura!",
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                    ),

                    const SizedBox(height: 32),

                    // Pin input
                    Center(
                      child: AppPinput(
                        controller: _pinController,
                        focusNode: _focusNode,
                        onCompleted: (pin) {},
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Resend code
                    AppResendCode(isComplete: true, onResend: () {}),
                  ],
                ),
              ),
            ),

            // Botão Verify
            if (isKeyboardVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: AppButton(
                  text: 'Verify',
                  onPressed: () => Get.to(() => const PhoneLinkedPage()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
