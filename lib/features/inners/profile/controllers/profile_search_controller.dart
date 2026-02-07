import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';

/// ProfileSearchController - Manages user search functionality
///
/// Responsibility: Search users by username or name
class ProfileSearchController extends GetxController {
  // Firebase Instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Search States
  final searchQuery = ''.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;

  // Métodos públicos

  /// Busca usuários por username ou nome
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    errorMessage.value = '';
    searchQuery.value = query.trim().toLowerCase();

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null || currentUserId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Buscar por username (exato ou começa com)
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchQuery.value)
          .where('username', isLessThan: '${searchQuery.value}z')
          .limit(20)
          .get();

      // Buscar por nome (case-insensitive via campo searchName)
      final nameQuery = await _firestore
          .collection('users')
          .where('searchName', isGreaterThanOrEqualTo: searchQuery.value)
          .where('searchName', isLessThan: '${searchQuery.value}z')
          .limit(20)
          .get();

      // Combinar resultados e remover duplicatas
      final results = <String, Map<String, dynamic>>{};

      for (var doc in usernameQuery.docs) {
        if (doc.id != currentUserId) {
          results[doc.id] = {'userId': doc.id, ...doc.data()};
        }
      }

      for (var doc in nameQuery.docs) {
        if (doc.id != currentUserId && !results.containsKey(doc.id)) {
          results[doc.id] = {'userId': doc.id, ...doc.data()};
        }
      }

      searchResults.value = results.values.toList();

      if (searchResults.isEmpty) {
        errorMessage.value = 'Nenhum usuário encontrado.';
      }
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao buscar usuários. Tente novamente.';
    } finally {
      isSearching.value = false;
    }
  }

  /// Limpa resultados da busca
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    errorMessage.value = '';
  }

  // Handlers de erro

  /// Handler de erros do Firestore
  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
  }
}
