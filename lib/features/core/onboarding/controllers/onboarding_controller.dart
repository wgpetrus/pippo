import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/onboarding_navigation.dart';

/// Controller do fluxo de onboarding
class OnboardingController extends GetxController {
  // Flag estático para pular WelcomeView (setado antes da navegação)
  static bool shouldSkipWelcome = false;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Estados adicionais
  final isAddingCourse = false.obs;
  
  // Flag para pular WelcomeView (quando vem de login social)
  final skipWelcome = false.obs;

  // Navegação
  final nav = OnboardingNavigation();

  // Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Dados do onboarding - Idioma
  final selectedLanguage = ''.obs;
  final languageLevel = ''.obs;
  final learningReason = ''.obs;

  // Dados do onboarding - Tempo
  final studyTime = ''.obs;

  // Dados do onboarding - Perfil
  final userName = ''.obs;
  final userAge = ''.obs;
  final userEmail = ''.obs;
  final userPassword = ''.obs;

  // Métodos públicos

  /// Completa o onboarding e salva os estados necessários
  Future<void> completeOnboarding() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Salvar isFirstAccess = false no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);

      // Salvar onboardingCompleted = true no Firestore (se usuário autenticado)
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'onboardingCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Navegar para home
      nav.finishOnboarding();
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível finalizar o onboarding. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Handlers

  /// Handler de erros do Firestore (padrão da empresa)
  String _handleFirestoreError(FirebaseException e) {
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
