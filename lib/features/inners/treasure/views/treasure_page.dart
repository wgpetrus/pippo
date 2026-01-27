import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../controllers/treasure_controller.dart';
import '../widgets/challenge_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/treasure_header.dart';

/// Página do treasure hunter
class TreasurePage extends StatefulWidget {
  const TreasurePage({super.key});

  @override
  State<TreasurePage> createState() => _TreasurePageState();
}

class _TreasurePageState extends State<TreasurePage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  // ScrollController para manter posição
  final _scrollController = ScrollController();

  // Manter estado da página ao navegar entre tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Adicionar observer para detectar quando app volta ao foreground
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recarregar desafios quando app volta ao foreground
    if (state == AppLifecycleState.resumed) {
      final controller = Get.find<TreasureController>();
      controller.loadChallenges();
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin
    
    final controller = Get.find<TreasureController>();
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        surfaceTintColor: AppTheme.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Caça ao Tesouro', style: AppTheme.displaySmBold),
        titleSpacing: r.spacing16,
      ),
      // Botões flutuantes para desenvolvimento
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão para deletar todos os desafios
          FloatingActionButton.extended(
            onPressed: () => _deleteAllChallenges(controller),
            backgroundColor: AppTheme.error,
            foregroundColor: AppTheme.white,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Limpar Tudo'),
            heroTag: 'delete',
          ),
          SizedBox(height: r.spacing12),
          // Botão para gerar desafios
          FloatingActionButton.extended(
            onPressed: () => _generateChallenges(controller),
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.white,
            icon: const Icon(Icons.add_task),
            label: const Text('Gerar Desafios'),
            heroTag: 'generate',
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // Loading state
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          // Error state
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(r.spacing24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessage.value,
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacing16),
                    ElevatedButton(
                      onPressed: () => controller.loadChallenges(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.white,
                      ),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Empty state
          if (controller.challenges.isEmpty) {
            return const EmptyState();
          }

          // Challenges list
          return RefreshIndicator(
            onRefresh: () => controller.loadChallenges(),
            color: AppTheme.primary,
            child: SingleChildScrollView(
              controller: _scrollController,
              clipBehavior: Clip.none,
              padding: EdgeInsets.only(
                top: r.spacing16,
                bottom: r.spacing16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner header
                  const TreasureHeader(),

                  // Challenges grouped by type
                  _buildChallengesByType(controller, r),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Métodos privados

  /// Deleta todos os desafios (para limpar dados incorretos)
  Future<void> _deleteAllChallenges(TreasureController controller) async {
    // Confirmar ação
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Deletar Todos os Desafios?'),
        content: const Text(
          'Esta ação irá remover TODOS os desafios do Firestore. '
          'Use apenas para limpar dados incorretos durante desenvolvimento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Deletar Tudo'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Mostrar loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        barrierDismissible: false,
      );

      // Deletar todos os desafios
      await controller.deleteAllChallenges();

      // Fechar loading
      Get.back();

      // Mostrar sucesso
      Get.snackbar(
        'Sucesso! 🗑️',
        'Todos os desafios foram deletados.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.green,
        colorText: AppTheme.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // Fechar loading
      Get.back();

      // Mostrar erro
      Get.snackbar(
        'Erro',
        'Não foi possível deletar desafios. Tente novamente.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: AppTheme.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Gera desafios diários e semanais para desenvolvimento/testes
  Future<void> _generateChallenges(TreasureController controller) async {
    try {
      // Mostrar loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        barrierDismissible: false,
      );

      // Gerar desafios
      await controller.generateDailyChallenges();
      await controller.generateWeeklyChallenges();

      // Fechar loading
      Get.back();

      // Mostrar sucesso
      Get.snackbar(
        'Sucesso! 🎉',
        'Desafios diários e semanais foram gerados.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.green,
        colorText: AppTheme.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // Fechar loading
      Get.back();

      // Mostrar erro
      Get.snackbar(
        'Erro',
        'Não foi possível gerar desafios. Tente novamente.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: AppTheme.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Widgets privados

  /// Constrói desafios agrupados por tipo (daily, weekly, special)
  Widget _buildChallengesByType(TreasureController controller, ResponsiveUtils r) {
    print('🎨 _buildChallengesByType() - Total de desafios: ${controller.challenges.length}');
    
    // Agrupar desafios por tipo
    final dailyChallenges = controller.challenges
        .where((c) => c['type'] == 'daily')
        .toList();
    final weeklyChallenges = controller.challenges
        .where((c) => c['type'] == 'weekly')
        .toList();
    final specialChallenges = controller.challenges
        .where((c) => c['type'] == 'special')
        .toList();

    print('📊 Diários: ${dailyChallenges.length}, Semanais: ${weeklyChallenges.length}, Especiais: ${specialChallenges.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Challenges
        if (dailyChallenges.isNotEmpty) ...[
          _buildSectionTitle('Desafios Diários', r),
          _buildChallengesList(dailyChallenges, controller, r),
          SizedBox(height: r.spacing8),
        ],

        // Weekly Challenges
        if (weeklyChallenges.isNotEmpty) ...[
          _buildSectionTitle('Missões Semanais', r),
          _buildChallengesList(weeklyChallenges, controller, r),
          SizedBox(height: r.spacing8),
        ],

        // Special Challenges
        if (specialChallenges.isNotEmpty) ...[
          _buildSectionTitle('Desafios Especiais', r),
          _buildChallengesList(specialChallenges, controller, r),
        ],
      ],
    );
  }

  /// Constrói título de seção
  Widget _buildSectionTitle(String title, ResponsiveUtils r) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.spacing16,
        vertical: r.spacing12,
      ),
      child: Text(title, style: AppTheme.textLgBold),
    );
  }

  /// Constrói lista de desafios
  Widget _buildChallengesList(
    List<Map<String, dynamic>> challenges,
    TreasureController controller,
    ResponsiveUtils r,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.spacing16),
      child: Column(
        children: challenges.map((challengeData) {
          return ChallengeCard(
            challengeData: challengeData,
          );
        }).toList(),
      ),
    );
  }
}
