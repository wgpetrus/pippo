import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/profile_controller.dart';
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

  late final ProfileController _controller;

  // Formatador de máscara
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
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
          _controller.verificationId = verificationId;
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
        _errorMessage = 'Erro ao enviar código. Tente novamente.';
      });
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Número de telefone inválido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      default:
        return 'Erro ao enviar código. Tente novamente.';
    }
  }

  // Widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Telefone'),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                "Qual é o seu telefone",
                style: AppTheme.textLgBold.copyWith(color: AppTheme.black),
              ),

              const SizedBox(height: 16),

              // Campo de telefone com seletor de país
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          const SizedBox(width: 8),
                          Text(
                            _countryCode,
                            style: AppTheme.textMdMedium.copyWith(color: AppTheme.black),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppTheme.gray400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Campo de texto
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneMaskFormatter],
                        onChanged: (value) => setState(() {}),
                        validator: _controller.validatePhoneNumber,
                        style: AppTheme.textMdMedium.copyWith(color: AppTheme.black),
                        decoration: InputDecoration(
                          hintText: 'número de telefone',
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

              const SizedBox(height: 16),

              // Aviso
              Text(
                'Você receberá um SMS para verificar seu telefone. Taxas de SMS padrão podem ser aplicadas.',
                style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray400),
              ),

              // Error message
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: AppTheme.textSmMedium.copyWith(color: AppTheme.error),
                ),
              ],

              const Spacer(),

              // Botão Save/Next
              AppButton(
                text: _phoneController.text.isEmpty ? 'Salvar' : 'Próximo',
                isLoading: _isSendingCode,
                onPressed: (_phoneController.text.isEmpty || _isSendingCode)
                    ? null
                    : _sendVerificationCode,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
