import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';

/// Tela de sucesso após vincular número de telefone
class PhoneLinkedPage extends StatefulWidget {
  const PhoneLinkedPage({super.key});

  @override
  State<PhoneLinkedPage> createState() => _PhoneLinkedPageState();
}

class _PhoneLinkedPageState extends State<PhoneLinkedPage>
    with SingleTickerProviderStateMixin {
  // Animação
  late AnimationController _mascotController;
  late Animation<double> _mascotAnim;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _mascotAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Mascote animado
              AnimatedBuilder(
                animation: _mascotController,
                builder: (context, child) {
                  final value = _mascotAnim.value;
                  return Transform.translate(
                    offset: Offset(0, -value * 10),
                    child: child,
                  );
                },
                child: Image.asset(
                  AppAssets.mascotPause,
                  width: 280,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 32),

              // Título
              Text(
                'Seu Número Está Vinculado!',
                style: AppTheme.displayXsBold.copyWith(color: AppTheme.black),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Descrição
              Text(
                "Usaremos isso para enviar seus códigos mágicos e proteger suas gemas.",
                style: AppTheme.textMdRegular.copyWith(color: AppTheme.gray200),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Botão Back to home
              AppButton(
                text: 'Voltar para o início',
                onPressed: () => Get.offAllNamed('/home'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
