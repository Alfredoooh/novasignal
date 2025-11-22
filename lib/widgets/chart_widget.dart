import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatelessWidget {
  final List<double> data;
  final List<String> months;

  const ChartWidget({
    super.key,
    required this.data,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 25),
      child: Stack(
        children: [
          _buildGridLines(),
          _buildLineChart(),
          const Positioned(
            right: 0,
            top: 70,
            child: Text(
              '6,18K',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF375F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLines() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        return Container(
          height: 0.5,
          color: Colors.white.withOpacity(0.2),
        );
      }),
    );
  }

  Widget _buildLineChart() {
    final validData = data.where((v) => v > 0).toList();
    if (validData.isEmpty) return const SizedBox();

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      if (data[i] > 0) {
        spots.add(FlSpot(i.toDouble(), data[i]));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: data.reduce((a, b) => a > b ? a : b) * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: const Color(0xFFFF375F),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFFFF375F),
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${months[spot.x.toInt()]}\n${spot.y.toStringAsFixed(0)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ),
    );
  }
}