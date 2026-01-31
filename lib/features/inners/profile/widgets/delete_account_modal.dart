import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import 'confirm_delete_modal.dart';

/// Modal de primeira confirmação de exclusão de conta
class DeleteAccountModal {
  static void show(BuildContext context) {
    final r = ResponsiveUtils(context);

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.red100,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(r.spacing24, r.spacing16, r.spacing24, r.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Excluir Conta',
                  style: AppTheme.displayXsBold.copyWith(color: AppTheme.red),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.spacing16),

                // Descrição das consequências
                Text(
                  'Tem certeza que deseja excluir sua conta?\n\nEsta ação é permanente e irá apagar:',
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.black),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.spacing12),

                // Lista de consequências
                _buildConsequenceItem(r, 'Todo seu progresso de aprendizado'),
                _buildConsequenceItem(r, 'Sua sequência de dias consecutivos'),
                _buildConsequenceItem(r, 'Todas as suas gemas e recompensas'),
                _buildConsequenceItem(r, 'Seus cursos e estatísticas'),
                _buildConsequenceItem(r, 'Suas conexões sociais (seguidores/seguindo)'),

                SizedBox(height: r.spacing24),

                // Botão Cancel (secundário)
                AppButton(
                  text: 'Cancelar',
                  isPrimary: false,
                  onPressed: () => Get.back(),
                ),

                SizedBox(height: r.spacing12),

                // Botão Continuar para segunda confirmação
                // TODO: [etapa 8] conectar com controller.showSecondConfirmation()
                _DeleteButton(
                  onPressed: () {
                    Get.back(); // Fecha o primeiro modal
                    // Mostra o segundo modal de confirmação
                    ConfirmDeleteModal.show(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildConsequenceItem(ResponsiveUtils r, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.spacing4),
      child: Row(
        children: [
          Icon(
            Icons.close,
            color: AppTheme.red,
            size: r.fontSize16,
          ),
          SizedBox(width: r.spacing8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.textSmRegular.copyWith(color: AppTheme.black),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão vermelho de exclusão (customizado para cor vermelha)
class _DeleteButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _DeleteButton({required this.onPressed});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: double.infinity,
        height: ResponsiveUtils.height(62, min: 48, max: 72),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppTheme.red,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: _isPressed ? 0 : 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AppTheme.red,
          ),
          child: Center(
            child: Text(
              'Continuar',
              style: AppTheme.textLgBold.copyWith(color: AppTheme.white),
            ),
          ),
        ),
      ),
    );
  }
}
