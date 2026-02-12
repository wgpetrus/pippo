import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_pinput.dart';
import '../../../../shared/widgets/app_resend_code.dart';
import '../controllers/profile_auth_controller.dart';

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

  late final ProfileAuthController _controller;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    // Garantir que ProfileAuthController está disponível
    if (!Get.isRegistered<ProfileAuthController>()) {
      Get.put(ProfileAuthController());
    }
    _controller = Get.find<ProfileAuthController>();
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
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(title: 'verify_phone_title'.tr),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: r.spacing24,
                  right: r.spacing24,
                  top: r.spacing24,
                  bottom: r.keyboardHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      'verify_phone_otp_title'.tr,
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    ),

                    SizedBox(height: r.spacing12),

                    // Descrição
                    Text(
                      'verify_phone_description'.tr,
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                    ),

                    SizedBox(height: r.spacing32),

                    // Pin input
                    Center(
                      child: AppPinput(
                        controller: _pinController,
                        focusNode: _focusNode,
                        onCompleted: (pin) => _verifyCode(),
                      ),
                    ),

                    SizedBox(height: r.spacing16),

                    // Resend code
                    AppResendCode(
                      isComplete: true,
                      onResend: () {
                        // Reenviar código via controller
                        _controller.linkPhoneNumber(
                          widget.phoneNumber,
                          '',
                        );
                      },
                    ),

                    SizedBox(height: r.spacing16),

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
            if (r.isKeyboardOpen)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  r.spacing24,
                  0,
                  r.spacing24,
                  r.spacing16,
                ),
                child: Obx(() => AppButton(
                  text: 'verify_phone_verify'.tr,
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
