import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_dialog.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../controllers/treasure_challenges_controller.dart';
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
      final challengesController = Get.find<TreasureChallengesController>();
      challengesController.loadChallenges();
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin
    
    final challengesController = Get.find<TreasureChallengesController>();
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
            onPressed: () => _deleteAllChallenges(challengesController),
            backgroundColor: AppTheme.error,
            foregroundColor: AppTheme.white,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Limpar Tudo'),
            heroTag: 'delete',
          ),
          SizedBox(height: r.spacing12),
          // Botão para gerar desafios
          FloatingActionButton.extended(
            onPressed: () => _generateChallenges(challengesController),
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
          if (challengesController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          // Error state
          if (challengesController.errorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(r.spacing24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      challengesController.errorMessage.value,
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray300),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacing16),
                    ElevatedButton(
                      onPressed: () => challengesController.loadChallenges(),
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
          if (challengesController.challenges.isEmpty) {
            return const EmptyState();
          }

          // Challenges list
          return RefreshIndicator(
            onRefresh: () => challengesController.loadChallenges(),
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
                  _buildChallengesByType(challengesController, r),
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
  Future<void> _deleteAllChallenges(TreasureChallengesController challengesController) async {
    // Confirmar ação
    final confirm = await AppDialog.confirm(
      context: context,
      title: 'Deletar Todos os Desafios?',
      message: 'Esta ação não pode ser desfeita.',
      confirmText: 'Deletar',
      cancelText: 'Cancelar',
      confirmColor: AppTheme.red,
    );

    if (confirm != true) return;

    if (!mounted) return;
    AppDialog.loading(context: context, message: 'Deletando...');

    try {
      // Deletar todos os desafios
      await challengesController.deleteAllChallenges();

      if (!mounted) return;
      Get.back();

      // Mostrar sucesso
      AppDialog.success(
        context: context,
        title: 'Sucesso',
        message: 'Todos os desafios foram deletados.',
      );
    } catch (e) {
      if (!mounted) return;
      Get.back();

      // Mostrar erro
      AppDialog.error(
        context: context,
        title: 'Erro',
        message: 'Não foi possível deletar os desafios.',
      );
    }
  }

  /// Gera desafios diários e semanais para desenvolvimento/testes
  Future<void> _generateChallenges(TreasureChallengesController challengesController) async {
    if (!mounted) return;
    AppDialog.loading(context: context, message: 'Gerando desafios...');

    try {
      // Gerar desafios
      await challengesController.generateDailyChallenges();
      await challengesController.generateWeeklyChallenges();

      if (!mounted) return;
      Get.back();

      // Mostrar sucesso
      AppDialog.success(
        context: context,
        title: 'Sucesso',
        message: 'Desafios diários e semanais foram gerados.',
      );
    } catch (e) {
      if (!mounted) return;
      Get.back();

      // Mostrar erro
      AppDialog.error(
        context: context,
        title: 'Erro',
        message: 'Não foi possível gerar desafios. Tente novamente.',
      );
    }
  }

  // Widgets privados

  /// Constrói desafios agrupados por tipo (daily, weekly, special)
  Widget _buildChallengesByType(TreasureChallengesController challengesController, ResponsiveUtils r) {
    // Agrupar desafios por tipo
    final dailyChallenges = challengesController.challenges
        .where((c) => c['type'] == 'daily')
        .toList();
    final weeklyChallenges = challengesController.challenges
        .where((c) => c['type'] == 'weekly')
        .toList();
    final specialChallenges = challengesController.challenges
        .where((c) => c['type'] == 'special')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Challenges
        if (dailyChallenges.isNotEmpty) ...[
          _buildSectionTitle('Desafios Diários', r),
          _buildChallengesList(dailyChallenges, r),
          SizedBox(height: r.spacing8),
        ],

        // Weekly Challenges
        if (weeklyChallenges.isNotEmpty) ...[
          _buildSectionTitle('Missões Semanais', r),
          _buildChallengesList(weeklyChallenges, r),
          SizedBox(height: r.spacing8),
        ],

        // Special Challenges
        if (specialChallenges.isNotEmpty) ...[
          _buildSectionTitle('Desafios Especiais', r),
          _buildChallengesList(specialChallenges, r),
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
