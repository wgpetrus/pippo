import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../inners/gamification/controllers/gamification_controller.dart';

/// Controller para gerenciar o fluxo de lições e exercícios
class LessonController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  // Dependências
  late final GamificationController _gamificationController;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados da lição (lesson data)
  final currentLesson = Rx<Map<String, dynamic>?>(null);
  final currentExercises = <Map<String, dynamic>>[].obs;
  final currentExerciseIndex = 0.obs;

  // Estados de execução (execution states)
  final hearts = 3.obs;
  final correctAnswers = 0.obs;
  final totalAnswers = 0.obs;
  final startTime = Rx<DateTime?>(null);
  final pauseTime = Rx<DateTime?>(null);
  final accumulatedTime = 0.obs; // Tempo acumulado em milissegundos

  // Estados de feedback (feedback states)
  final showFeedback = false.obs;
  final isCorrectAnswer = false.obs;
  final correctAnswerText = ''.obs;

  // Getters
  double get progress => currentExercises.isNotEmpty
      ? currentExerciseIndex.value / currentExercises.length
      : 0.0;

  double get accuracy => totalAnswers.value > 0
      ? (correctAnswers.value / totalAnswers.value) * 100
      : 0.0;

  bool get isPerfect => totalAnswers.value > 0 && accuracy == 100.0;

  // Concurrency prevention
  bool _isLessonStarting = false;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _gamificationController = Get.find<GamificationController>();
  }

  @override
  void onClose() {
    // Reset dos estados da lição ao fechar o controller
    _resetLessonState();
    
    // Reset da flag de concorrência
    _isLessonStarting = false;
    
    super.onClose();
  }

  // Métodos públicos
  
  /// Inicia uma lição seguindo a ordem CRÍTICA de operações
  /// 
  /// Ordem obrigatória:
  /// 1. Validar lição desbloqueada
  /// 2. Validar energia disponível (ou ilimitada ativa)
  /// 3. Consumir energia (operação atômica)
  /// 4. Inicializar estado da lição (hearts=3, counters=0, startTime)
  /// 5. Carregar exercícios do Firestore
  /// 6. Navegar para primeiro exercício
  /// 
  /// Em caso de erro: exibe mensagem, NÃO consome energia
  /// Previne múltiplos inícios simultâneos
  Future<void> startLesson(String courseId, String lessonId) async {
    // Prevenir múltiplos inícios simultâneos (concurrency prevention)
    if (_isLessonStarting) {
      errorMessage.value = 'Uma lição já está sendo iniciada. Aguarde.';
      return;
    }

    _isLessonStarting = true;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Step 1: Validar lição desbloqueada
      final lessonIdInt = int.tryParse(lessonId);
      if (lessonIdInt == null) {
        errorMessage.value = 'ID de lição inválido.';
        return;
      }

      final isUnlocked = await _isLessonUnlocked(courseId, lessonIdInt);
      if (!isUnlocked) {
        errorMessage.value = 'Complete a lição anterior para desbloquear esta.';
        return;
      }

      // Step 2: Validar energia disponível (ou ilimitada ativa)
      final hasUnlimited = _hasUnlimitedEnergy();
      if (!hasUnlimited) {
        final hasEnergy = await _hasEnergy();
        if (!hasEnergy) {
          errorMessage.value = 'Você não tem energia suficiente. Aguarde a regeneração ou compre mais energia.';
          return;
        }
      }

      // Step 3: Consumir energia (operação atômica)
      // Apenas consome se não tiver energia ilimitada
      if (!hasUnlimited) {
        try {
          await _consumeEnergy();
        } catch (e) {
          // Erro ao consumir energia - NÃO prossegue
          errorMessage.value = 'Não foi possível consumir energia. Tente novamente.';
          return;
        }
      }

      // Step 4: Inicializar estado da lição
      hearts.value = 3;
      correctAnswers.value = 0;
      totalAnswers.value = 0;
      startTime.value = DateTime.now();
      pauseTime.value = null;
      accumulatedTime.value = 0;
      currentExerciseIndex.value = 0;
      
      // Reset feedback states
      showFeedback.value = false;
      isCorrectAnswer.value = false;
      correctAnswerText.value = '';

      // Step 5: Carregar exercícios do Firestore
      try {
        await _loadLessonData(courseId, lessonId);
      } catch (e) {
        // Erro ao carregar dados - energia já foi consumida, mas não há como refundar
        // Apenas exibe erro
        errorMessage.value = 'Não foi possível carregar os exercícios. Tente novamente.';
        _resetLessonState();
        return;
      }

      // Validar que todos os exercícios têm dados válidos
      if (!_validateExerciseData()) {
        errorMessage.value = 'Dados dos exercícios inválidos. Tente novamente.';
        _resetLessonState();
        return;
      }

      // Step 6: Navegar para primeiro exercício
      // A navegação será feita pela view após sucesso
      // Controller apenas sinaliza que está pronto via isLoading = false
      
    } catch (e) {
      // Em caso de erro inesperado, exibe mensagem
      errorMessage.value = 'Não foi possível carregar a lição. Tente novamente.';
      
      // Reset estados em caso de erro
      _resetLessonState();
    } finally {
      _isLessonStarting = false;
      isLoading.value = false;
    }
  }

  /// Verifica se o usuário pode iniciar uma lição
  /// Retorna true se pode iniciar, false caso contrário
  bool canStartLesson() {
    return _gamificationController.canStartLesson();
  }

  /// Retoma uma lição em progresso sem consumir energia adicional
  /// 
  /// Carrega progresso da lição do Firestore e restaura:
  /// - currentExerciseIndex
  /// - hearts, correctAnswers, totalAnswers
  /// - accumulatedTime
  /// 
  /// NÃO consome energia adicional
  /// Continua do exercício salvo
  Future<void> resumeLesson(String courseId, String lessonId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'Usuário não autenticado.';
        return;
      }

      // Carregar progresso salvo do Firestore
      final progressDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .doc(lessonId)
          .get();

      if (!progressDoc.exists) {
        errorMessage.value = 'Progresso da lição não encontrado.';
        return;
      }

      final progressData = progressDoc.data()!;
      final status = progressData['status'] as String?;

      // Verificar se lição está em progresso
      if (status != 'in_progress') {
        errorMessage.value = 'Esta lição não está em progresso.';
        return;
      }

      // Carregar dados da lição e exercícios
      await _loadLessonData(courseId, lessonId);

      // Restaurar estado da lição do progresso salvo
      currentExerciseIndex.value = progressData['currentExerciseIndex'] as int? ?? 0;
      hearts.value = progressData['hearts'] as int? ?? 3;
      correctAnswers.value = progressData['correctAnswers'] as int? ?? 0;
      totalAnswers.value = progressData['totalAnswers'] as int? ?? 0;
      accumulatedTime.value = progressData['accumulatedTime'] as int? ?? 0;

      // Reiniciar startTime para continuar rastreamento de tempo
      startTime.value = DateTime.now();
      pauseTime.value = null;

      // Reset feedback states
      showFeedback.value = false;
      isCorrectAnswer.value = false;
      correctAnswerText.value = '';

      // NÃO consome energia adicional - apenas restaura estado
      // A navegação será feita pela view após sucesso

    } catch (e) {
      errorMessage.value = 'Não foi possível retomar a lição. Tente novamente.';
      _resetLessonState();
    } finally {
      isLoading.value = false;
    }
  }

  /// Submete uma resposta do usuário para o exercício atual
  /// 
  /// Ordem de operações:
  /// 1. Valida resposta usando método apropriado
  /// 2. Incrementa totalAnswers
  /// 3. Se correto: incrementa correctAnswers
  /// 4. Se incorreto: decrementa hearts ANTES de mostrar feedback
  /// 5. Verifica se hearts = 0 (trigger failLesson())
  /// 6. Mostra feedback (correto/incorreto)
  /// 7. Se último exercício e hearts > 0: trigger completeLesson()
  Future<void> submitAnswer(dynamic userAnswer, String exerciseType) async {
    try {
      // Obter exercício atual
      if (currentExerciseIndex.value >= currentExercises.length) {
        errorMessage.value = 'Exercício não encontrado.';
        return;
      }

      final currentExercise = currentExercises[currentExerciseIndex.value];
      
      // Step 1: Validar resposta usando método apropriado
      bool isCorrect = false;
      String correctAnswer = '';

      switch (exerciseType) {
        case 'image':
          final selectedImageId = userAnswer as String;
          final options = currentExercise['options'] as List;
          final correctOption = options.firstWhere((opt) => opt['isCorrect'] == true);
          final correctImageId = correctOption['id'] as String;
          correctAnswer = correctImageId;
          isCorrect = _validateImageExercise(selectedImageId, correctImageId);
          break;

        case 'translation':
          final selectedTranslation = userAnswer as String;
          final options = currentExercise['options'] as List;
          final correctOption = options.firstWhere((opt) => opt['isCorrect'] == true);
          final correctTranslationText = correctOption['text'] as String;
          correctAnswer = correctTranslationText;
          isCorrect = _validateTranslationExercise(selectedTranslation, correctTranslationText);
          break;

        case 'word_order':
          final userOrder = userAnswer as List<String>;
          final correctOrder = currentExercise['correctOrder'] as List<String>;
          correctAnswer = correctOrder.join(' ');
          isCorrect = _validateWordOrderExercise(userOrder, correctOrder);
          break;

        case 'match':
          final userPairs = userAnswer as Map<String, String>;
          final pairs = currentExercise['pairs'] as List;
          final correctPairs = <String, String>{};
          for (final pair in pairs) {
            correctPairs[pair['audio'] as String] = pair['text'] as String;
          }
          correctAnswer = correctPairs.toString();
          isCorrect = _validateMatchExercise(userPairs, correctPairs);
          break;

        default:
          errorMessage.value = 'Tipo de exercício desconhecido.';
          return;
      }

      // Step 2: Incrementa totalAnswers
      totalAnswers.value++;

      // Step 3: Se correto: incrementa correctAnswers
      if (isCorrect) {
        correctAnswers.value++;
      } else {
        // Step 4: Se incorreto: decrementa hearts ANTES de mostrar feedback
        hearts.value--;
        
        // Step 5: Verifica se hearts = 0 (trigger failLesson())
        if (hearts.value <= 0) {
          await failLesson();
          return;
        }
      }

      // Step 6: Mostra feedback (correto/incorreto)
      isCorrectAnswer.value = isCorrect;
      correctAnswerText.value = correctAnswer;
      showFeedback.value = true;

      // Step 7: Se último exercício e hearts > 0: trigger completeLesson()
      final isLastExercise = currentExerciseIndex.value >= currentExercises.length - 1;
      if (isLastExercise && hearts.value > 0) {
        // Aguarda um momento para mostrar feedback antes de completar
        await Future.delayed(const Duration(milliseconds: 500));
        await completeLesson();
      }
    } catch (e) {
      errorMessage.value = 'Erro ao processar resposta. Tente novamente.';
    }
  }

  /// Registra uma resposta do usuário
  void recordAnswer({required bool isCorrect}) {
    totalAnswers.value++;
    if (isCorrect) {
      correctAnswers.value++;
    }
  }

  /// Avança para o próximo exercício
  void nextExercise() {
    if (currentExerciseIndex.value < currentExercises.length) {
      currentExerciseIndex.value++;
    }
    
    // Reset feedback states ao avançar
    showFeedback.value = false;
    isCorrectAnswer.value = false;
    correctAnswerText.value = '';
  }

  /// Completa a lição seguindo a ordem CRÍTICA de operações
  /// 
  /// Ordem obrigatória:
  /// 1. Calcular recompensas (_calculateTotalXP, _calculateTotalGems)
  /// 2. Distribuir XP (_distributeXP)
  /// 3. Adicionar gems ao totalGems
  /// 4. Verificar e executar level up (_checkAndLevelUp)
  /// 5. Atualizar streak (apenas se primeira lição hoje, _updateStreak)
  /// 6. Salvar progresso da lição (_saveLessonProgress)
  /// 7. Atualizar histórico diário (_updateDailyHistory)
  /// 8. Atualizar desafios (_updateChallenges)
  /// 9. Desbloquear próxima lição (_unlockNextLesson)
  /// 10. Navegar para tela de conclusão
  /// 
  /// Tratamento de erros: retry até 3 vezes com exponential backoff
  /// Se todas falharem: cache localmente, sincroniza na próxima abertura
  Future<void> completeLesson() async {
    isLoading.value = true;
    errorMessage.value = '';

    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        // Step 1: Calcular recompensas
        final totalXp = await _calculateTotalXP();
        final totalGems = _calculateTotalGems();
        
        // Step 2: Distribuir XP (atomic operation)
        await _distributeXP(totalXp);
        
        // Step 3: Adicionar gems ao totalGems
        await _addGems(totalGems);
        
        // Step 4: Verificar e executar level up
        final leveledUp = await _checkAndLevelUp();
        
        // Step 5: Atualizar streak (apenas se primeira lição hoje)
        final isFirstToday = await _isFirstLessonToday();
        if (isFirstToday) {
          await _updateStreak();
        }
        
        // Step 6: Salvar progresso da lição
        final courseId = currentLesson.value?['courseId'] as String? ?? '';
        final lessonId = currentLesson.value?['id'] as String? ?? '';
        await _saveLessonProgress(courseId, lessonId, totalXp, totalGems);
        
        // Step 7: Atualizar histórico diário
        final timeSpent = _calculateTimeSpent();
        await _updateDailyHistory(totalXp, totalGems, timeSpent);
        
        // Step 8: Atualizar desafios
        await _updateChallenges();
        
        // Step 9: Desbloquear próxima lição
        await _unlockNextLesson(courseId, lessonId);
        
        // Step 10: Navegação será feita pela view
        // Controller apenas sinaliza sucesso via isLoading = false
        
        // Sucesso - sair do loop de retry
        break;
        
      } on FirebaseException catch (e) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          // Todas as tentativas falharam - cache localmente
          await _cacheProgressLocally();
          errorMessage.value = 'Não foi possível salvar seu progresso. Tentaremos novamente automaticamente.';
        } else {
          // Aguardar antes de tentar novamente (exponential backoff)
          // 500ms, 1000ms, 1500ms
          final delayMs = 500 * retryCount;
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      } catch (e) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          // Todas as tentativas falharam - cache localmente
          await _cacheProgressLocally();
          errorMessage.value = 'Não foi possível salvar seu progresso. Tentaremos novamente automaticamente.';
        } else {
          // Aguardar antes de tentar novamente (exponential backoff)
          final delayMs = 500 * retryCount;
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
    }
    
    // Reset dos estados da lição
    _resetLessonState();
    isLoading.value = false;
  }

  /// Falha a lição quando hearts chegam a 0
  /// 
  /// Consequências:
  /// - Define estado da lição como failed
  /// - Exibe tela de falha
  /// - Premia zero recompensas (XP = 0, gems = 0)
  /// - NÃO reembolsa energia consumida
  /// - Navega para tela de falha
  Future<void> failLesson() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Define estado como failed
      // Não há recompensas (XP = 0, gems = 0)
      // Energia NÃO é reembolsada
      
      // A navegação para tela de falha será feita pela view
      // Controller apenas sinaliza que a lição falhou
      
      // Reset dos estados da lição
      _resetLessonState();
    } catch (e) {
      errorMessage.value = 'Erro ao processar falha da lição.';
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos privados - Carregamento de dados
  
  /// Valida que todos os exercícios têm dados válidos
  /// Retorna true se todos os exercícios são válidos, false caso contrário
  bool _validateExerciseData() {
    if (currentExercises.isEmpty) return false;
    
    for (final exercise in currentExercises) {
      final type = exercise['type'] as String?;
      final order = exercise['order'] as int?;
      
      // Validar tipo de exercício
      if (type == null || !['image', 'translation', 'word_order', 'match'].contains(type)) {
        return false;
      }
      
      // Validar ordem
      if (order == null || order < 0) {
        return false;
      }
      
      // Validar dados específicos por tipo
      switch (type) {
        case 'image':
          final options = exercise['options'] as List?;
          if (options == null || options.length != 4) return false;
          if (!options.any((opt) => opt['isCorrect'] == true)) return false;
          break;
          
        case 'translation':
          final options = exercise['options'] as List?;
          if (options == null || options.length != 4) return false;
          if (!options.any((opt) => opt['isCorrect'] == true)) return false;
          break;
          
        case 'word_order':
          final correctOrder = exercise['correctOrder'] as List?;
          if (correctOrder == null || correctOrder.isEmpty) return false;
          break;
          
        case 'match':
          final pairs = exercise['pairs'] as List?;
          if (pairs == null || pairs.length != 4) return false;
          break;
      }
    }
    
    return true;
  }
  
  /// Carrega dados da lição e exercícios do Firestore com validação
  /// Lança exceção se dados não forem encontrados ou inválidos
  Future<void> _loadLessonData(String courseId, String lessonId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    try {
      // Carregar dados da lição
      final lessonDoc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .get();

      if (!lessonDoc.exists) {
        throw Exception('Lição não encontrada');
      }

      currentLesson.value = {
        'id': lessonDoc.id,
        ...lessonDoc.data()!,
      };

      // Carregar exercícios da lição
      final exercisesSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('exercises')
          .orderBy('order')
          .get();

      if (exercisesSnapshot.docs.isEmpty) {
        throw Exception('Nenhum exercício encontrado para esta lição');
      }

      currentExercises.value = exercisesSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao carregar lição: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao carregar lição: $e');
    }
  }
  
  // Validação de lições
  
  /// Verifica se a lição está desbloqueada
  /// Lição 1 sempre desbloqueada, outras requerem lição anterior completa
  Future<bool> _isLessonUnlocked(String courseId, int lessonId) async {
    try {
      // Lição 1 sempre desbloqueada
      if (lessonId == 1) return true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Verifica se lição anterior (lessonId - 1) está completa
      final previousLessonId = lessonId - 1;
      final progressDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .doc(previousLessonId.toString())
          .get();

      if (!progressDoc.exists) return false;

      final status = progressDoc.data()?['status'] as String?;
      return status == 'completed';
    } catch (e) {
      return false;
    }
  }

  /// Verifica se o usuário tem energia disponível
  Future<bool> _hasEnergy() async {
    return _gamificationController.currentEnergy.value > 0;
  }

  /// Verifica se energia ilimitada está ativa
  bool _hasUnlimitedEnergy() {
    return _gamificationController.hasUnlimitedEnergy;
  }

  // Gerenciamento de energia
  
  /// Consome 1 energia do usuário (operação atômica via Firestore transaction)
  /// Lança exceção se energia insuficiente ou erro ao processar
  Future<void> _consumeEnergy() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification');

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        if (!snapshot.exists) {
          throw Exception('Dados do usuário não encontrados');
        }

        final currentEnergy = snapshot.data()?['currentEnergy'] as int? ?? 0;
        
        if (currentEnergy <= 0) {
          throw Exception('Energia insuficiente');
        }

        // Decrementa energia
        transaction.update(statsRef, {
          'currentEnergy': currentEnergy - 1,
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Erro ao processar energia: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar energia: $e');
    }
  }

  /// Calcula energia disponível baseado na regeneração
  /// Fórmula: min(5, currentEnergy + (minutesPassed ~/ 30))
  int _calculateAvailableEnergy(DateTime lastEnergyUpdate, int currentEnergy) {
    final now = DateTime.now();
    final minutesPassed = now.difference(lastEnergyUpdate).inMinutes;
    final energyRegenerated = minutesPassed ~/ 30;
    final totalEnergy = currentEnergy + energyRegenerated;
    
    return totalEnergy > 5 ? 5 : totalEnergy;
  }

  /// Calcula minutos até próxima energia
  /// Fórmula: 30 - (minutesPassed % 30)
  int _calculateMinutesUntilNextEnergy(DateTime lastEnergyUpdate) {
    final now = DateTime.now();
    final minutesPassed = now.difference(lastEnergyUpdate).inMinutes;
    
    return 30 - (minutesPassed % 30);
  }
  
  // Cálculo de recompensas
  
  /// Calcula XP total seguindo ordem CRÍTICA:
  /// 1. Base: lesson.xpReward
  /// 2. Perfect bonus: +5 se accuracy == 100%
  /// 3. First today bonus: +5 se _isFirstLessonToday()
  /// 4. XP Booster: multiplica por 2 se ativo e não expirado
  Future<int> _calculateTotalXP() async {
    // Step 1: Base XP da lição
    int totalXp = currentLesson.value?['xpReward'] as int? ?? 10;
    
    // Step 2: Perfect bonus (+5 se 100% accuracy)
    if (accuracy == 100.0) {
      totalXp += 5;
    }
    
    // Step 3: First today bonus (+5 se primeira lição hoje)
    final isFirstToday = await _isFirstLessonToday();
    if (isFirstToday) {
      totalXp += 5;
    }
    
    // Step 4: XP Booster (multiplica por 2 se ativo)
    final hasXpBooster = _gamificationController.hasXpBooster;
    if (hasXpBooster) {
      totalXp *= 2;
    }
    
    return totalXp;
  }
  
  /// Calcula gems totais seguindo ordem CRÍTICA:
  /// 1. Base: lesson.gemsReward
  /// 2. Gem Multiplier: multiplica por 2 se ativo e não expirado
  int _calculateTotalGems() {
    // Step 1: Base gems da lição
    int totalGems = currentLesson.value?['gemsReward'] as int? ?? 1;
    
    // Step 2: Gem Multiplier (multiplica por 2 se ativo)
    final hasGemMultiplier = _gamificationController.hasGemMultiplier;
    if (hasGemMultiplier) {
      totalGems *= 2;
    }
    
    return totalGems;
  }
  
  /// Verifica se um booster está ativo comparando tempo atual com expiração
  /// Retorna true se booster está ativo (tempo atual < tempo de expiração)
  bool _checkBoosterExpiration(DateTime? expirationTime) {
    if (expirationTime == null) return false;
    
    final now = DateTime.now();
    return now.isBefore(expirationTime);
  }
  
  /// Verifica se esta é a primeira lição completada hoje
  /// Usa timezone do usuário para determinar "hoje"
  Future<bool> _isFirstLessonToday() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;
      
      final todayDate = _getTodayDateString();
      
      // Verifica se já existe histórico para hoje
      final historyDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(todayDate)
          .get();
      
      if (!historyDoc.exists) return true;
      
      final lessonsCompleted = historyDoc.data()?['lessonsCompleted'] as int? ?? 0;
      return lessonsCompleted == 0;
    } catch (e) {
      return false;
    }
  }
  
  /// Retorna a data de hoje no formato YYYY-MM-DD (timezone do usuário)
  /// Em caso de erro na conversão, usa data atual como fallback
  String _getTodayDateString() {
    try {
      final now = DateTime.now();
      return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    } catch (e) {
      // Fallback: usar data atual em UTC
      final now = DateTime.now().toUtc();
      return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
  }
  
  // Gerenciamento de Streak
  
  /// Atualiza o streak do usuário baseado na última data de streak
  /// 
  /// Lógica:
  /// - Se última data é ontem: incrementa currentStreak em 1
  /// - Se última data é hoje: sem mudanças
  /// - Se última data é antes de ontem: reseta currentStreak para 1
  /// - Atualiza longestStreak se currentStreak exceder
  /// - Salva data atual como lastStreakDate
  Future<void> _updateStreak() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification');
    
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        if (!snapshot.exists) {
          throw Exception('Dados do usuário não encontrados');
        }
        
        final data = snapshot.data()!;
        final streakData = data['streak'] as Map<String, dynamic>? ?? {};
        
        // Obter valores atuais
        final currentStreak = streakData['currentStreak'] as int? ?? 0;
        final longestStreak = streakData['longestStreak'] as int? ?? 0;
        final lastStreakDate = streakData['lastStreakDate'] as String? ?? '';
        
        // Obter data de hoje
        final todayDate = _getTodayDateString();
        
        // Determinar novo valor de currentStreak
        int newCurrentStreak;
        
        if (lastStreakDate == todayDate) {
          // Última data é hoje: sem mudanças
          newCurrentStreak = currentStreak;
        } else if (_isYesterday(lastStreakDate, todayDate)) {
          // Última data é ontem: incrementa
          newCurrentStreak = currentStreak + 1;
        } else {
          // Última data é antes de ontem: reseta para 1
          newCurrentStreak = 1;
        }
        
        // Atualizar longestStreak se necessário
        final newLongestStreak = newCurrentStreak > longestStreak 
            ? newCurrentStreak 
            : longestStreak;
        
        // Salvar atualizações
        transaction.update(statsRef, {
          'streak.currentStreak': newCurrentStreak,
          'streak.longestStreak': newLongestStreak,
          'streak.lastStreakDate': todayDate,
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar streak: ${e.message}');
    }
  }
  
  /// Verifica se uma data é ontem comparada com hoje
  /// 
  /// Formato esperado: YYYY-MM-DD
  /// Usa timezone do usuário
  bool _isYesterday(String lastStreakDate, String todayDate) {
    if (lastStreakDate.isEmpty) return false;
    
    try {
      // Parse das datas
      final lastParts = lastStreakDate.split('-');
      final todayParts = todayDate.split('-');
      
      if (lastParts.length != 3 || todayParts.length != 3) return false;
      
      final lastDate = DateTime(
        int.parse(lastParts[0]),
        int.parse(lastParts[1]),
        int.parse(lastParts[2]),
      );
      
      final today = DateTime(
        int.parse(todayParts[0]),
        int.parse(todayParts[1]),
        int.parse(todayParts[2]),
      );
      
      // Calcular diferença em dias
      final difference = today.difference(lastDate).inDays;
      
      return difference == 1;
    } catch (e) {
      return false;
    }
  }
  
  // Distribuição de XP e Level Up
  
  /// Distribui XP para todos os três contadores atomicamente usando Firestore transaction
  /// 
  /// Adiciona XP a:
  /// - totalXp (nunca reseta)
  /// - weeklyXp (reseta segunda-feira 00:00)
  /// - todayXp (reseta diariamente à meia-noite)
  /// 
  /// Usa transação do Firestore para garantir atomicidade
  Future<void> _distributeXP(int xpAmount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification');
    
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        if (!snapshot.exists) {
          throw Exception('Dados do usuário não encontrados');
        }
        
        final data = snapshot.data()!;
        final xpData = data['xp'] as Map<String, dynamic>? ?? {};
        
        // Obter valores atuais
        final currentTotalXp = xpData['totalXp'] as int? ?? 0;
        final currentWeeklyXp = xpData['weeklyXp'] as int? ?? 0;
        final currentTodayXp = xpData['todayXp'] as int? ?? 0;
        
        // Adicionar XP a todos os três contadores atomicamente
        transaction.update(statsRef, {
          'xp.totalXp': currentTotalXp + xpAmount,
          'xp.weeklyXp': currentWeeklyXp + xpAmount,
          'xp.todayXp': currentTodayXp + xpAmount,
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Erro ao distribuir XP: ${e.message}');
    }
  }
  
  /// Verifica se o usuário deve subir de nível e executa o level up
  /// 
  /// Fórmula: totalXp >= currentLevel * 100
  /// Se level up: incrementa currentLevel, NÃO reseta totalXp
  /// 
  /// Retorna true se houve level up, false caso contrário
  Future<bool> _checkAndLevelUp() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification');
    
    try {
      bool leveledUp = false;
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        if (!snapshot.exists) {
          throw Exception('Dados do usuário não encontrados');
        }
        
        final data = snapshot.data()!;
        final xpData = data['xp'] as Map<String, dynamic>? ?? {};
        
        // Obter valores atuais
        final currentTotalXp = xpData['totalXp'] as int? ?? 0;
        final currentLevel = xpData['level'] as int? ?? 1;
        
        // Calcular XP necessário para próximo nível
        final xpForNextLevel = _calculateXPForNextLevel(currentLevel);
        
        // Verificar se deve subir de nível
        if (currentTotalXp >= xpForNextLevel) {
          final newLevel = currentLevel + 1;
          final newXpForNextLevel = _calculateXPForNextLevel(newLevel);
          
          // Incrementar nível, NÃO resetar totalXp
          transaction.update(statsRef, {
            'xp.level': newLevel,
            'xp.xpToNextLevel': newXpForNextLevel,
          });
          
          leveledUp = true;
        }
      });
      
      return leveledUp;
    } on FirebaseException catch (e) {
      throw Exception('Erro ao verificar level up: ${e.message}');
    }
  }
  
  /// Calcula XP necessário para o próximo nível
  /// 
  /// Fórmula: currentLevel * 100
  int _calculateXPForNextLevel(int currentLevel) {
    return currentLevel * 100;
  }
  
  /// Reseta os estados da lição
  void _resetLessonState() {
    currentLesson.value = null;
    currentExercises.clear();
    currentExerciseIndex.value = 0;
    hearts.value = 3;
    correctAnswers.value = 0;
    totalAnswers.value = 0;
    startTime.value = null;
    pauseTime.value = null;
    accumulatedTime.value = 0;
    showFeedback.value = false;
    isCorrectAnswer.value = false;
    correctAnswerText.value = '';
  }

  // Validação de exercícios
  
  /// Valida exercício de imagem comparando imageIds
  /// Retorna true se o imageId selecionado corresponde ao correto
  bool _validateImageExercise(String selectedImageId, String correctImageId) {
    return selectedImageId == correctImageId;
  }

  /// Valida exercício de tradução comparando texto
  /// Comparação case-sensitive com whitespace trimmed
  bool _validateTranslationExercise(String selectedTranslation, String correctTranslation) {
    return selectedTranslation.trim() == correctTranslation.trim();
  }

  /// Valida exercício de ordenação de palavras comparando arrays ordenados
  /// Retorna true se a ordem das palavras está correta
  bool _validateWordOrderExercise(List<String> userOrder, List<String> correctOrder) {
    if (userOrder.length != correctOrder.length) return false;
    
    for (int i = 0; i < userOrder.length; i++) {
      if (userOrder[i] != correctOrder[i]) return false;
    }
    
    return true;
  }

  /// Valida exercício de combinação verificando se todos os 4 pares estão corretos
  /// Retorna true se todos os pares correspondem
  bool _validateMatchExercise(Map<String, String> userPairs, Map<String, String> correctPairs) {
    if (userPairs.length != 4 || correctPairs.length != 4) return false;
    
    for (final entry in correctPairs.entries) {
      if (userPairs[entry.key] != entry.value) return false;
    }
    
    return true;
  }
  
  /// Calcula XP base baseado na performance (10-15)
  /// DEPRECATED: Usar _calculateTotalXP() ao invés
  int _calculateBaseXp() {
    final accuracyDecimal = accuracy / 100;
    if (accuracyDecimal >= 0.9) return 15; // 90%+ = 15 XP
    if (accuracyDecimal >= 0.7) return 13; // 70-89% = 13 XP
    if (accuracyDecimal >= 0.5) return 11; // 50-69% = 11 XP
    return 10; // <50% = 10 XP
  }

  /// Calcula gems base baseado na performance (1-3)
  /// DEPRECATED: Usar _calculateTotalGems() ao invés
  int _calculateBaseGems() {
    final accuracyDecimal = accuracy / 100;
    if (accuracyDecimal >= 0.9) return 3; // 90%+ = 3 gems
    if (accuracyDecimal >= 0.7) return 2; // 70-89% = 2 gems
    return 1; // <70% = 1 gem
  }
  
  // Persistência de progresso
  
  /// Adiciona gems ao totalGems do usuário (operação atômica)
  Future<void> _addGems(int gemsAmount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification');
    
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);
        
        if (!snapshot.exists) {
          throw Exception('Dados do usuário não encontrados');
        }
        
        final data = snapshot.data()!;
        final gemsData = data['gems'] as Map<String, dynamic>? ?? {};
        
        // Obter valores atuais
        final currentGems = gemsData['totalGems'] as int? ?? 0;
        final totalGemsEarned = gemsData['totalGemsEarned'] as int? ?? 0;
        
        // Adicionar gems
        transaction.update(statsRef, {
          'gems.totalGems': currentGems + gemsAmount,
          'gems.totalGemsEarned': totalGemsEarned + gemsAmount,
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Erro ao adicionar gems: ${e.message}');
    }
  }
  
  /// Salva o progresso da lição no Firestore
  /// 
  /// Path: users/{userId}/courses/{courseId}/progress/{lessonId}
  /// Inclui: accuracy, xpEarned, gemsEarned, timeSpent (segundos), mistakes
  /// Usa FieldValue.serverTimestamp() para completedAt
  Future<void> _saveLessonProgress(
    String courseId,
    String lessonId,
    int xpEarned,
    int gemsEarned,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    final timeSpent = _calculateTimeSpent();
    final mistakes = totalAnswers.value - correctAnswers.value;
    
    final progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('progress')
        .doc(lessonId);
    
    try {
      await progressRef.set({
        'lessonId': lessonId,
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'accuracy': accuracy,
        'xpEarned': xpEarned,
        'gemsEarned': gemsEarned,
        'timeSpent': timeSpent,
        'mistakes': mistakes,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Erro ao salvar progresso: ${e.message}');
    }
  }
  
  /// Atualiza o histórico diário do usuário
  /// 
  /// Path: users/{userId}/history/{YYYY-MM-DD}
  /// Usa timezone do usuário para cálculo da data
  /// Incrementa: lessonsCompleted, totalXp, totalGems, totalTime
  Future<void> _updateDailyHistory(int xp, int gems, int timeSpent) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    final todayDate = _getTodayDateString();
    
    final historyRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(todayDate);
    
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(historyRef);
        
        if (!snapshot.exists) {
          // Criar novo documento de histórico
          transaction.set(historyRef, {
            'date': todayDate,
            'lessonsCompleted': 1,
            'xpEarned': xp,
            'gemsEarned': gems,
            'timeSpent': timeSpent,
            'exercisesCorrect': correctAnswers.value,
            'exercisesTotal': totalAnswers.value,
            'streakMaintained': true,
          });
        } else {
          // Atualizar documento existente
          final data = snapshot.data()!;
          
          transaction.update(historyRef, {
            'lessonsCompleted': (data['lessonsCompleted'] as int? ?? 0) + 1,
            'xpEarned': (data['xpEarned'] as int? ?? 0) + xp,
            'gemsEarned': (data['gemsEarned'] as int? ?? 0) + gems,
            'timeSpent': (data['timeSpent'] as int? ?? 0) + timeSpent,
            'exercisesCorrect': (data['exercisesCorrect'] as int? ?? 0) + correctAnswers.value,
            'exercisesTotal': (data['exercisesTotal'] as int? ?? 0) + totalAnswers.value,
          });
        }
      });
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar histórico: ${e.message}');
    }
  }
  
  /// Atualiza todos os desafios ativos do usuário
  /// 
  /// Incrementa contadores relevantes (lessonsCompleted, xpEarned, etc.)
  /// Marca desafios como completos quando meta é atingida
  /// Premia recompensas de desafios
  Future<void> _updateChallenges() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    try {
      // Buscar desafios ativos
      final challengesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .where('status', isEqualTo: 'active')
          .get();
      
      if (challengesSnapshot.docs.isEmpty) return;
      
      // Atualizar cada desafio
      final batch = _firestore.batch();
      
      for (final doc in challengesSnapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String?;
        final goal = data['goal'] as int? ?? 0;
        final progress = data['progress'] as int? ?? 0;
        
        int newProgress = progress;
        
        // Incrementar progresso baseado no tipo de desafio
        switch (type) {
          case 'lessons_completed':
            newProgress = progress + 1;
            break;
          case 'xp_earned':
            final xp = await _calculateTotalXP();
            newProgress = progress + xp;
            break;
          case 'perfect_lessons':
            if (isPerfect) newProgress = progress + 1;
            break;
          default:
            continue;
        }
        
        // Verificar se desafio foi completado
        final isCompleted = newProgress >= goal;
        
        batch.update(doc.reference, {
          'progress': newProgress,
          'status': isCompleted ? 'completed' : 'active',
          if (isCompleted) 'completedAt': FieldValue.serverTimestamp(),
        });
        
        // Se completado, premiar recompensas
        if (isCompleted && !data.containsKey('completedAt')) {
          final rewardXp = data['rewardXp'] as int? ?? 0;
          final rewardGems = data['rewardGems'] as int? ?? 0;
          
          if (rewardXp > 0) await _distributeXP(rewardXp);
          if (rewardGems > 0) await _addGems(rewardGems);
        }
      }
      
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar desafios: ${e.message}');
    }
  }
  
  /// Desbloqueia a próxima lição (lessonId + 1)
  Future<void> _unlockNextLesson(String courseId, String lessonId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    try {
      final lessonIdInt = int.tryParse(lessonId);
      if (lessonIdInt == null) return;
      
      final nextLessonId = lessonIdInt + 1;
      
      // Verificar se próxima lição existe
      final nextLessonDoc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(nextLessonId.toString())
          .get();
      
      if (!nextLessonDoc.exists) return; // Não há próxima lição
      
      // Marcar próxima lição como desbloqueada
      final progressRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .doc(nextLessonId.toString());
      
      await progressRef.set({
        'lessonId': nextLessonId.toString(),
        'status': 'not_started',
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Erro ao desbloquear próxima lição: ${e.message}');
    }
  }
  
  /// Pausa o rastreamento de tempo da lição
  /// Salva o tempo atual e acumula o tempo decorrido até agora
  void pauseLesson() {
    if (startTime.value == null || pauseTime.value != null) return;
    
    final now = DateTime.now();
    final elapsed = now.difference(startTime.value!).inMilliseconds;
    accumulatedTime.value += elapsed;
    pauseTime.value = now;
  }
  
  /// Retoma o rastreamento de tempo da lição
  /// Reinicia o startTime sem perder o tempo acumulado
  void resumeTimeTracking() {
    if (pauseTime.value == null) return;
    
    startTime.value = DateTime.now();
    pauseTime.value = null;
  }
  
  /// Salva o estado atual da lição como in_progress
  /// Permite retomar a lição mais tarde sem consumir energia adicional
  Future<void> saveInProgressState(String courseId, String lessonId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');
    
    final progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('progress')
        .doc(lessonId);
    
    try {
      await progressRef.set({
        'lessonId': lessonId,
        'status': 'in_progress',
        'currentExerciseIndex': currentExerciseIndex.value,
        'hearts': hearts.value,
        'correctAnswers': correctAnswers.value,
        'totalAnswers': totalAnswers.value,
        'accumulatedTime': accumulatedTime.value,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Erro ao salvar estado da lição: ${e.message}');
    }
  }
  
  /// Calcula o tempo gasto na lição em milissegundos
  /// Inclui apenas tempo ativo (exclui tempo de pausa)
  /// Acumula tempo através de sessões de resume
  /// 
  /// Retorna tempo total em milissegundos
  int _calculateTimeSpentMilliseconds() {
    if (startTime.value == null) return accumulatedTime.value;
    
    // Se está pausado, retorna apenas tempo acumulado
    if (pauseTime.value != null) {
      return accumulatedTime.value;
    }
    
    // Se está ativo, adiciona tempo desde último start ao tempo acumulado
    final now = DateTime.now();
    final currentSessionTime = now.difference(startTime.value!).inMilliseconds;
    
    return accumulatedTime.value + currentSessionTime;
  }
  
  /// Calcula o tempo gasto na lição em segundos
  /// Converte de milissegundos para segundos para armazenamento
  int _calculateTimeSpent() {
    final milliseconds = _calculateTimeSpentMilliseconds();
    return (milliseconds / 1000).round();
  }
  
  /// Cache o progresso localmente quando falha ao salvar no Firestore
  /// Será sincronizado na próxima abertura do app
  /// 
  /// Armazena em SharedPreferences com chave: lesson_progress_{userId}_{courseId}_{lessonId}
  Future<void> _cacheProgressLocally() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;
      
      final courseId = currentLesson.value?['courseId'] as String? ?? '';
      final lessonId = currentLesson.value?['id'] as String? ?? '';
      
      if (courseId.isEmpty || lessonId.isEmpty) return;
      
      // Preparar dados para cache
      final progressData = {
        'userId': userId,
        'courseId': courseId,
        'lessonId': lessonId,
        'accuracy': accuracy,
        'xpEarned': await _calculateTotalXP(),
        'gemsEarned': _calculateTotalGems(),
        'timeSpent': _calculateTimeSpent(),
        'mistakes': totalAnswers.value - correctAnswers.value,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // TODO: Implementar cache usando SharedPreferences
      // Por enquanto, apenas log do erro
      print('CACHE LOCAL: Progresso não salvo - $progressData');
    } catch (e) {
      print('Erro ao fazer cache local: $e');
    }
  }
}

// Extension for testing - exposes private validation methods
extension LessonControllerTestExtension on LessonController {
  /// Test wrapper for _validateImageExercise
  bool validateImageExerciseForTest(String selectedImageId, String correctImageId) {
    return _validateImageExercise(selectedImageId, correctImageId);
  }

  /// Test wrapper for _validateTranslationExercise
  bool validateTranslationExerciseForTest(String selectedTranslation, String correctTranslation) {
    return _validateTranslationExercise(selectedTranslation, correctTranslation);
  }

  /// Test wrapper for _validateWordOrderExercise
  bool validateWordOrderExerciseForTest(List<String> userOrder, List<String> correctOrder) {
    return _validateWordOrderExercise(userOrder, correctOrder);
  }

  /// Test wrapper for _validateMatchExercise
  bool validateMatchExerciseForTest(Map<String, String> userPairs, Map<String, String> correctPairs) {
    return _validateMatchExercise(userPairs, correctPairs);
  }
  
  /// Test wrapper for _calculateTotalXP
  Future<int> calculateTotalXPForTest() {
    return _calculateTotalXP();
  }
  
  /// Test wrapper for _calculateTotalGems
  int calculateTotalGemsForTest() {
    return _calculateTotalGems();
  }
  
  /// Test wrapper for _checkBoosterExpiration
  bool checkBoosterExpirationForTest(DateTime? expirationTime) {
    return _checkBoosterExpiration(expirationTime);
  }
  
  /// Test wrapper for _isFirstLessonToday
  Future<bool> isFirstLessonTodayForTest() {
    return _isFirstLessonToday();
  }
  
  /// Test wrapper for _getTodayDateString
  String getTodayDateStringForTest() {
    return _getTodayDateString();
  }
  
  /// Test wrapper for _distributeXP
  Future<void> distributeXPForTest(int xpAmount) {
    return _distributeXP(xpAmount);
  }
  
  /// Test wrapper for _checkAndLevelUp
  Future<bool> checkAndLevelUpForTest() {
    return _checkAndLevelUp();
  }
  
  /// Test wrapper for _calculateXPForNextLevel
  int calculateXPForNextLevelForTest(int currentLevel) {
    return _calculateXPForNextLevel(currentLevel);
  }
  
  /// Test wrapper for _updateStreak
  Future<void> updateStreakForTest() {
    return _updateStreak();
  }
  
  /// Test wrapper for _isYesterday
  bool isYesterdayForTest(String lastStreakDate, String todayDate) {
    return _isYesterday(lastStreakDate, todayDate);
  }
  
  /// Test wrapper for _saveLessonProgress
  Future<void> saveLessonProgressForTest(String courseId, String lessonId, int xpEarned, int gemsEarned) {
    return _saveLessonProgress(courseId, lessonId, xpEarned, gemsEarned);
  }
  
  /// Test wrapper for _updateDailyHistory
  Future<void> updateDailyHistoryForTest(int xp, int gems, int timeSpent) {
    return _updateDailyHistory(xp, gems, timeSpent);
  }
  
  /// Test wrapper for _updateChallenges
  Future<void> updateChallengesForTest() {
    return _updateChallenges();
  }
  
  /// Test wrapper for _unlockNextLesson
  Future<void> unlockNextLessonForTest(String courseId, String lessonId) {
    return _unlockNextLesson(courseId, lessonId);
  }
  
  /// Test wrapper for _calculateTimeSpent
  int calculateTimeSpentForTest() {
    return _calculateTimeSpent();
  }
  
  /// Test wrapper for _calculateTimeSpentMilliseconds
  int calculateTimeSpentMillisecondsForTest() {
    return _calculateTimeSpentMilliseconds();
  }
  
  /// Test wrapper for pauseLesson
  void pauseLessonForTest() {
    pauseLesson();
  }
  
  /// Test wrapper for _addGems
  Future<void> addGemsForTest(int gemsAmount) {
    return _addGems(gemsAmount);
  }
  
  /// Test wrapper for resumeLesson (public method)
  Future<void> resumeLessonForTest(String courseId, String lessonId) {
    return resumeLesson(courseId, lessonId);
  }
  
  /// Test wrapper for saveInProgressState
  Future<void> saveInProgressStateForTest(String courseId, String lessonId) {
    return saveInProgressState(courseId, lessonId);
  }
}
