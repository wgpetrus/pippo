import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';

class GemsController extends GetxController {
  // Dependency Injection com valores padrão (backward compatible)
  GemsController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Carregar dados ao inicializar
    loadGems();
  }

  final gems = 0.obs;
  final totalGemsEarned = 0.obs;
  final totalGemsSpent = 0.obs;

  DateTime? _gemMultiplierUntil;

  bool get hasGemMultiplier =>
      _gemMultiplierUntil != null &&
      DateTime.now().isBefore(_gemMultiplierUntil!);

  DateTime? get gemMultiplierUntil => _gemMultiplierUntil;

  String getGemMultiplierTimeRemaining() {
    if (_gemMultiplierUntil == null) return '';

    final now = DateTime.now();
    if (now.isAfter(_gemMultiplierUntil!)) return '';

    final diff = _gemMultiplierUntil!.difference(now);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}min restantes';
    } else {
      return '${diff.inHours}h restantes';
    }
  }

  Future<void> loadGems() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      String? courseId;

      // Tentar 3 vezes com delay para dar tempo do Firestore indexar
      for (int attempt = 1; attempt <= 3; attempt++) {
        final coursesSnapshot = await _retryOperation(
          () => _firestore
              .collection('users')
              .doc(userId)
              .collection('courses')
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get()
              .timeout(const Duration(seconds: 30)),
        );

        if (coursesSnapshot.docs.isNotEmpty) {
          courseId = coursesSnapshot.docs.first.id;
          break;
        }

        // Se não encontrou e não é a última tentativa, aguardar
        if (attempt < 3) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }

      // Se ainda não encontrou curso ativo, buscar qualquer curso
      if (courseId == null) {
        final allCoursesSnapshot = await _retryOperation(
          () => _firestore
              .collection('users')
              .doc(userId)
              .collection('courses')
              .limit(1)
              .get()
              .timeout(const Duration(seconds: 30)),
        );

        if (allCoursesSnapshot.docs.isNotEmpty) {
          courseId = allCoursesSnapshot.docs.first.id;
          
          // Marcar este curso como ativo
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('courses')
              .doc(courseId)
              .update({'isActive': true});
        } else {
          if (kDebugMode) {
            debugPrint('⚠️ Nenhum curso encontrado para o usuário');
          }
          return;
        }
      }

      final doc = await _retryOperation(
        () => _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(courseId)
            .collection('stats')
            .doc('gamification')
            .get()
            .timeout(const Duration(seconds: 30)),
      );

      if (!doc.exists) {
        await _createInitialGems(userId, courseId);
        return;
      }

      final data = doc.data()!;
      final gemsData = data['gems'] as Map<String, dynamic>? ?? {};

      gems.value = gemsData['gems'] ?? 0;
      totalGemsEarned.value = gemsData['totalGemsEarned'] ?? 0;
      totalGemsSpent.value = gemsData['totalGemsSpent'] ?? 0;
      _gemMultiplierUntil = _timestampToDateTime(
        gemsData['gemMultiplierUntil'],
      );
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar gems. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addGems(int amount) async {
    if (amount < 0) {
      throw Exception('Cannot add negative gems');
    }

    final gemsToAdd = hasGemMultiplier ? amount * 2 : amount;

    gems.value += gemsToAdd;
    totalGemsEarned.value += gemsToAdd;

    // Salvar gems no Firestore
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await _saveGems(userId);
      } on TimeoutException {
        errorMessage.value =
            'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
        // Reverter valores locais em caso de erro
        gems.value -= gemsToAdd;
        totalGemsEarned.value -= gemsToAdd;
      } on FirebaseException catch (e) {
        errorMessage.value = _handleFirestoreError(e);
        // Reverter valores locais em caso de erro
        gems.value -= gemsToAdd;
        totalGemsEarned.value -= gemsToAdd;
      } catch (e) {
        errorMessage.value = 'Erro ao salvar gems. Tente novamente.';
        // Reverter valores locais em caso de erro
        gems.value -= gemsToAdd;
        totalGemsEarned.value -= gemsToAdd;
      }
    }
  }

  Future<void> spendGems(int amount) async {
    if (gems.value < amount) {
      errorMessage.value =
          'Você precisa de ${amount - gems.value} gemas a mais.';
      return;
    }

    gems.value -= amount;
    totalGemsSpent.value += amount;

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await _saveGems(userId);
      } on TimeoutException {
        errorMessage.value =
            'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
        // Reverter valores locais em caso de erro
        gems.value += amount;
        totalGemsSpent.value -= amount;
      } on FirebaseException catch (e) {
        errorMessage.value = _handleFirestoreError(e);
        // Reverter valores locais em caso de erro
        gems.value += amount;
        totalGemsSpent.value -= amount;
      } catch (e) {
        errorMessage.value = 'Erro ao salvar gems. Tente novamente.';
        // Reverter valores locais em caso de erro
        gems.value += amount;
        totalGemsSpent.value -= amount;
      }
    }
  }

  Future<void> activateGemMultiplier(int minutes) async {
    final previousMultiplier = _gemMultiplierUntil;
    _gemMultiplierUntil = DateTime.now().add(Duration(minutes: minutes));

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await _saveGems(userId);
      } on TimeoutException {
        errorMessage.value =
            'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
        // Reverter valor em caso de erro
        _gemMultiplierUntil = previousMultiplier;
      } on FirebaseException catch (e) {
        errorMessage.value = _handleFirestoreError(e);
        // Reverter valor em caso de erro
        _gemMultiplierUntil = previousMultiplier;
      } catch (e) {
        errorMessage.value = 'Erro ao ativar multiplicador. Tente novamente.';
        // Reverter valor em caso de erro
        _gemMultiplierUntil = previousMultiplier;
      }
    }
  }

  Future<void> _createInitialGems(String userId, String courseId) async {
    // CORREÇÃO: Verificar se documento já existe antes de criar
    // Isso evita sobrescrever dados existentes ao reiniciar o app
    final doc = await _retryOperation(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .get()
          .timeout(const Duration(seconds: 30)),
    );
    
    // Se já existe, apenas carregar (não sobrescrever)
    if (doc.exists) {
      final data = doc.data()!;
      final gemsData = data['gems'] as Map<String, dynamic>? ?? {};
      
      // Se tem dados de gems, carregar
      if (gemsData.isNotEmpty) {
        gems.value = gemsData['gems'] ?? 0;
        totalGemsEarned.value = gemsData['totalGemsEarned'] ?? 0;
        totalGemsSpent.value = gemsData['totalGemsSpent'] ?? 0;
        _gemMultiplierUntil = _timestampToDateTime(
          gemsData['gemMultiplierUntil'],
        );
        
        if (kDebugMode) {
          debugPrint('✅ Gems carregadas do Firestore: ${gems.value} gems');
        }
        return;
      }
    }
    
    // Se não existe ou está vazio, criar valores iniciais
    await _retryOperation(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .set({
            'gems': {
              'gems': 0,
              'totalGemsEarned': 0,
              'totalGemsSpent': 0,
              'gemMultiplierUntil': null,
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 30)),
    );

    if (kDebugMode) {
      debugPrint('🆕 Gems iniciais criadas no Firestore');
    }
    
    await loadGems();
  }

  Future<void> _saveGems(String userId) async {
    final coursesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 30));

    if (coursesSnapshot.docs.isEmpty) {
      throw Exception('Nenhum curso ativo encontrado.');
    }

    final courseId = coursesSnapshot.docs.first.id;

    await _retryOperation(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .update({
            'gems': {
              'gems': gems.value,
              'totalGemsEarned': totalGemsEarned.value,
              'totalGemsSpent': totalGemsSpent.value,
              'gemMultiplierUntil': _gemMultiplierUntil != null
                  ? _dateTimeToTimestamp(_gemMultiplierUntil!)
                  : null,
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 30)),
    );
  }

  DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Timestamp _dateTimeToTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
  }

  String _handleFirestoreError(FirebaseException e) {
    return ErrorHandler.getFirestoreErrorMessage(e);
  }

  Future<T> _retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) rethrow;

        await Future.delayed(Duration(seconds: pow(2, attempts - 1).toInt()));
      }
    }

    throw Exception('Operation failed after $maxAttempts attempts');
  }

  @visibleForTesting
  void setGemMultiplierUntil(DateTime? date) {
    _gemMultiplierUntil = date;
  }

  @visibleForTesting
  DateTime? getGemMultiplierUntil() {
    return _gemMultiplierUntil;
  }
}
