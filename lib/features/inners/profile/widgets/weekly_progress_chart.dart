import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../shared/theme/theme.dart';

/// Gráfico de progresso semanal
class WeeklyProgressChart extends StatelessWidget {
  final List<ChartData> userProgress;
  final List<ChartData> otherProgress;
  final bool showOther;

  const WeeklyProgressChart({
    super.key,
    required this.userProgress,
    required this.otherProgress,
    this.showOther = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray600, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text('Progresso semanal', style: AppTheme.textLgBold),
          const SizedBox(height: 12),

          // Legenda
          Row(
            children: [
              _buildLegendItem('Sam', AppTheme.primary, true),
              const SizedBox(width: 16),
              if (showOther) _buildLegendItem('Me', AppTheme.gray400, false),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: AppTheme.textSmRegular.copyWith(color: AppTheme.gray300),
              ),
              primaryYAxis: NumericAxis(
                isVisible: true,
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: AppTheme.gray600_30,
                ),
                axisLine: const AxisLine(width: 0),
                labelStyle: AppTheme.textSmRegular.copyWith(color: AppTheme.gray300),
                minimum: 0,
                maximum: 1200,
                interval: 250,
              ),
              series: <CartesianSeries>[
                // Linha do outro usuário (cinza)
                if (showOther)
                  SplineSeries<ChartData, String>(
                    dataSource: otherProgress,
                    xValueMapper: (ChartData data, _) => data.day,
                    yValueMapper: (ChartData data, _) => data.xp,
                    color: AppTheme.gray400,
                    width: 3,
                    splineType: SplineType.natural,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      width: 10,
                      height: 10,
                      borderWidth: 3,
                      borderColor: AppTheme.white,
                    ),
                  ),

                // Linha do usuário (azul) com gradiente
                SplineAreaSeries<ChartData, String>(
                  dataSource: userProgress,
                  xValueMapper: (ChartData data, _) => data.day,
                  yValueMapper: (ChartData data, _) => data.xp,
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primary30,
                      AppTheme.primary05,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderColor: AppTheme.primary,
                  borderWidth: 3,
                  splineType: SplineType.natural,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 10,
                    height: 10,
                    borderWidth: 3,
                    borderColor: AppTheme.white,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildLegendItem(String label, Color color, bool isSelected) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color : AppTheme.white,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTheme.textSmRegular.copyWith(
            color: isSelected ? AppTheme.black : AppTheme.gray300,
          ),
        ),
      ],
    );
  }
}

/// Modelo de dados para o gráfico
class ChartData {
  final String day;
  final double xp;

  ChartData(this.day, this.xp);
}
