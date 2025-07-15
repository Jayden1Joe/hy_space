import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hy_space/resources/colors.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    Color.fromARGB(255, 255, 194, 151),
    Color.fromARGB(255, 255, 194, 151),
    Color.fromARGB(255, 255, 194, 151),
    Color(0xFFADD8FF),
    Color(0xFFE0ECFF),
    Color(0xFFE0ECFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFF4E5),
    Color.fromARGB(255, 255, 204, 167),
    Color.fromARGB(255, 255, 194, 151),
  ];
  double? selectedX;
  double? chartWidth;
  Offset? selectedPosition;

  String formatKoreanTime(double x) {
    int hour = x.floor();
    int minute = ((x - hour) * 60).round();

    final isAm = hour < 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = isAm ? '오전' : '오후';

    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timeText = selectedX != null ? formatKoreanTime(selectedX!) : '';

    return LayoutBuilder(
      builder: (context, constraints) {
        chartWidth = constraints.maxWidth;
        return Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: AspectRatio(
                aspectRatio: 3,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 4,
                    left: 4,
                    top: 16,
                    bottom: 0,
                  ),
                  child: Container(child: LineChart(mainData())),
                ),
              ),
            ),
            if (selectedX != null && selectedPosition != null)
              Positioned(
                top: 16,
                left: (selectedPosition!.dx - 60).clamp(15, chartWidth! - 150),
                child: Column(
                  children: [
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '취침까지 4시간 10분',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.white,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('오전 12시', style: style);
        break;
      case 8:
        text = const Text('오전 6시', style: style);
        break;
      case 14:
        text = const Text('오후 12시', style: style);
        break;
      case 20:
        text = const Text('오후 6시', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(meta: meta, child: text);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    String text = '';

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) => null).toList();
          },
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          if (response == null || response.lineBarSpots == null) return;

          final localPos = event.localPosition;
          setState(() {
            selectedX = response.lineBarSpots!.first.x;
            selectedPosition = localPos;
          });
        },
      ),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 25,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 24,
      minY: 0,
      maxY: 13,
      lineBarsData: [
        LineChartBarData(
          spots: smoothSpots,

          isCurved: true,
          curveSmoothness: 0.2,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.25))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

List<FlSpot> catmullRomInterpolateWithTension(
  List<FlSpot> points, {
  int resolutionPerHour = 60,
  double curveSmoothness = 0.7,
}) {
  double _catmullRomTension(
    double t,
    double p0,
    double p1,
    double p2,
    double p3,
    double tension,
  ) {
    double t2 = t * t;
    double t3 = t2 * t;

    double a0 = -tension * t3 + 2 * tension * t2 - tension * t;
    double a1 = (2 - tension) * t3 + (tension - 3) * t2 + 1;
    double a2 = (tension - 2) * t3 + (3 - 2 * tension) * t2 + tension * t;
    double a3 = tension * t3 - tension * t2;

    return a0 * p0 + a1 * p1 + a2 * p2 + a3 * p3;
  }

  List<FlSpot> result = [];

  // tension은 일반적으로 0.0 ~ 1.0 사이에서 조절
  double tension = (1.0 - curveSmoothness).clamp(0.0, 1.0);

  for (int i = 0; i < points.length - 1; i++) {
    FlSpot p0 = i == 0 ? points[i] : points[i - 1];
    FlSpot p1 = points[i];
    FlSpot p2 = points[i + 1];
    FlSpot p3 = (i + 2 < points.length) ? points[i + 2] : points[i + 1];

    double startX = p1.x;
    double endX = p2.x;
    int segments = ((endX - startX) * resolutionPerHour).round();

    for (int j = 0; j <= segments; j++) {
      double t = j / segments;

      double x = _catmullRomTension(t, p0.x, p1.x, p2.x, p3.x, tension);
      double y = _catmullRomTension(t, p0.y, p1.y, p2.y, p3.y, tension);

      result.add(FlSpot(x, y + .6));
    }
  }

  return result.where((spot) => spot.x <= 23.9833).toList();
}

List<FlSpot> keySpots = [
  FlSpot(0, 2),
  FlSpot(1, 0),
  FlSpot(6, 0),
  FlSpot(7, 2),
  FlSpot(7.5, 7),
  FlSpot(10, 9),
  FlSpot(13, 10),
  FlSpot(21, 4),
  FlSpot(24, 2),
];

List<FlSpot> smoothSpots = catmullRomInterpolateWithTension(keySpots);
