import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/responsive_utils.dart';
import '../../../../../shared/utils/validation_helper.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../controllers/onboarding_data_controller.dart';
import '../../controllers/onboarding_flow_controller.dart';
import '../../widgets/onboarding_header.dart';
import '../../widgets/onboarding_text_field.dart';

/// Tela de inserção do nome do usuário
class UserNamePage extends StatefulWidget {
  const UserNamePage({super.key});

  @override
  State<UserNamePage> createState() => _UserNamePageState();
}

class _UserNamePageState extends State<UserNamePage> {
  // Controllers
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();

  late final OnboardingDataController _dataController;
  late final OnboardingFlowController _flowController;

  // Estados
  bool _isFocused = false;
  String? _errorMessage;

  // Lifecycle

  @override
  void initState() {
    super.initState();
    _dataController = Get.find<OnboardingDataController>();
    _flowController = Get.find<OnboardingFlowController>();
    
    // Pre-fill with Google displayName if available
    if (_dataController.userName.value.isNotEmpty) {
      _nameController.text = _dataController.userName.value;
    }
    
    _nameController.addListener(_validateInput);
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Métodos

  void _validateInput() {
    setState(() {
      _errorMessage = ValidationHelper.validateName(_nameController.text);
    });
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    final hasText = _nameController.text.isNotEmpty;
    final isValid = hasText && _errorMessage == null;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const OnboardingHeader(progress: 55),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Qual é o seu nome?',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
              ),
              SizedBox(height: r.spacing24),
              Text(
                'Nome',
                style: AppTheme.textMdBold.copyWith(color: AppTheme.black),
              ),
              SizedBox(height: r.spacing8),
              OnboardingTextField(
                controller: _nameController,
                focusNode: _focusNode,
                hint: 'digite seu nome',
                isFocused: _isFocused,
                errorText: _errorMessage,
              ),
              SizedBox(height: r.hp(40)),
              AppButton(
                text: 'Continuar',
                onPressed: isValid
                    ? () {
                        _dataController.setUserName(_nameController.text.trim());
                        _flowController.nav.goToUserAge();
                      }
                    : null,
              ),
              SizedBox(height: r.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}
