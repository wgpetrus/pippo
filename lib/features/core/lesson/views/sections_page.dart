import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../../../../shared/mocks/lesson_mocks.dart';
import '../../../inners/gamification/controllers/gamification_controller.dart';
import '../controllers/lesson_flow_controller.dart';
import '../widgets/low_energy_modal.dart';
import '../widgets/section_card.dart';
import 'lesson_exercise_container.dart';

/// Página de seções de um curso (navegação interna via Get.to)
class SectionsPage extends StatefulWidget {
  final String courseName;
  final int buttonIndex;

  const SectionsPage({
    super.key,
    required this.courseName,
    required this.buttonIndex,
  });

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  List<Map<String, dynamic>> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    debugPrint('🔄 SectionsPage: Iniciando carregamento de seções...');
    debugPrint('  📍 ButtonIndex recebido: ${widget.buttonIndex}');
    
    setState(() {
      _isLoading = true;
    });

    try {
      final gamificationController = Get.find<GamificationController>();
      final userId = gamificationController.userId;
      
      debugPrint('👤 UserId: $userId');
      
      if (userId == null) {
        debugPrint('⚠️ UserId é null, usando seções estáticas');
        // Fallback para seções estáticas do botão especificado
        setState(() {
          _sections = LessonMocks.getSectionsForButton(widget.buttonIndex);
          _isLoading = false;
        });
        return;
      }

      // Buscar curso ativo
      final coursesSnapshot = await gamificationController.firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      String courseId = 'mock_course_id';
      if (coursesSnapshot.docs.isNotEmpty) {
        courseId = coursesSnapshot.docs.first.id;
      }
      
      debugPrint('📚 CourseId: $courseId');
      debugPrint('🎯 Carregando seções para botão ${widget.buttonIndex}');
      
      // Carregar seções com progresso dinâmico para o botão especificado
      final sections = await LessonMocks.getSectionsWithProgress(
        userId,
        courseId,
        buttonIndex: widget.buttonIndex,
      );
      
      debugPrint('✅ Seções carregadas: ${sections.length}');
      for (final section in sections) {
        debugPrint('  - ${section['title']}: ${section['currentProgress']}/${section['totalProgress']} (${section['status']})');
      }
      
      setState(() {
        _sections = sections;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erro ao carregar seções: $e');
      setState(() {
        _sections = LessonMocks.getSectionsForButton(widget.buttonIndex);
        _isLoading = false;
      });
    }
  }

  // Métodos

  /// Determina qual lição iniciar baseado no progresso
  /// Retorna o ID da próxima lição não completada DA SEÇÃO ATUAL
  Future<String?> _getNextLessonId() async {
    try {
      final gamificationController = Get.find<GamificationController>();
      final userId = gamificationController.userId;
      
      if (userId == null) return '1';

      // Buscar curso ativo
      final coursesSnapshot = await gamificationController.firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      String courseId = 'mock_course_id';
      if (coursesSnapshot.docs.isNotEmpty) {
        courseId = coursesSnapshot.docs.first.id;
      }

      // Buscar progresso de todas as lições
      final progressSnapshot = await gamificationController.firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .get();

      // Criar mapa de progresso
      final progressMap = <String, String>{};
      for (final doc in progressSnapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'not_started';
        progressMap[doc.id] = status;
      }

      // Encontrar a seção atual (primeira seção in_progress OU not_started)
      debugPrint('🔍 Procurando seção atual...');
      for (final section in _sections) {
        final sectionStatus = section['status'] as String;
        debugPrint('  📋 Seção ${section['id']}: $sectionStatus');
        
        if (sectionStatus == 'in_progress' || sectionStatus == 'not_started') {
          final lessons = section['lessons'] as List<String>;
          
          debugPrint('  ✅ Seção ${section['id']} selecionada, procurando lição não completada...');
          
          // Encontrar primeira lição não completada DESTA SEÇÃO
          for (final lessonId in lessons) {
            final status = progressMap[lessonId];
            debugPrint('    📖 Lição $lessonId: ${status ?? "not_started"}');
            
            if (status != 'completed') {
              debugPrint('📍 Próxima lição a iniciar (seção ${section['id']}): $lessonId (status: ${status ?? "not_started"})');
              return lessonId;
            }
          }
          
          // Todas lições completadas, mas status da seção ainda não atualizado
          debugPrint('Seção ${section['id']}: todas lições completadas, status=$sectionStatus');
        }
      }

      // Se não encontrou nenhuma lição in_progress, retorna a primeira lição
      debugPrint('⚠️ Nenhuma lição in_progress encontrada, retornando lição 1');
      return '1';
    } catch (e) {
      debugPrint('❌ Erro ao determinar próxima lição: $e');
      return '1';
    }
  }

  Future<void> _startLesson(BuildContext context) async {
    debugPrint('🎮 Iniciando lição...');
    
    final flowController = Get.find<LessonFlowController>();
    final gamificationController = Get.find<GamificationController>();

    // Verifica se tem energia suficiente
    if (!gamificationController.canStartLesson()) {
      debugPrint('⚠️ Sem energia suficiente');
      LowEnergyModal.show(
        context,
        currentEnergy: gamificationController.currentEnergy.value,
      );
      return;
    }

    // Determinar qual lição iniciar
    final lessonId = await _getNextLessonId();
    if (lessonId == null) {
      debugPrint('❌ Não foi possível determinar qual lição iniciar');
      Get.snackbar(
        'Erro',
        'Não foi possível determinar qual lição iniciar.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: AppTheme.white,
      );
      return;
    }

    debugPrint('🎯 Iniciando lição $lessonId');

    // Iniciar lição do curso ativo
    await flowController.startLessonFromActiveCourse(lessonId);
    
    if (flowController.errorMessage.value.isEmpty) {
      debugPrint('✅ Lição iniciada, navegando para exercícios...');
      // Navegar para exercícios e aguardar retorno
      await Get.to(() => const LessonExerciseContainer());
      
      debugPrint('🔄 Retornou dos exercícios, recarregando seções...');
      // Recarregar seções após completar lição
      await _loadSections();
    } else {
      debugPrint('❌ Erro ao iniciar lição: ${flowController.errorMessage.value}');
      Get.snackbar(
        'Erro',
        flowController.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: AppTheme.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        appBar: AppAppbar(title: widget.courseName),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    debugPrint('🎨 Reconstruindo UI com ${_sections.length} seções');

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppAppbar(title: widget.courseName),
      body: ListView.separated(
        key: ValueKey('sections_${_sections.hashCode}'), // Força rebuild quando _sections muda
        padding: EdgeInsets.all(r.spacing16),
        itemCount: _sections.length,
        separatorBuilder: (context, index) => SizedBox(height: r.spacing16),
        itemBuilder: (context, index) {
          final section = _sections[index];
          final status = section['status'] as String;
          final currentProgress = section['currentProgress'] as int? ?? 0;
          final totalProgress = section['totalProgress'] as int? ?? 0;
          
          debugPrint('🎨 Renderizando seção ${section['id']}: $currentProgress/$totalProgress ($status)');
          debugPrint('  📊 Dados brutos da seção: $section');
          
          SectionStatus sectionStatus;
          switch (status) {
            case 'in_progress':
              sectionStatus = SectionStatus.inProgress;
              break;
            case 'completed':
              sectionStatus = SectionStatus.completed;
              break;
            case 'not_started':
              sectionStatus = SectionStatus.notStarted;
              break;
            case 'locked':
            default:
              sectionStatus = SectionStatus.locked;
              break;
          }

          return SectionCard(
            key: ValueKey('section_${section['id']}_${currentProgress}_${status}'), // Key única por seção
            title: section['title'] as String,
            status: sectionStatus,
            currentProgress: currentProgress,
            totalProgress: totalProgress,
            onTap: (sectionStatus == SectionStatus.inProgress || sectionStatus == SectionStatus.notStarted)
                ? () => _startLesson(context) 
                : null,
          );
        },
      ),
    );
  }
}
