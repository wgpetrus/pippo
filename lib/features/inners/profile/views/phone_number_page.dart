import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/widgets/app_button.dart';
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
  final _phoneController = TextEditingController();

  // Estados
  String _countryCode = '+1';
  String _countryFlag = AppAssets.flagUsa;

  // Formatador de máscara
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Lifecycle
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Telefone'),
      body: Padding(
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
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_phoneMaskFormatter],
                      onChanged: (value) => setState(() {}),
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

            const Spacer(),

            // Botão Save/Next
            AppButton(
              text: _phoneController.text.isEmpty ? 'Salvar' : 'Próximo',
              onPressed: _phoneController.text.isEmpty ? null : () {
                Get.to(() => const VerifyPhonePage());
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
