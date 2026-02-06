import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Controller de energia
///
/// Gerencia:
/// - Energia atual (máximo 5)
/// - Regeneração automática (1 a cada 30 min)
/// - Energia ilimitada temporária
class EnergyController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados reativos - Energy
  final currentEnergy = 5.obs;

  // Estados internos (não reativos)
  DateTime _lastEnergyRegenAt = DateTime.now();
  DateTime? _unlimitedEnergyUntil;

  // Computed properties
  /// Verifica se energia ilimitada está ativa
  bool get hasUnlimitedEnergy =>
      _unlimitedEnergyUntil != null &&
      DateTime.now().isBefore(_unlimitedEnergyUntil!);

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
  }

  // Métodos públicos
  /// Carrega energia do Firestore (do curso ativo)
  Future<void> loadEnergy() async {
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
        await _createInitialEnergy(userId, courseId);
        return;
      }

      final data = doc.data()!;
      final energyData = data['energy'] as Map<String, dynamic>? ?? {};

      currentEnergy.value = energyData['currentEnergy'] ?? 5;
      _lastEnergyRegenAt = _timestampToDateTime(
        energyData['lastEnergyRegenAt'],
      );
      _unlimitedEnergyUntil = _timestampToDateTime(
        energyData['unlimitedEnergyUntil'],
      );

      // Calcular regeneração após carregar
      _calculateEnergyRegeneration();
    } on TimeoutException {
      errorMessage.value =
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar energia. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Consome energia (chamado ao iniciar lição)
  Future<void> consumeEnergy(int amount) async {
    if (hasUnlimitedEnergy) return;

    if (currentEnergy.value >= amount) {
      currentEnergy.value -= amount;
      _lastEnergyRegenAt = DateTime.now();

      // Salvar no Firestore
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _saveEnergy(userId);
      }
    }
  }

  /// Regenera energia baseado no tempo passado
  void regenerateEnergy() {
    _calculateEnergyRegeneration();
  }

  /// Ativa energia ilimitada por X minutos
  Future<void> activateUnlimitedEnergy(int minutes) async {
    _unlimitedEnergyUntil = DateTime.now().add(Duration(minutes: minutes));

    // Salvar no Firestore
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveEnergy(userId);
    }
  }

  /// Recarrega energia completamente (compra na loja)
  Future<void> refillEnergy() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Calcular regeneração para ter valor atualizado
      _calculateEnergyRegeneration();

      // Validar se já está com energia máxima
      if (currentEnergy.value >= 5) {
        errorMessage.value = 'Você já está com energia máxima!';
        return;
      }

      // Obter userId
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Adicionar 5 energia (limitado ao máximo)
      final newEnergy = currentEnergy.value + 5;
      currentEnergy.value = newEnergy > 5 ? 5 : newEnergy;

      // Salvar no Firestore
      await _saveEnergy(userId);
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
      await loadEnergy();
    } catch (e) {
      errorMessage.value =
          'Erro ao recarregar energia. Tente novamente.';
      await loadEnergy();
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifica se pode iniciar lição (tem energia suficiente)
  bool canStartLesson() {
    if (hasUnlimitedEnergy) return true;
    _calculateEnergyRegeneration();
    return currentEnergy.value > 0;
  }

  /// Retorna tempo até próxima energia
  String getNextEnergyTime() {
    if (hasUnlimitedEnergy) return 'Ilimitada';
    if (currentEnergy.value >= 5) return 'Completa';

    final now = DateTime.now();
    final minutesSinceRegen = now.difference(_lastEnergyRegenAt).inMinutes;
    final minutesUntilNext = 30 - (minutesSinceRegen % 30);

    return '$minutesUntilNext min';
  }

  // Métodos privados
  /// Cria energia inicial para novo curso
  Future<void> _createInitialEnergy(String userId, String courseId) async {
    await _retryOperation(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .set({
            'energy': {
              'currentEnergy': 5,
              'maxEnergy': 5,
              'lastEnergyRegenAt': FieldValue.serverTimestamp(),
              'unlimitedEnergyUntil': null,
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 30)),
    );

    await loadEnergy();
  }

  /// Salva energia no Firestore (no curso ativo)
  Future<void> _saveEnergy(String userId) async {
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

    // 2. Salvar energia no curso ativo
    await _retryOperation(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('stats')
          .doc('gamification')
          .update({
            'energy': {
              'currentEnergy': currentEnergy.value,
              'maxEnergy': 5,
              'lastEnergyRegenAt': _dateTimeToTimestamp(_lastEnergyRegenAt),
              'unlimitedEnergyUntil': _unlimitedEnergyUntil != null
                  ? _dateTimeToTimestamp(_unlimitedEnergyUntil!)
                  : null,
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 30)),
    );
  }

  /// Calcula regeneração de energia baseado no tempo passado
  void _calculateEnergyRegeneration() {
    if (hasUnlimitedEnergy) return;
    if (currentEnergy.value >= 5) return;

    final now = DateTime.now();
    final minutesPassed = now.difference(_lastEnergyRegenAt).inMinutes;

    // Calcular energia a adicionar: 1 energia a cada 30 minutos
    final energiesToAdd = minutesPassed ~/ 30;

    if (energiesToAdd == 0) return;

    // Calcular nova energia (limitado ao máximo)
    final newEnergy = min(currentEnergy.value + energiesToAdd, 5);

    // Atualizar timestamp pelo tempo de energia realmente regenerada
    final minutesConsumed = (newEnergy - currentEnergy.value) * 30;
    _lastEnergyRegenAt = _lastEnergyRegenAt.add(
      Duration(minutes: minutesConsumed),
    );

    currentEnergy.value = newEnergy;
  }

  /// Converte Timestamp do Firestore para DateTime
  DateTime _timestampToDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
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
  void calculateEnergyRegenerationPublic() {
    _calculateEnergyRegeneration();
  }

  void consumeEnergyPublic() {
    if (hasUnlimitedEnergy) return;
    if (currentEnergy.value > 0) {
      currentEnergy.value--;
      _lastEnergyRegenAt = DateTime.now();
    }
  }

  void setLastEnergyRegenAt(DateTime date) {
    _lastEnergyRegenAt = date;
  }

  void setUnlimitedEnergyUntil(DateTime? date) {
    _unlimitedEnergyUntil = date;
  }

  DateTime getLastEnergyRegenAt() {
    return _lastEnergyRegenAt;
  }
}
