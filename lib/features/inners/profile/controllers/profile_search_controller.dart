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

  // Lifecycle
  @override
  void onClose() {
    // Limpar listas
    searchResults.clear();

    // Resetar estados
    isLoading.value = false;
    errorMessage.value = '';
    isSearching.value = false;

    super.onClose();
  }

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
        errorMessage.value = 'error_unauthenticated'.tr;
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
        errorMessage.value = 'error_no_users_found'.tr;
      }
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'error_generic'.tr;
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
}
