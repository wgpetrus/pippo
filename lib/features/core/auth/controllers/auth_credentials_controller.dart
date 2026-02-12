// Dart SDK
import 'dart:async';

// Flutter
import 'package:flutter/foundation.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Imports locais
import '../../../../shared/utils/error_handler.dart';

/// Controller de credenciais de autenticação (email/senha)
class AuthCredentialsController extends GetxController {
  // Dependency Injection com valores padrão (backward compatible)
  AuthCredentialsController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Firebase instances
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Lifecycle

  @override
  void onClose() {
    // Resetar estados
    isLoading.value = false;
    errorMessage.value = '';

    super.onClose();
  }

  // Validadores

  /// Valida email (retorna mensagem de erro ou null se válido)
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'error_email_required'.tr;
    if (!GetUtils.isEmail(value)) return 'error_email_invalid'.tr;
    return null;
  }

  /// Valida senha (retorna mensagem de erro ou null se válido)
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'error_password_required'.tr;
    if (value.length < 6) return 'error_password_min_length'.tr;
    return null;
  }

  // Métodos públicos

  /// Realiza login com email e senha
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // VERIFICAR ANTES DE AUTENTICAR: Se email existe no Firestore com provider Google
      if (kDebugMode) {
        debugPrint('🔍 Verificando se email $email já existe no Firestore');
      }
      
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 30));
      
      if (emailQuery.docs.isNotEmpty) {
        // Email já existe - verificar provider
        final existingUserData = emailQuery.docs.first.data();
        final existingProvider = existingUserData['authProvider'] as String?;
        
        if (kDebugMode) {
          debugPrint('⚠️ Email já existe com provider: $existingProvider');
        }
        
        if (existingProvider == 'google') {
          // Email já existe com login do Google - BLOQUEAR
          errorMessage.value = 'Já existe uma conta com este e-mail usando login do Google. Por favor, faça login com Google.';
          
          if (kDebugMode) {
            debugPrint('🚫 Login com email/senha bloqueado - email já tem conta Google');
          }
          
          return;
        }
        // Se provider é 'email', pode continuar
      }
      
      // Autenticar via Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Buscar documento do usuário no Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get()
          .timeout(const Duration(seconds: 30));

      if (!userDoc.exists) {
        // Documento não existe - criar documento básico e redirecionar para onboarding
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'id': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'authProvider': 'email',
          'onboardingCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 30));
        
        // Navegar para onboarding com argumento skipWelcome
        Get.offAllNamed('/onboarding', arguments: {'skipWelcome': true});
        return;
      }

      final userData = userDoc.data()!;
      final onboardingCompleted = userData['onboardingCompleted'] ?? false;

      if (!onboardingCompleted) {
        // Onboarding incompleto - navegar com argumento skipWelcome
        Get.offAllNamed('/onboarding', arguments: {'skipWelcome': true});
      } else {
        // Onboarding completo - atualizar lastActiveAt e navegar para home
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
          'lastActiveAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 30));

        Get.offAllNamed('/home');
      }
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseAuthException catch (e) {
      errorMessage.value = ErrorHandler.getLoginErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível fazer login. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Realiza registro com email e senha
  Future<void> register(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // VERIFICAR ANTES DE CRIAR: Se email já existe no Firestore
      if (kDebugMode) {
        debugPrint('🔍 Verificando se email $email já existe no Firestore');
      }
      
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 30));
      
      if (emailQuery.docs.isNotEmpty) {
        // Email já existe - verificar provider
        final existingUserData = emailQuery.docs.first.data();
        final existingProvider = existingUserData['authProvider'] as String?;
        
        if (kDebugMode) {
          debugPrint('⚠️ Email já existe com provider: $existingProvider');
        }
        
        if (existingProvider == 'google') {
          // Email já existe com login do Google - BLOQUEAR
          errorMessage.value = 'Já existe uma conta com este e-mail usando login do Google. Por favor, faça login com Google.';
          
          if (kDebugMode) {
            debugPrint('🚫 Registro com email/senha bloqueado - email já tem conta Google');
          }
          
          return;
        } else if (existingProvider == 'email') {
          // Email já existe com email/senha
          errorMessage.value = 'Este e-mail já está sendo usado por outra conta.';
          
          if (kDebugMode) {
            debugPrint('🚫 Registro bloqueado - email já cadastrado');
          }
          
          return;
        }
      }
      
      // Criar conta via Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Criar documento básico no Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'id': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'authProvider': 'email',
        'onboardingCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 30));

      // Navegar para onboarding com argumento skipWelcome
      Get.offAllNamed('/onboarding', arguments: {'skipWelcome': true});
    } on TimeoutException {
      errorMessage.value = 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseAuthException catch (e) {
      errorMessage.value = ErrorHandler.getRegisterErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível criar sua conta. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }
}
