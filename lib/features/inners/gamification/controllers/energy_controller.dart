import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../shared/utils/error_handler.dart';

class EnergyController extends GetxController {
  // Dependency Injection com valores padrão (backward compatible)
  EnergyController({
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
    loadEnergy();
  }

  final currentEnergy = 5.obs;

  DateTime _lastEnergyRegenAt = DateTime.now();
  DateTime? _unlimitedEnergyUntil;

  bool get hasUnlimitedEnergy =>
      _unlimitedEnergyUntil != null &&
      DateTime.now().isBefore(_unlimitedEnergyUntil!);

  Future<void> loadEnergy() async {
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

  Future<void> consumeEnergy(int amount) async {
    if (hasUnlimitedEnergy) return;

    if (currentEnergy.value >= amount) {
      currentEnergy.value -= amount;
      _lastEnergyRegenAt = DateTime.now();

      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _saveEnergy(userId);
      }
    }
  }

  void regenerateEnergy() {
    _calculateEnergyRegeneration();
  }

  Future<void> activateUnlimitedEnergy(int minutes) async {
    _unlimitedEnergyUntil = DateTime.now().add(Duration(minutes: minutes));

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveEnergy(userId);
    }
  }

  Future<void> refillEnergy() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // CORREÇÃO: Verificar ANTES de calcular regeneração
      // Isso evita que energia regenerada naturalmente bloqueie a compra
      if (currentEnergy.value >= 5) {
        errorMessage.value = 'Você já está com energia máxima!';
        return;
      }

      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // CORREÇÃO: Encher completamente (5) em vez de adicionar 5
      // Comprar energia deve sempre encher até o máximo
      currentEnergy.value = 5;
      _lastEnergyRegenAt = DateTime.now();

      await _saveEnergy(userId);
      
      print('⚡ Energia recarregada com sucesso! Energia atual: ${currentEnergy.value}');
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

  bool canStartLesson() {
    if (hasUnlimitedEnergy) return true;
    _calculateEnergyRegeneration();
    return currentEnergy.value > 0;
  }

  String getNextEnergyTime() {
    if (hasUnlimitedEnergy) return 'Ilimitada';
    if (currentEnergy.value >= 5) return 'Completa';

    final now = DateTime.now();
    final minutesSinceRegen = now.difference(_lastEnergyRegenAt).inMinutes;
    final minutesUntilNext = 30 - (minutesSinceRegen % 30);

    return '$minutesUntilNext min';
  }

  Future<void> _createInitialEnergy(String userId, String courseId) async {
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
      final energyData = data['energy'] as Map<String, dynamic>? ?? {};
      
      // Se tem dados de energy, carregar
      if (energyData.isNotEmpty) {
        currentEnergy.value = energyData['currentEnergy'] ?? 5;
        _lastEnergyRegenAt = _timestampToDateTime(
          energyData['lastEnergyRegenAt'],
        );
        _unlimitedEnergyUntil = _timestampToDateTime(
          energyData['unlimitedEnergyUntil'],
        );
        
        _calculateEnergyRegeneration();
        
        if (kDebugMode) {
          debugPrint('✅ Energy carregada do Firestore: ${currentEnergy.value}/5');
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

    if (kDebugMode) {
      debugPrint('🆕 Energy inicial criada no Firestore');
    }
    
    await loadEnergy();
  }

  Future<void> _saveEnergy(String userId) async {
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

  void _calculateEnergyRegeneration() {
    if (hasUnlimitedEnergy) return;
    if (currentEnergy.value >= 5) return;

    final now = DateTime.now();
    final minutesPassed = now.difference(_lastEnergyRegenAt).inMinutes;

    final energiesToAdd = minutesPassed ~/ 30;

    if (energiesToAdd == 0) return;

    final newEnergy = min(currentEnergy.value + energiesToAdd, 5);

    final minutesConsumed = (newEnergy - currentEnergy.value) * 30;
    _lastEnergyRegenAt = _lastEnergyRegenAt.add(
      Duration(minutes: minutesConsumed),
    );

    currentEnergy.value = newEnergy;
  }

  DateTime _timestampToDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
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
  void calculateEnergyRegenerationPublic() {
    _calculateEnergyRegeneration();
  }

  @visibleForTesting
  void consumeEnergyPublic() {
    if (hasUnlimitedEnergy) return;
    if (currentEnergy.value > 0) {
      currentEnergy.value--;
      _lastEnergyRegenAt = DateTime.now();
    }
  }

  @visibleForTesting
  void setLastEnergyRegenAt(DateTime date) {
    _lastEnergyRegenAt = date;
  }

  @visibleForTesting
  void setUnlimitedEnergyUntil(DateTime? date) {
    _unlimitedEnergyUntil = date;
  }

  @visibleForTesting
  DateTime getLastEnergyRegenAt() {
    return _lastEnergyRegenAt;
  }
}
