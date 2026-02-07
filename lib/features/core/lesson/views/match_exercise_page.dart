import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../inners/gamification/controllers/energy_controller.dart';
import '../controllers/lesson_flow_controller.dart';
import '../controllers/lesson_exercise_controller.dart';
import '../controllers/lesson_progress_controller.dart';
import '../widgets/audio_card.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/lesson_option_card.dart';

/// Página de exercício de matching (combinar pares)
class MatchExercisePage extends StatefulWidget {
  const MatchExercisePage({super.key});

  @override
  State<MatchExercisePage> createState() => _MatchExercisePageState();
}

class _MatchExercisePageState extends State<MatchExercisePage> {
  // Controllers
  late final LessonFlowController _flowController;
  late final LessonExerciseController _exerciseController;
  
  // Estados
  int? _selectedAudioIndex;
  int? _selectedTextIndex;
  final Set<int> _matchedPairs = {};
  bool _hasChecked = false;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _flowController = Get.find<LessonFlowController>();
    _exerciseController = Get.find<LessonExerciseController>();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    // Obter exercício atual do controller
    if (_flowController.currentExerciseIndex.value >= _flowController.currentExercises.length) {
      return const Scaffold(
        body: Center(child: Text('Exercício não encontrado')),
      );
    }
    
    final currentExercise = _flowController.currentExercises[_flowController.currentExerciseIndex.value];
    final pairs = (currentExercise['pairs'] as List?) ?? [];
    
    return WillPopScope(
      onWillPop: () async {
        // Bloquear voltar após verificar resposta
        if (_hasChecked) return false;
        
        // Mostrar dialog de confirmação antes de sair
        return await _showExitConfirmation(context) ?? false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.spacing16),

                // Header - sem botão voltar após verificar
                Obx(() => ExerciseHeader(
                      progress: _flowController.currentExerciseIndex.value / _flowController.currentExercises.length,
                      energy: Get.find<EnergyController>().currentEnergy.value,
                      onBack: _hasChecked ? null : () => _onBackPressed(context),
                    )),

                SizedBox(height: r.spacing24),

                // Título
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                  child: Text(
                    currentExercise['question'] as String? ?? 'Toque nos pares correspondentes',
                    style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                  ),
                ),

                SizedBox(height: r.spacing32),

                // Pares
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.spacing16),
                  child: Column(
                    children: [
                      for (int i = 0; i < pairs.length; i++) ...[
                        _buildPairRow(i, pairs, r),
                        if (i < pairs.length - 1) SizedBox(height: r.spacing16),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: r.spacing24),

                // Link "Can't listen now"
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: [etapa 8] implementar skip de exercício de áudio
                    },
                    child: Text(
                      "Não posso ouvir agora",
                      style: AppTheme.textMdSemibold.copyWith(
                        color: AppTheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: r.spacing16),

                // Botão Check
                Padding(
                  padding: EdgeInsets.all(r.spacing16),
                  child: Obx(() => AppButton(
                        text: 'Verificar',
                        isLoading: _exerciseController.isLoading.value,
                        onPressed: _matchedPairs.length == pairs.length && !_exerciseController.isLoading.value && !_hasChecked
                            ? _onCheck
                            : null,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widgets

  Widget _buildPairRow(int index, List pairs, ResponsiveUtils r) {
    final isMatched = _matchedPairs.contains(index);
    final pair = pairs[index];

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          // Card de áudio
          Expanded(
            child: AudioCard(
              status: _getAudioStatus(index),
              onTap: (isMatched || _hasChecked) ? null : () => _onAudioTap(index),
            ),
          ),

          SizedBox(width: r.spacing12),

          // Card de texto
          Expanded(
            child: LessonOptionCard(
              label: pair['text'] as String? ?? '',
              showImage: false,
              status: _getTextStatus(index),
              onTap: (isMatched || _hasChecked) ? null : () => _onTextTap(index),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  AudioCardStatus _getAudioStatus(int index) {
    if (_matchedPairs.contains(index)) return AudioCardStatus.matched;
    if (_selectedAudioIndex == index) return AudioCardStatus.selected;
    return AudioCardStatus.normal;
  }

  LessonOptionStatus _getTextStatus(int index) {
    if (_matchedPairs.contains(index)) {
      return LessonOptionStatus.correct;
    }
    if (_selectedTextIndex == index) return LessonOptionStatus.selected;
    return LessonOptionStatus.normal;
  }

  // Métodos de ação
  void _onAudioTap(int index) {
    setState(() {
      _selectedAudioIndex = index;
      _checkMatch();
    });
  }

  void _onTextTap(int index) {
    setState(() {
      _selectedTextIndex = index;
      _checkMatch();
    });
  }

  void _checkMatch() {
    if (_selectedAudioIndex != null && _selectedTextIndex != null) {
      // Verifica se os índices correspondem (match correto)
      if (_selectedAudioIndex == _selectedTextIndex) {
        _matchedPairs.add(_selectedAudioIndex!);
      }
      // Limpa seleção
      _selectedAudioIndex = null;
      _selectedTextIndex = null;
    }
  }

  void _onCheck() async {
    setState(() {
      _hasChecked = true;
    });

    // Criar mapa de pares para submeter
    final Map<String, String> userPairs = {};
    final pairs = _flowController.currentExercises[_flowController.currentExerciseIndex.value]['pairs'] as List;
    
    for (final index in _matchedPairs) {
      final pair = pairs[index];
      userPairs[pair['audio'] as String] = pair['text'] as String;
    }

    // Submete resposta ao controller
    await _exerciseController.submitAnswer(userPairs, 'match');

    // CORREÇÃO: Registrar resposta no progresso
    final _progressController = Get.find<LessonProgressController>();
    if (_exerciseController.isCorrectAnswer.value) {
      _progressController.addCorrectAnswer();
    } else {
      _progressController.addWrongAnswer();
      _progressController.loseHeart();
    }

    // Mostra feedback
    if (!mounted) return;
    
    FeedbackBottomSheet.show(
      context,
      type: _exerciseController.isCorrectAnswer.value 
          ? FeedbackType.correct 
          : FeedbackType.wrong,
      correctAnswer: _exerciseController.isCorrectAnswer.value 
          ? null 
          : _exerciseController.correctAnswerText.value,
      onContinue: _onContinue,
    );
  }

  void _onContinue() {
    // Fechar o modal primeiro
    Navigator.of(context).pop();
    
    // Depois avançar o índice do exercício
    _flowController.nextExercise();
  }

  // Métodos auxiliares

  /// Mostra dialog de confirmação ao tentar sair da lição
  Future<bool?> _showExitConfirmation(BuildContext context) async {
    return await WoltModalSheet.show<bool>(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: AppTheme.white,
          surfaceTintColor: Colors.transparent,
          hasSabGradient: false,
          hasTopBarLayer: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone de aviso
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppTheme.orange,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  'Sair da lição?',
                  style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Mensagem
                Text(
                  'Se você sair agora, perderá o progresso desta lição e a energia gasta não será devolvida.',
                  style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Botões
                AppButton(
                  text: 'Continuar Lição',
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Sair',
                  isPrimary: false,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
        ),
      ],
      modalTypeBuilder: (context) => WoltModalType.dialog(),
      barrierDismissible: false,
    );
  }

  /// Callback para o botão voltar do header
  void _onBackPressed(BuildContext context) async {
    final shouldExit = await _showExitConfirmation(context);
    if (shouldExit == true) {
      Get.back();
    }
  }
}
