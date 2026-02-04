import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Helper centralizado para dialogs do app
/// 
/// Usa Awesome Dialog para confirmações, alertas e mensagens simples.
/// Para modals/bottom sheets complexos, usar WoltModalSheet.
class AppDialog {
  /// Dialog de confirmação padrão
  /// 
  /// Retorna true se confirmado, false se cancelado, null se dismissed.
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) async {
    bool? result;
    
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: title,
      desc: message,
      titleTextStyle: AppTheme.displayXsBold,
      descTextStyle: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
      btnCancelText: cancelText,
      btnCancelColor: AppTheme.gray400,
      btnCancelOnPress: () {
        result = false;
      },
      btnOkText: confirmText,
      btnOkColor: confirmColor ?? AppTheme.primary,
      btnOkOnPress: () {
        result = true;
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
    
    return result;
  }

  /// Dialog de sucesso
  static void success({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: title,
      desc: message,
      titleTextStyle: AppTheme.displayXsBold,
      descTextStyle: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
      btnOkText: 'OK',
      btnOkColor: AppTheme.green,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  /// Dialog de erro
  static void error({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: title,
      desc: message,
      titleTextStyle: AppTheme.displayXsBold,
      descTextStyle: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
      btnOkText: 'OK',
      btnOkColor: AppTheme.red,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  /// Dialog de aviso
  static void warning({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: title,
      desc: message,
      titleTextStyle: AppTheme.displayXsBold,
      descTextStyle: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
      btnOkText: 'OK',
      btnOkColor: AppTheme.orange,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  /// Dialog de informação
  static void info({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: title,
      desc: message,
      titleTextStyle: AppTheme.displayXsBold,
      descTextStyle: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
      btnOkText: 'OK',
      btnOkColor: AppTheme.primary,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  /// Dialog de loading
  /// 
  /// Usar Get.back() para fechar após operação assíncrona.
  static void loading({
    required BuildContext context,
    String? message,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primary),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message, style: AppTheme.textMdMedium),
            ],
          ],
        ),
      ),
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }
}
