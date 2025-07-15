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

  TimeOfDay wakeUpTime = TimeOfDay(hour: 7, minute: 30); // 예: 7:30 AM
  TimeOfDay sleepTime = TimeOfDay(hour: 23, minute: 30); // 예: 11:00 PM

  final now = TimeOfDay.fromDateTime(DateTime.now());

  String formatKoreanTime(double x) {
    int hour = x.floor();
    int minute = ((x - hour) * 60).round();

    final isAm = hour < 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = isAm ? '오전' : '오후';

    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }

  String formatKoreanRemainingTime(double x) {
    final wakeUpMinutes = wakeUpTime.hour * 60 + wakeUpTime.minute;
    final sleepMinutes = sleepTime.hour * 60 + sleepTime.minute;

    int totalMinutes = (x * 60).round();

    if (totalMinutes == wakeUpMinutes) {
      return '기상';
    }
    if (totalMinutes == sleepMinutes) {
      return '취침';
    }

    if (totalMinutes < wakeUpMinutes || totalMinutes > sleepMinutes) {
      int diff = wakeUpMinutes - totalMinutes;
      if (diff < 0) diff += 24 * 60; // 다음날 계산
      int hours = diff ~/ 60;
      int minutes = diff % 60;
      if (hours > 0) {
        return '기상까지 $hours시간 $minutes분';
      } else {
        return '기상까지 $minutes분';
      }
    }

    if (totalMinutes > wakeUpMinutes && totalMinutes < sleepMinutes) {
      int diff = sleepMinutes - totalMinutes;
      int hours = diff ~/ 60;
      int minutes = diff % 60;
      if (hours > 0) {
        return '취침까지 $hours시간 $minutes분';
      } else {
        return '취침까지 $minutes분';
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final double nowX = DateTime.now().hour + DateTime.now().minute / 60;
    final timeText = formatKoreanTime(selectedX ?? nowX);
    String remainingTimeText = formatKoreanRemainingTime(selectedX ?? nowX);

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
                    right: 10,
                    left: 10,
                    top: 16,
                    bottom: 0,
                  ),
                  child: Container(child: LineChart(mainData())),
                ),
              ),
            ),
            (selectedX != null && selectedPosition != null)
                ? Positioned(
                    top: 16,
                    left: (selectedPosition!.dx - 60).clamp(
                      15,
                      chartWidth! - 150,
                    ),
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
                        Text(
                          remainingTimeText,
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                : Positioned(
                    top: 16,
                    left: 15,
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
                        Text(
                          remainingTimeText,
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
          if (event is FlLongPressEnd ||
              event is FlPanEndEvent ||
              event is FlTapUpEvent) {
            setState(() {
              selectedX = null;
              selectedPosition = null;
            });
          } else if (response != null && response.lineBarSpots != null) {
            final localPos = event.localPosition;
            setState(() {
              selectedX = response.lineBarSpots!.first.x;
              selectedPosition = localPos;
            });
          }
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

List<Map<String, double>> keyPoints = [
  {'hour': 0, 'minute': 0, 'value': 2},
  {'hour': 1, 'minute': 0, 'value': 0},
  {'hour': 6, 'minute': 0, 'value': 0},
  {'hour': 7, 'minute': 0, 'value': 2},
  {'hour': 7, 'minute': 30, 'value': 7},
  {'hour': 10, 'minute': 0, 'value': 9},
  {'hour': 13, 'minute': 0, 'value': 10},
  {'hour': 21, 'minute': 0, 'value': 4},
  {'hour': 24, 'minute': 0, 'value': 2},
];

List<FlSpot> convertToFlSpots(List<Map<String, dynamic>> points) {
  return points.map((point) {
    final double x = point['hour'] + (point['minute'] / 60.0);
    return FlSpot(x, point['value']);
  }).toList();
}

List<FlSpot> smoothSpots = catmullRomInterpolateWithTension(
  convertToFlSpots(keyPoints),
);
