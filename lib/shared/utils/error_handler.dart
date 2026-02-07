import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  static String getLoginErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Verifique e tente novamente.';
      case 'invalid-email':
        return 'Por favor, insira um e-mail válido.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Entre em contato com o suporte.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Não foi possível fazer login. Tente novamente.';
    }
  }

  static String getRegisterErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está sendo usado por outra conta.';
      case 'invalid-email':
        return 'Por favor, insira um e-mail válido.';
      case 'operation-not-allowed':
        return 'Operação não permitida no momento.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      default:
        return 'Não foi possível criar sua conta. Tente novamente.';
    }
  }

  static String getResetPasswordErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail.';
      case 'invalid-email':
        return 'Por favor, insira um e-mail válido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      default:
        return 'Não foi possível enviar o e-mail de recuperação. Tente novamente.';
    }
  }

  static String getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
      case 'unavailable':
        return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
      case 'deadline-exceeded':
        return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
      case 'resource-exhausted':
        return 'Muitas requisições. Aguarde alguns minutos e tente novamente.';
      case 'failed-precondition':
        return 'Operação não permitida no estado atual. Tente novamente.';
      case 'aborted':
        return 'Operação cancelada. Tente novamente.';
      case 'out-of-range':
        return 'Valor fora do intervalo permitido.';
      case 'unimplemented':
        return 'Operação não implementada.';
      case 'internal':
        return 'Erro interno do servidor. Tente novamente em alguns instantes.';
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'not-found':
        return 'Recurso não encontrado.';
      case 'already-exists':
        return 'Recurso já existe.';
      case 'cancelled':
        return 'Operação cancelada.';
      case 'data-loss':
        return 'Erro de integridade de dados.';
      case 'invalid-argument':
        return 'Argumento inválido.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }
}
