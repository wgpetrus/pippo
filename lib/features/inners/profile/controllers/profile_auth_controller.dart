// Flutter
import 'package:flutter/foundation.dart';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// ProfileAuthController - Manages authentication actions
///
/// Responsibility: Manage authentication actions (password, phone, delete account)
class ProfileAuthController extends GetxController {
  // Firebase Instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Phone States
  final phone = ''.obs;
  final phoneVerified = false.obs;
  final verificationId = ''.obs;

  // Métodos públicos

  /// Altera senha do usuário
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Reautenticar usuário
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Alterar senha
      await user.updatePassword(newPassword);

      Get.snackbar(
        'Sucesso',
        'Senha alterada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseAuthError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao alterar senha. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Vincula número de telefone
  Future<void> linkPhoneNumber(
    String phoneNumber,
    String verificationCode,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Criar credencial com código de verificação
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: verificationCode,
      );

      // Vincular telefone
      await user.linkWithCredential(credential);

      // Atualizar Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'phone': phoneNumber,
        'phoneVerified': true,
      });

      phone.value = phoneNumber;
      phoneVerified.value = true;

      Get.snackbar(
        'Sucesso',
        'Telefone vinculado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseAuthError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao vincular telefone. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Deleta conta do usuário
  Future<void> deleteAccount() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final userId = user.uid;

      // Reautenticar antes de deletar
      await _reauthenticateForDeletion();

      // Deletar subcoleções do Firestore
      await _deleteUserSubcollections(userId);

      // Deletar documento do usuário
      await _firestore.collection('users').doc(userId).delete();

      // Deletar conta do Firebase Auth
      await user.delete();

      // Navegar para tela de auth
      Get.offAllNamed('/auth');

      Get.snackbar(
        'Conta Deletada',
        'Sua conta foi deletada com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleFirebaseAuthError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao deletar conta. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos privados

  /// Deleta todas as subcoleções do usuário
  Future<void> _deleteUserSubcollections(String userId) async {
    try {
      // Deletar subcoleções principais
      await _deleteSubcollection(userId, 'following');
      await _deleteSubcollection(userId, 'followers');
      await _deleteSubcollection(userId, 'notifications');

      // Deletar stats com suas subcoleções
      await _deleteStatsSubcollection(userId);

      // Deletar courses com suas subcoleções
      await _deleteCoursesWithSubcollections(userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao deletar subcoleções: $e');
      }
    }
  }

  /// Deleta courses e suas subcoleções
  Future<void> _deleteCoursesWithSubcollections(String userId) async {
    try {
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      for (final courseDoc in coursesSnapshot.docs) {
        final courseId = courseDoc.id;

        // Deletar subcoleções do curso
        await _deleteCourseSubcollection(userId, courseId, 'sections');
        await _deleteCourseSubcollection(userId, courseId, 'lessons');
        await _deleteCourseSubcollection(userId, courseId, 'exercises');

        // Deletar stats do curso
        await _deleteCourseStatsSubcollection(userId, courseId);

        // Deletar documento do curso
        await courseDoc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao deletar courses: $e');
      }
    }
  }

  /// Deleta subcoleção de um curso
  Future<void> _deleteCourseSubcollection(
    String userId,
    String courseId,
    String subcollectionName,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection(subcollectionName)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao deletar $subcollectionName do curso: $e');
      }
    }
  }

  /// Deleta stats de um curso
  Future<void> _deleteCourseStatsSubcollection(
    String userId,
    String courseId,
  ) async {
    try {
      final statsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .get();

      for (final statsDoc in statsSnapshot.docs) {
        // Deletar subcoleções de stats (se houver)
        final daysSnapshot = await statsDoc.reference.collection('days').get();
        for (final dayDoc in daysSnapshot.docs) {
          await dayDoc.reference.delete();
        }

        await statsDoc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao deletar stats do curso: $e');
      }
    }
  }

  /// Deleta uma subcoleção
  Future<void> _deleteSubcollection(
    String userId,
    String subcollectionName,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(subcollectionName)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao deletar $subcollectionName: $e');
      }
    }
  }

  /// Deleta stats e suas subcoleções
  Future<void> _deleteStatsSubcollection(String userId) async {
    try {
      final statsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .get();

      for (final statsDoc in statsSnapshot.docs) {
        // Deletar subcoleções de stats
        final daysSnapshot = await statsDoc.reference.collection('days').get();
        for (final dayDoc in daysSnapshot.docs) {
          await dayDoc.reference.delete();
        }

        await statsDoc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao deletar stats: $e');
      }
    }
  }

  /// Reautentica usuário antes de deletar conta
  Future<void> _reauthenticateForDeletion() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // Se usuário tem email, pedir senha
    if (user.email != null) {
      // TODO: Implementar modal para pedir senha
      // Por enquanto, assumir que usuário já está autenticado recentemente
      return;
    }

    // Se usuário tem apenas provedores sociais, reautenticar com provedor
    for (final providerData in user.providerData) {
      if (providerData.providerId == 'google.com') {
        // TODO: Implementar reautenticação com Google
        return;
      }
      if (providerData.providerId == 'facebook.com') {
        // TODO: Implementar reautenticação com Facebook
        return;
      }
    }
  }

  // Handlers de erro

  /// Valida senha atual
  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha atual é obrigatória.';
    }
    return null;
  }

  /// Valida nova senha
  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nova senha é obrigatória.';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  /// Valida confirmação de senha
  String? validateConfirmPassword(String? value, String newPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória.';
    }
    if (value != newPassword) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  /// Valida número de telefone
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Número de telefone é obrigatório.';
    }
    // Remove formatação
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return 'Número de telefone inválido.';
    }
    return null;
  }

  // Handlers de erro

  /// Handler de erros do Firebase Auth
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Senha atual incorreta.';
      case 'weak-password':
        return 'A nova senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'requires-recent-login':
        return 'Por segurança, faça login novamente antes de alterar a senha.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'invalid-credential':
        return 'Credenciais inválidas.';
      case 'invalid-verification-code':
        return 'Código de verificação inválido.';
      case 'invalid-verification-id':
        return 'ID de verificação inválido.';
      case 'credential-already-in-use':
        return 'Este telefone já está vinculado a outra conta.';
      case 'provider-already-linked':
        return 'Este método de autenticação já está vinculado.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      default:
        return 'Erro de autenticação. Tente novamente.';
    }
  }
}
