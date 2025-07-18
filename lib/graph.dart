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
  int? selectedY;
  double? chartWidth;
  Offset? selectedPosition;

  TimeOfDay wakeUpTime = TimeOfDay(hour: 7, minute: 30); // 예: 7:30 AM
  TimeOfDay sleepTime = TimeOfDay(hour: 23, minute: 30); // 예: 11:00 PM

  final now = TimeOfDay.fromDateTime(DateTime.now());

  String formatKoreanTime(double x) {
    int hour = x.floor();
    int minute = ((x - hour) * 60).round();

    if (minute == 60) {
      minute = 0;
      hour += 1;
    }

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
              padding: const EdgeInsets.only(top: 80), //글자와 그래프 사이 간격
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
                          style: TextStyle(fontSize: 15, color: Colors.white70),
                        ),
                        Text(
                          '밝기 $selectedY',
                          style: TextStyle(fontSize: 15, color: Colors.white70),
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
        text = const Text('오전 12시 ', style: style);
        break;
      case 8:
        text = const Text('오전 6시  ', style: style);
        break;
      case 14:
        text = const Text('오후 12시 ', style: style);
        break;
      case 20:
        text = const Text('오후 6시  ', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(meta: meta, child: text);
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        //터치할때 반응 구현
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) => null).toList();
          },
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          if (event is FlLongPressEnd ||
              event is FlPanEndEvent ||
              event is FlTapUpEvent) {
            //터치 안하고 있을땐 Null
            setState(() {
              selectedX = null;
              selectedPosition = null;
            });
          } else if (response != null && response.lineBarSpots != null) {
            //터치 중일때
            final localPos = event.localPosition;
            setState(() {
              //터치 중인 곳의 값을 넣음
              selectedX = response.lineBarSpots!.first.x; //x축의 값: 시간
              selectedY = ((response.lineBarSpots!.first.y - 0.5) * 10)
                  .toInt()
                  .clamp(0, 100); //y축의 값: 밝기, 그래프 모양 예쁘게 하려고 0.5 더한거 뺌
              selectedPosition = localPos;
            });
          }
        },
        getTouchedSpotIndicator: (barData, spotIndexes) {
          final LinearGradient? gradient = barData.gradient is LinearGradient
              ? barData.gradient as LinearGradient
              : null;
          final colorStops = gradient?.getSafeColorStops();
          return spotIndexes.map((index) {
            final spot = barData.spots[index];
            final t = spot.x / 24.0; // Normalize to 0~1 for full day
            final gradientColor = gradient != null && colorStops != null
                ? lerpGradient(gradient.colors, colorStops, t)
                : gradientColors.first;

            return TouchedSpotIndicatorData(
              FlLine(color: gradientColor.withOpacity(0.8), strokeWidth: 3.5),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(radius: 6, color: gradientColor),
              ),
            );
          }).toList();
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

      result.add(FlSpot(x, y + .5)); //선이 굵어서 바닥을 뚫어서 y값을 조금 더해서 그래프 전체를 들어 올림
    }
  }

  return result.where((spot) => spot.x <= 23.9833).toList();
}

Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  final length = colors.length;
  if (stops.length != length) {
    stops = List.generate(length, (i) => (i + 1) / length);
  }

  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s];
    final rightStop = stops[s + 1];

    final leftColor = colors[s];
    final rightColor = colors[s + 1];

    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}

extension GradientUtils on LinearGradient {
  List<double> getSafeColorStops() {
    if (stops != null && stops!.length == colors.length) {
      return stops!;
    }

    if (colors.length <= 1) {
      throw ArgumentError('"colors" must have length > 1.');
    }

    final step = 1.0 / (colors.length - 1);
    return List.generate(colors.length, (index) => index * step);
  }
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
