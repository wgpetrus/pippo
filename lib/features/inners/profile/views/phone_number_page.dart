import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/phone_mask_helper.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/profile_auth_controller.dart';
import '../widgets/country_selector_modal.dart';
import 'verify_phone_page.dart';

/// Página de edição de número de telefone
class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  // Estados
  String _countryCode = '+1';
  String _countryFlag = AppAssets.flagUsa;
  bool _isSendingCode = false;
  String _errorMessage = '';

  late final ProfileAuthController _controller;

  // Formatador de máscara (dinâmico por país)
  late MaskTextInputFormatter _phoneMaskFormatter;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    // Garantir que ProfileAuthController está disponível
    if (!Get.isRegistered<ProfileAuthController>()) {
      Get.put(ProfileAuthController());
    }
    _controller = Get.find<ProfileAuthController>();
    // Inicializar máscara com país padrão
    _phoneMaskFormatter = PhoneMaskHelper.getMaskForCountry(_countryCode);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Métodos
  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSendingCode = true;
      _errorMessage = '';
    });

    final fullPhoneNumber = _countryCode + _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verificação (Android)
          // Não fazemos nada aqui, deixamos o usuário inserir o código manualmente
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isSendingCode = false;
            _errorMessage = _getErrorMessage(e);
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isSendingCode = false;
          });
          // Salvar verificationId no controller
          _controller.verificationId.value = verificationId;
          // Navegar para tela de verificação
          Get.to(() => VerifyPhonePage(
            phoneNumber: fullPhoneNumber,
            verificationId: verificationId,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout de auto-recuperação
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isSendingCode = false;
        _errorMessage = 'phone_number_error_generic'.tr;
      });
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'phone_number_error_invalid'.tr;
      case 'too-many-requests':
        return 'phone_number_error_too_many'.tr;
      case 'network-request-failed':
        return 'phone_number_error_network'.tr;
      default:
        return 'phone_number_error_generic'.tr;
    }
  }

  // Widgets
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(title: 'phone_number_title'.tr),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(r.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'phone_number_question'.tr,
                  style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
                ),

                SizedBox(height: r.spacing16),

                // Campo de telefone com seletor de país
                Container(
                  padding: EdgeInsets.symmetric(horizontal: r.spacing16, vertical: r.spacing12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.gray600, width: 1),
                  ),
                  child: Row(
                    children: [
                      // Bandeira e código do país
                      GestureDetector(
                        onTap: () {
                          CountrySelectorModal.show(
                            context,
                            currentCode: _countryCode,
                            onSelect: (code, flag) {
                              setState(() {
                                _countryCode = code;
                                _countryFlag = flag;
                                // Atualizar máscara quando país muda
                                _phoneMaskFormatter = PhoneMaskHelper.getMaskForCountry(code);
                                // Limpar campo para aplicar nova máscara
                                _phoneController.clear();
                              });
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              _countryFlag,
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: r.spacing8),
                            Text(
                              _countryCode,
                              style: AppTheme.textMdMedium.copyWith(color: AppTheme.black),
                            ),
                            SizedBox(width: r.spacing4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.gray400,
                              size: 20,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: r.spacing12),

                      // Campo de texto
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneMaskFormatter],
                          onChanged: (value) => setState(() {}),
                          validator: _validatePhoneNumber,
                          style: AppTheme.textMdMedium.copyWith(color: AppTheme.black),
                          decoration: InputDecoration(
                            hintText: PhoneMaskHelper.getPlaceholderForCountry(_countryCode),
                            hintStyle: AppTheme.textMdMedium.copyWith(color: AppTheme.gray400),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: r.spacing16),

                // Aviso
                Text(
                  'phone_number_warning'.tr,
                  style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray400),
                ),

                // Error message
                if (_errorMessage.isNotEmpty) ...[
                  SizedBox(height: r.spacing16),
                  Text(
                    _errorMessage,
                    style: AppTheme.textSmMedium.copyWith(color: AppTheme.error),
                  ),
                ],

                const Spacer(),

                // Botão Save/Next
                AppButton(
                  text: _phoneController.text.isEmpty ? 'phone_number_save'.tr : 'phone_number_next'.tr,
                  isLoading: _isSendingCode,
                  onPressed: (_phoneController.text.isEmpty || _isSendingCode)
                      ? null
                      : _sendVerificationCode,
                ),

                SizedBox(height: r.spacing16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Validadores
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'phone_number_validation_required'.tr;
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    final minDigits = PhoneMaskHelper.getMinDigitsForCountry(_countryCode);
    if (digitsOnly.length < minDigits) {
      return 'phone_number_validation_invalid'.tr;
    }
    return null;
  }
}
