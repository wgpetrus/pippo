import 'package:flutter/material.dart';

import 'confirm_delete_modal.dart';

/// Modal de confirmação de exclusão de conta
class DeleteAccountModal {
  static void show(BuildContext context, {required VoidCallback onDelete}) {
    ConfirmDeleteModal.show(
      context,
      title: 'Excluir Conta',
      description: 'Tem certeza que deseja excluir sua conta? Esta ação é permanente e apagará seu progresso, sequência, gemas e recompensas.',
      confirmText: 'Excluir Conta',
      onConfirm: onDelete,
    );
  }
}
