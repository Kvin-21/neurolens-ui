import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Helper utilities for creating consistent charts throughout the app.
class ChartHelpers {
  static List<Color> gradientColours(Color baseColour) {
    return [baseColour.withOpacity(0.8), baseColour.withOpacity(0.3)];
  }

  static LineChartBarData lineChartBar(
    List<FlSpot> spots,
    Color colour, {
    bool showDots = true,
    bool showArea = true,
    double strokeWidth = 3.0,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      gradient: LinearGradient(
        colors: gradientColours(colour),
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      barWidth: strokeWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: showDots,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 4,
          color: colour,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: showArea,
        gradient: LinearGradient(
          colors: [colour.withOpacity(0.3), colour.withOpacity(0.1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  static FlTitlesData chartTitles({
    required List<String> bottomTitles,
    bool showLeftTitles = true,
    bool showRightTitles = false,
    bool showTopTitles = false,
    double? leftInterval,
    double? bottomInterval,
  }) {
    return FlTitlesData(
      show: true,
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: showRightTitles)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: showTopTitles)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: bottomInterval ?? (bottomTitles.length > 10 ? bottomTitles.length / 5 : 1),
          getTitlesWidget: (double value, TitleMeta meta) {
            final index = value.toInt();
            if (index >= 0 && index < bottomTitles.length) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  bottomTitles[index],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLeftTitles,
          interval: leftInterval,
          getTitlesWidget: (double value, TitleMeta meta) {
            return Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
          reservedSize: 32,
        ),
      ),
    );
  }

  static FlGridData chartGrid({
    bool show = true,
    bool drawVerticalLine = true,
    bool drawHorizontalLine = true,
    double? horizontalInterval,
    double? verticalInterval,
  }) {
    return FlGridData(
      show: show,
      drawVerticalLine: drawVerticalLine,
      drawHorizontalLine: drawHorizontalLine,
      horizontalInterval: horizontalInterval,
      verticalInterval: verticalInterval,
      getDrawingHorizontalLine: (value) =>
          FlLine(color: Colors.grey.shade300, strokeWidth: 1),
      getDrawingVerticalLine: (value) =>
          FlLine(color: Colors.grey.shade300, strokeWidth: 1),
    );
  }

  static FlBorderData chartBorder({bool show = true, Color? colour}) {
    return FlBorderData(
      show: show,
      border: Border.all(color: colour ?? Colors.grey.shade300, width: 1),
    );
  }

  static LineTouchData chartTooltip({
    required List<String> xAxisLabels,
    String? unit,
  }) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Colors.black87,
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            final flSpot = barSpot;
            final index = flSpot.x.toInt();
            final xLabel = index < xAxisLabels.length ? xAxisLabels[index] : '';
            final value = unit != null
                ? '${flSpot.y.toStringAsFixed(1)} $unit'
                : flSpot.y.toStringAsFixed(1);

            return LineTooltipItem(
              '$xLabel\n$value',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  static List<PieChartSectionData> pieChartSections(
    Map<String, double> data,
    List<Color> colours,
  ) {
    final total = data.values.reduce((a, b) => a + b);
    final entries = data.entries.toList();

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final dataEntry = entry.value;
      final percentage = (dataEntry.value / total * 100);

      return PieChartSectionData(
        color: colours[index % colours.length],
        value: dataEntry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  static Widget legend(Map<String, Color> items) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: entry.value,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        );
      }).toList(),
    );
  }

  static BarChartData barChart(
    List<BarChartGroupData> barGroups, {
    double? maxY,
    FlTitlesData? titlesData,
    FlGridData? gridData,
    FlBorderData? borderData,
  }) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.black87,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.toStringAsFixed(1),
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      titlesData: titlesData ?? FlTitlesData(show: false),
      borderData: borderData ?? chartBorder(),
      barGroups: barGroups,
      gridData: gridData ?? chartGrid(),
      maxY: maxY,
    );
  }

  static List<BarChartGroupData> barGroups(
    List<double> values,
    Color colour, {
    double width = 16,
  }) {
    return values.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: colour,
            width: width,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  /// Returns a colour based on normalised score (0–1).
  static Color colourForScore(double score, {double maxScore = 10.0}) {
    final normalised = score / maxScore;
    if (normalised >= 0.8) return Colors.green;
    if (normalised >= 0.6) return Colors.orange;
    if (normalised >= 0.4) return Colors.red;
    return Colors.grey;
  }

  static String formatDuration(double seconds) {
    if (seconds < 60) return '${seconds.toStringAsFixed(1)}s';
    if (seconds < 3600) {
      final minutes = (seconds / 60).floor();
      final remainingSeconds = (seconds % 60).floor();
      return '${minutes}m ${remainingSeconds}s';
    }
    final hours = (seconds / 3600).floor();
    final remainingMinutes = ((seconds % 3600) / 60).floor();
    return '${hours}h ${remainingMinutes}m';
  }

  static String formatFrequency(double frequency) {
    if (frequency < 1000) return '${frequency.toStringAsFixed(0)} Hz';
    return '${(frequency / 1000).toStringAsFixed(1)} kHz';
  }

  static List<FlSpot> spotsFromData(
    List<Map<String, dynamic>> data,
    String field,
  ) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value[field] as double? ?? 0.0;
      return FlSpot(index.toDouble(), value);
    }).toList();
  }
}