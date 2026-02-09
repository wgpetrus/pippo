import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/utils/responsive_utils.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../inners/home/controllers/home_stats_controller.dart';
import '../../controllers/onboarding_data_controller.dart';
import '../../controllers/onboarding_flow_controller.dart';

/// Tela de conclusão do onboarding
class ConclusionPage extends StatefulWidget {
  const ConclusionPage({super.key});

  @override
  State<ConclusionPage> createState() => _ConclusionPageState();
}

class _ConclusionPageState extends State<ConclusionPage> with SingleTickerProviderStateMixin {
  // Animações
  late final AnimationController _animController;
  late final Animation<double> _animation;
  late final OnboardingDataController _dataController;
  late final OnboardingFlowController _flowController;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _dataController = Get.find<OnboardingDataController>();
    _flowController = Get.find<OnboardingFlowController>();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);
    
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: AppTheme.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildMascot()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.spacing24),
                child: Column(
                  children: [
                    Text(
                      'onboarding_conclusion_title'.tr,
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacing12),
                    Text(
                      'onboarding_conclusion_subtitle'.tr,
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacing24),
                    
                    // Exibir erro se houver
                    Obx(() => _dataController.errorMessage.value.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(bottom: r.spacing16),
                            child: Text(
                              _dataController.errorMessage.value,
                              style: AppTheme.textSmRegular.copyWith(color: AppTheme.error),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink()),
                    
                    // Exibir mensagem de retry se houver
                    Obx(() => _dataController.retryMessage.value.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(bottom: r.spacing16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    SizedBox(width: r.spacing8),
                                    Flexible(
                                      child: Text(
                                        _dataController.retryMessage.value,
                                        style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: r.spacing8),
                                TextButton(
                                  onPressed: () => _dataController.cancelRetry(),
                                  child: Text(
                                    'onboarding_conclusion_button_cancel'.tr,
                                    style: AppTheme.textSmBold.copyWith(color: AppTheme.error),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink()),
                    
                    Obx(() => AppButton(
                      text: 'onboarding_conclusion_button'.tr,
                      isLoading: _dataController.isLoading.value,
                      onPressed: _dataController.isLoading.value ? null : _onButtonPressed,
                    )),
                    SizedBox(height: r.spacing32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets
  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: child,
      ),
      child: Image.asset(
        AppAssets.mascotConclusion,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  // Métodos
  void _onButtonPressed() {
    if (_dataController.isAddingCourse.value) {
      debugPrint('🎯 _onButtonPressed: Modo add course - chamando finishOnboarding()');
      
      // Chamar finishOnboarding() que vai executar addNewCourse()
      _flowController.finishOnboarding();
      
      // Aguardar conclusão e então resetar estado e navegar
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_dataController.errorMessage.value.isEmpty) {
          debugPrint('✅ Curso adicionado com sucesso, voltando para home');
          _dataController.isAddingCourse.value = false;
          Get.offAllNamed('/home');
          
          // Recarregar cursos no HomeStatsController após voltar
          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              final homeStatsController = Get.find<HomeStatsController>();
              homeStatsController.loadActiveCourse();
              debugPrint('🔄 Cursos recarregados após adicionar novo curso');
            } catch (e) {
              debugPrint('⚠️ HomeStatsController não encontrado ao recarregar cursos');
            }
          });
        } else {
          debugPrint('❌ Erro ao adicionar curso: ${_dataController.errorMessage.value}');
        }
      });
    } else {
      debugPrint('🎯 _onButtonPressed: Modo onboarding normal - chamando finishOnboarding()');
      // Finaliza onboarding normal e salva estados
      _flowController.finishOnboarding();
    }
  }
}
