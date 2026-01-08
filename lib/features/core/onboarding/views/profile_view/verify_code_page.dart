import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
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
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const OnboardingHeader(progress: 100),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One step closer to your streak!',
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We\'ve sent a 5-digit code to your e-mail. Enter it below to unlock your next adventure!',
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                    ),
                    const SizedBox(height: 32),
                    AppPinput(
                      controller: _pinController,
                      focusNode: _focusNode,
                      onCompleted: (pin) => _controller.nav.goToConclusion(),
                    ),
                    const SizedBox(height: 20),
                    AppResendCode(isComplete: _isComplete, onResend: () {}),
                  ],
                ),
              ),
            ),
            if (isKeyboardVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: AppButton(
                  text: 'Verify',
                  onPressed: _isComplete ? _controller.nav.goToConclusion : null,
                  isPrimary: _isComplete,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
