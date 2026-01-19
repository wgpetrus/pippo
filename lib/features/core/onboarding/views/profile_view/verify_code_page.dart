import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/responsive_utils.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_pinput.dart';
import '../../../../../shared/widgets/app_resend_code.dart';
import '../../controllers/onboarding_controller.dart';
import '../../widgets/onboarding_header.dart';

/// Tela de verificação de código do onboarding
class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  // Controllers
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  late final OnboardingController _controller;

  // Estados
  bool _isComplete = false;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
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
    final r = ResponsiveUtils(context);
    final isKeyboardVisible = r.isKeyboardOpen;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const OnboardingHeader(
        currentScreen: 'verify_code',
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(r.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One step closer to your streak!',
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    ),
                    SizedBox(height: r.spacing12),
                    Text(
                      'We\'ve sent a 5-digit code to your e-mail. Enter it below to unlock your next adventure!',
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                    ),
                    SizedBox(height: r.spacing32),
                    
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
                    
                    Center(
                      child: AppPinput(
                        controller: _pinController,
                        focusNode: _focusNode,
                        onCompleted: (pin) {
                          if (!_controller.isLoading.value) {
                            _controller.verifyCode(pin);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: r.spacing24),
                    Obx(() => AppResendCode(
                      isComplete: _isComplete,
                      onResend: _controller.isLoading.value
                          ? () {}
                          : _controller.resendVerificationCode,
                    )),
                  ],
                ),
              ),
            ),
            if (isKeyboardVisible)
              Padding(
                padding: EdgeInsets.fromLTRB(r.spacing24, 0, r.spacing24, r.spacing16),
                child: Obx(() => AppButton(
                  text: 'Verify',
                  isLoading: _controller.isLoading.value,
                  onPressed: (_isComplete && !_controller.isLoading.value)
                      ? () => _controller.verifyCode(_pinController.text)
                      : null,
                  isPrimary: _isComplete,
                )),
              ),
          ],
        ),
      ),
    );
  }
}
