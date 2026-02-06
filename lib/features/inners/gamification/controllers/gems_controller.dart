import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Controller de gems (moeda virtual)
///
/// Gerencia:
/// - Gems atuais
/// - Total ganho e gasto
/// - Gem multiplier temporário
class GemsController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados reativos - Gems
  final gems = 0.obs;
  final totalGemsEarned = 0.obs;
  final totalGemsSpent = 0.obs;

  // Estados internos (não reativos)
  DateTime? _gemMultiplierUntil;

  // Computed properties
  /// Verifica se gem multiplier está ativo
  bool get hasGemMultiplier =>
      _gemMultiplierUntil != null &&
      DateTime.now().isBefore(_gemMultiplierUntil!);

  /// Retorna o tempo de expiração do gem multiplier (null se não ativo)
  DateTime? get gemMultiplierUntil => _gemMultiplierUntil;

  /// Retorna tempo restante do gem multiplier formatado
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

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
  }

  // Métodos públicos
  /// Carrega gems do Firestore (do curso ativo)
  Future<void> loadGems() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // 1. Buscar curso ativo
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

      if (coursesSnapshot.docs.isEmpty) {
        errorMessage.value = 'Nenhum curso ativo encontrado.';
        return;
      }

      final courseId = coursesSnapshot.docs.first.id;

      // 2. Buscar stats do curso ativo
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
        // Criar documento inicial
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

  /// Adiciona gems e atualiza gems e totalGemsEarned atomicamente
  void addGems(int amount) {
    // Validar gems não negativas
    if (amount < 0) {
      throw Exception('Cannot add negative gems');
    }

    // Aplicar multiplicador se ativo (2×)
    final gemsToAdd = hasGemMultiplier ? amount * 2 : amount;

    // Atualizar gems e totalGemsEarned atomicamente
    gems.value += gemsToAdd;
    totalGemsEarned.value += gemsToAdd;
  }

  /// Gasta gems (compras na loja)
  Future<void> spendGems(int amount) async {
    // Validar gems suficientes
    if (gems.value < amount) {
      errorMessage.value =
          'Você precisa de ${amount - gems.value} gemas a mais.';
      return;
    }

    // Deduzir gems
    gems.value -= amount;
    totalGemsSpent.value += amount;

    // Salvar no Firestore
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveGems(userId);
    }
  }

  /// Ativa gem multiplier por X minutos
  Future<void> activateGemMultiplier(int minutes) async {
    _gemMultiplierUntil = DateTime.now().add(Duration(minutes: minutes));

    // Salvar no Firestore
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveGems(userId);
    }
  }

  // Métodos privados
  /// Cria gems inicial para novo curso
  Future<void> _createInitialGems(String userId, String courseId) async {
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

    await loadGems();
  }

  /// Salva gems no Firestore (no curso ativo)
  Future<void> _saveGems(String userId) async {
    // 1. Buscar curso ativo
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

    // 2. Salvar gems no curso ativo
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

  /// Converte Timestamp do Firestore para DateTime
  DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  /// Converte DateTime para Timestamp do Firestore
  Timestamp _dateTimeToTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
  }

  /// Handler de erros do Firestore
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
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'not-found':
        return 'Dados não encontrados.';
      case 'already-exists':
        return 'Recurso já existe.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }

  /// Retry logic com exponential backoff
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

  // Test Helpers
  void setGemMultiplierUntil(DateTime? date) {
    _gemMultiplierUntil = date;
  }

  DateTime? getGemMultiplierUntil() {
    return _gemMultiplierUntil;
  }
}
