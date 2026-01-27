import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';

/// Widget de estado vazio para a página de desafios
/// 
/// Exibe o mascote treasure hunter com uma mensagem amigável
/// quando não há desafios disponíveis.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascote treasure hunter
            Image.asset(
              AppAssets.mascotTreasure,
              width: r.wp(60),
              height: r.wp(60),
              fit: BoxFit.contain,
            ),
            
            SizedBox(height: r.spacing24),
            
            // Título
            Text(
              'Nenhum desafio disponível',
              style: AppTheme.displayXsBold.copyWith(
                color: AppTheme.black,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: r.spacing12),
            
            // Mensagem
            Text(
              'Novos desafios aparecerão em breve.\nVolte mais tarde para ganhar recompensas!',
              style: AppTheme.textMdRegular.copyWith(
                color: AppTheme.gray300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
