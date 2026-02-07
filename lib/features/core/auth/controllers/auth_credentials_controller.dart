// Dart SDK
import 'dart:async';

// Flutter
import 'package:flutter/foundation.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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

  // Validadores

  /// Valida email (retorna mensagem de erro ou null se válido)
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório.';
    if (!GetUtils.isEmail(value)) return 'Por favor, insira um e-mail válido.';
    return null;
  }

  /// Valida senha (retorna mensagem de erro ou null se válido)
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória.';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
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
      errorMessage.value = _handleFirebaseLoginError(e);
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
      errorMessage.value = _handleFirebaseRegisterError(e);
    } catch (e) {
      errorMessage.value = 'Não foi possível criar sua conta. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos privados

  /// Handler de erros de login do Firebase Auth
  String _handleFirebaseLoginError(FirebaseAuthException e) {
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

  /// Handler de erros de registro do Firebase Auth
  String _handleFirebaseRegisterError(FirebaseAuthException e) {
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
}
