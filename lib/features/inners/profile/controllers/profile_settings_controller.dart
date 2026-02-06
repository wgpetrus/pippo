import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// ProfileSettingsController - Manages user settings
///
/// Responsibility: Manage user settings (notifications, learning controls)
class ProfileSettingsController extends GetxController {
  // Firebase Instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Settings States
  final soundEffects = true.obs;
  final listeningExercises = true.obs;
  final speakingExercises = true.obs;
  final practiceReminders = false.obs;
  final reminderTime = '18:00'.obs;
  final leaderboardUpdates = true.obs;
  final friendActivity = true.obs;
  final dailyGoal = 10.obs;

  // Métodos públicos

  /// Carrega configurações do usuário do Firestore
  Future<void> loadSettings() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      final settingsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (settingsDoc.exists) {
        final data = settingsDoc.data() as Map<String, dynamic>;

        // Som e Exercícios
        soundEffects.value = data['soundEffects'] ?? true;
        listeningExercises.value = data['listeningExercises'] ?? true;
        speakingExercises.value = data['speakingExercises'] ?? true;

        // Notificações
        practiceReminders.value = data['practiceReminders'] ?? false;
        reminderTime.value = data['reminderTime'] ?? '18:00';
        leaderboardUpdates.value = data['leaderboardUpdates'] ?? true;
        friendActivity.value = data['friendActivity'] ?? true;

        // Meta diária
        dailyGoal.value = data['dailyGoal'] ?? 10;
      }
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar configurações. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza uma configuração específica
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set({key: value}, SetOptions(merge: true));

      // Atualizar estado local
      switch (key) {
        case 'soundEffects':
          soundEffects.value = value as bool;
          break;
        case 'listeningExercises':
          listeningExercises.value = value as bool;
          break;
        case 'speakingExercises':
          speakingExercises.value = value as bool;
          break;
        case 'practiceReminders':
          practiceReminders.value = value as bool;
          break;
        case 'reminderTime':
          reminderTime.value = value as String;
          break;
        case 'leaderboardUpdates':
          leaderboardUpdates.value = value as bool;
          break;
        case 'friendActivity':
          friendActivity.value = value as bool;
          break;
        case 'dailyGoal':
          dailyGoal.value = value as int;
          break;
      }
    } on FirebaseException catch (e) {
      errorMessage.value = _handleFirestoreError(e);
    } catch (e) {
      errorMessage.value = 'Erro ao atualizar configuração. Tente novamente.';
    }
  }

  // Error Handlers

  /// Trata erros do Firestore com mensagens amigáveis em português
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
      case 'failed-precondition':
        return 'Operação não permitida no estado atual. Tente novamente.';
      case 'aborted':
        return 'Operação cancelada. Tente novamente.';
      case 'out-of-range':
        return 'Erro: valor fora do intervalo permitido. Verifique os dados.';
      case 'unimplemented':
        return 'Operação não implementada.';
      case 'internal':
        return 'Erro interno do servidor. Tente novamente em alguns instantes.';
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'not-found':
        return 'Recurso não encontrado. Verifique os dados e tente novamente.';
      case 'already-exists':
        return 'Recurso já existe.';
      case 'cancelled':
        return 'Operação cancelada.';
      case 'data-loss':
        return 'Erro de integridade de dados.';
      case 'invalid-argument':
        return 'Erro: argumento inválido. Verifique os dados e tente novamente.';
      default:
        return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
    }
  }
}
