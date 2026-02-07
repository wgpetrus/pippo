// Dart SDK
import 'dart:async';

// Flutter packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Controllers
import '../../../core/onboarding/controllers/onboarding_flow_controller.dart';
import '../../../../shared/utils/error_handler.dart';

/// Controller da splash screen
class SplashController extends GetxController {
  // Instâncias Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final showRetryButton = false.obs;

  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  // Métodos públicos

  /// Método público para retry
  void retry() {
    _navigate();
  }

  // Métodos privados
  
  /// Navega para a tela apropriada baseado no estado do usuário
  Future<void> _navigate() async {
    // Exibir splash por no mínimo 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    try {
      isLoading.value = true;
      errorMessage.value = '';
      showRetryButton.value = false;

      // Ordem crítica de verificação (NUNCA inverter)
      // 1. Verificar se usuário está autenticado
      final isAuthenticated = _isAuthenticated();

      if (!isAuthenticated) {
        // 2. Se não autenticado, verificar primeiro acesso
        final isFirstAccess = await _isFirstAccess();

        if (isFirstAccess) {
          _navigateToOnboarding();
        } else {
          _navigateToAuth();
        }
        return;
      }

      // 3. Se autenticado, verificar onboarding completo
      final userId = _auth.currentUser!.uid;
      final onboardingCompleted = await _isOnboardingCompleted(userId);

      if (!onboardingCompleted) {
        // Configurar OnboardingController antes de navegar
        // O binding criará o controller se não existir
        Get.offAllNamed('/onboarding');
        
        // Configurar após navegação para garantir que o controller existe
        Future.microtask(() {
          try {
            final onboardingFlowController = Get.find<OnboardingFlowController>();
            onboardingFlowController.skipWelcome.value = true;
          } catch (e) {
            // Controller será criado pelo binding na próxima frame
            debugPrint('⚠️ OnboardingFlowController não encontrado, será criado pelo binding');
          }
        });
      } else {
        _navigateToHome();
      }
    } on TimeoutException {
      // Timeout na verificação do Firestore
      errorMessage.value = 'Verifique sua conexão com a internet';
      showRetryButton.value = true;
      isLoading.value = false;
    } on FirebaseException catch (e) {
      // Detectar erro de rede especificamente
      if (_isNetworkError(e)) {
        errorMessage.value = 'Verifique sua conexão com a internet';
        showRetryButton.value = true;
      } else {
        errorMessage.value = _handleFirestoreError(e);
        _navigateToAuth();
      }
      isLoading.value = false;
    } catch (e) {
      // Erro genérico
      errorMessage.value = 'Erro ao inicializar. Tente novamente.';
      showRetryButton.value = true;
      isLoading.value = false;
    }
  }

  // Verificações

  /// Verifica se há um usuário autenticado no Firebase Auth
  bool _isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Verifica se é o primeiro acesso do usuário no dispositivo
  Future<bool> _isFirstAccess() async {
    final prefs = await SharedPreferences.getInstance();
    // Se a chave não existe, retorna true (primeiro acesso)
    return prefs.getBool('isFirstAccess') ?? true;
  }

  /// Verifica se o usuário completou o onboarding no Firestore
  Future<bool> _isOnboardingCompleted(String userId) async {
    try {
      // Aplicar timeout de 30 segundos
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 30));

      if (!docSnapshot.exists) {
        return false;
      }

      final data = docSnapshot.data();
      // Se o campo não existe, retorna false
      return data?['onboardingCompleted'] ?? false;
    } on TimeoutException {
      // Re-lançar timeout para ser tratado no _navigate
      rethrow;
    } on FirebaseException {
      // Re-lançar erro do Firestore para ser tratado no _navigate
      rethrow;
    }
  }

  // Navegação auxiliar

  /// Navega para a tela de onboarding
  void _navigateToOnboarding() {
    Get.offAllNamed('/onboarding');
  }

  /// Navega para a tela de autenticação
  void _navigateToAuth() {
    Get.offAllNamed('/auth');
  }

  /// Navega para a tela principal
  void _navigateToHome() {
    Get.offAllNamed('/home');
  }

  // Handlers de erro

  /// Verifica se o erro do Firebase é relacionado à rede
  bool _isNetworkError(FirebaseException e) {
    return e.code == 'unavailable' || 
           e.code == 'deadline-exceeded' ||
           e.message?.toLowerCase().contains('network') == true;
  }
  
  /// Handler de erros do Firestore (padronizado)
  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
  }
}
