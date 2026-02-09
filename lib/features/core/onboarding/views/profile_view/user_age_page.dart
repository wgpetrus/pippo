import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_data_controller.dart';
import '../../controllers/onboarding_flow_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/onboarding_text_field.dart';

/// Tela de inserção da idade do usuário
class UserAgePage extends StatefulWidget {
  const UserAgePage({super.key});

  @override
  State<UserAgePage> createState() => _UserAgePageState();
}

class _UserAgePageState extends State<UserAgePage> {
  // Controllers
  final _ageController = TextEditingController();
  final _focusNode = FocusNode();

  late final OnboardingDataController _dataController;
  late final OnboardingFlowController _flowController;

  // Estados
  bool _isFocused = false;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _dataController = Get.find<OnboardingDataController>();
    _flowController = Get.find<OnboardingFlowController>();
    _ageController.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _ageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final hasText = _ageController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const OnboardingHeader(progress: 66),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'onboarding_user_age_question'.tr,
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
              const SizedBox(height: 24),
              Text(
                'onboarding_user_age_label'.tr,
                style: AppTheme.textMdBold.copyWith(color: AppTheme.black),
              ),
              const SizedBox(height: 8),
              OnboardingTextField(
                controller: _ageController,
                focusNode: _focusNode,
                hint: 'onboarding_user_age_hint'.tr,
                isFocused: _isFocused,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              const Spacer(),
              AppButton(
                text: 'common_continue'.tr,
                onPressed: hasText
                    ? () {
                        _dataController.setUserAge(_ageController.text.trim());
                        _flowController.nav.goToUserEmail();
                      }
                    : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
