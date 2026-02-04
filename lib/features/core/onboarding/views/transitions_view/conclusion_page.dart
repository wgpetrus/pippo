import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/theme/theme.dart';
import '../../../../../shared/utils/app_assets.dart';
import '../../../../../shared/utils/responsive_utils.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../inners/home/controllers/home_controller.dart';
import '../../controllers/onboarding_controller.dart';

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
  late final OnboardingController _controller;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
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
                      'Estava te esperando! Vamos nos divertir.',
                      style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacing12),
                    Text(
                      'Seu curso está pronto e esperando — a apenas um clique.',
                      style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacing24),
                    
                    // Exibir erro se houver
                    Obx(() => _controller.errorMessage.value.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(bottom: r.spacing16),
                            child: Text(
                              _controller.errorMessage.value,
                              style: AppTheme.textSmRegular.copyWith(color: AppTheme.error),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink()),
                    
                    // Exibir mensagem de retry se houver
                    Obx(() => _controller.retryMessage.value.isNotEmpty
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
                                        _controller.retryMessage.value,
                                        style: AppTheme.textSmRegular.copyWith(color: AppTheme.gray600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: r.spacing8),
                                TextButton(
                                  onPressed: () => _controller.cancelRetry(),
                                  child: Text(
                                    'Cancelar',
                                    style: AppTheme.textSmBold.copyWith(color: AppTheme.error),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink()),
                    
                    Obx(() => AppButton(
                      text: 'Vamos Aprender',
                      isLoading: _controller.isLoading.value,
                      onPressed: _controller.isLoading.value ? null : _onButtonPressed,
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
    if (_controller.isAddingCourse.value) {
      debugPrint('🎯 _onButtonPressed: Modo add course - chamando completeOnboarding()');
      
      // Chamar completeOnboarding() que vai executar addNewCourse()
      _controller.completeOnboarding();
      
      // Aguardar conclusão e então resetar estado e navegar
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_controller.errorMessage.value.isEmpty) {
          debugPrint('✅ Curso adicionado com sucesso, voltando para home');
          _controller.isAddingCourse.value = false;
          Get.offAllNamed('/home');
          
          // Recarregar cursos no HomeController após voltar
          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              final homeController = Get.find<HomeController>();
              homeController.loadUserCourses();
              debugPrint('🔄 Cursos recarregados após adicionar novo curso');
            } catch (e) {
              debugPrint('⚠️ HomeController não encontrado ao recarregar cursos');
            }
          });
        } else {
          debugPrint('❌ Erro ao adicionar curso: ${_controller.errorMessage.value}');
        }
      });
    } else {
      debugPrint('🎯 _onButtonPressed: Modo onboarding normal - chamando completeOnboarding()');
      // Finaliza onboarding normal e salva estados
      _controller.completeOnboarding();
    }
  }
}
