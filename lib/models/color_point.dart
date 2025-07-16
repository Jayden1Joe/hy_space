import 'package:flutter/material.dart';
import 'package:hy_space/utils/get_color_for_kelvin.dart';

final colorPoints = [
  ColorPoint(6, 0, 2000),
  ColorPoint(7, 30, 8000),
  ColorPoint(23, 30, 2000),
];

class ColorPoint {
  final int hour;
  final int minute;
  int kelvin;

  ColorPoint(this.hour, this.minute, this.kelvin);

  int get totalMinutes => hour * 60 + minute;

  Color get color => getColorForKelvin(kelvin);

  static List<Color> toGradientColors(List<ColorPoint> points) {
    final sorted = [...points]
      ..sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
    return sorted.map((p) => p.color).toList();
  }

  static List<double> toGradientStops(List<ColorPoint> points) {
    final sorted = [...points]
      ..sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
    return sorted.map((p) => p.totalMinutes / 1440).toList();
  }
}

class CustomKelvinGradient {
  final List<ColorPoint> colorPoints;

  CustomKelvinGradient(this.colorPoints);

  /// 보간을 위한 헬퍼: kelvinMap 기반 lerp
  Color lerpKelvinColor(double kelvin) {
    final keys = kelvinMap.keys.toList()..sort();
    for (int i = 0; i < keys.length - 1; i++) {
      final low = keys[i].toDouble();
      final high = keys[i + 1].toDouble();
      if (kelvin >= low && kelvin <= high) {
        final t = (kelvin - low) / (high - low);
        return Color.lerp(kelvinMap[low.toInt()], kelvinMap[high.toInt()], t)!;
      }
    }
    // 범위 밖은 가장 가까운 색 반환
    if (kelvin < keys.first) return kelvinMap[keys.first]!;
    return kelvinMap[keys.last]!;
  }

  /// colors, stops를 만들고 LinearGradient 반환
  LinearGradient generateGradient() {
    // 1. 시간 순 정렬
    final sortedPoints = [...colorPoints]
      ..sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));

    final List<Color> gradientColors = [];
    final List<double> gradientStops = [];

    // 2. 각 ColorPoint별로 위치와 색상을 결정, 중간은 kelvinMap 기반 보간
    for (int i = 0; i < sortedPoints.length; i++) {
      final cp = sortedPoints[i];
      final pos = cp.totalMinutes / 1440;

      gradientStops.add(pos);
      gradientColors.add(lerpKelvinColor(cp.kelvin.toDouble()));

      // 구간 사이 세부 스텝 넣고 싶으면 여기서 처리 가능
      if (i < sortedPoints.length - 1) {
        final nextCp = sortedPoints[i + 1];
        final startMin = cp.totalMinutes;
        final endMin = nextCp.totalMinutes;

        // 예: 중간에 4단계 보간 (조절 가능)
        const int steps = 4;
        for (int step = 1; step < steps; step++) {
          final interpMin = startMin + (endMin - startMin) * (step / steps);
          final interpPos = interpMin / 1440;

          // 시간대별 켈빈 보간
          final interpKelvin =
              cp.kelvin + (nextCp.kelvin - cp.kelvin) * (step / steps);
          gradientStops.add(interpPos);
          gradientColors.add(lerpKelvinColor(interpKelvin));
        }
      }
    }

    // Wrap-around from last to first (simulate 24h loop)
    if (sortedPoints.length >= 2) {
      final last = sortedPoints.last;
      final first = sortedPoints.first;

      final startMin = last.totalMinutes;
      final endMin = first.totalMinutes + 1440;

      const int steps = 4;
      for (int step = 1; step < steps; step++) {
        final interpMin = startMin + (endMin - startMin) * (step / steps);
        final interpPos = interpMin / 1440;

        final interpKelvin =
            last.kelvin + (first.kelvin - last.kelvin) * (step / steps);
        gradientStops.add(interpPos % 1); // normalize back to 0~1
        gradientColors.add(lerpKelvinColor(interpKelvin.toDouble()));
      }
    }

    return LinearGradient(
      colors: gradientColors,
      stops: gradientStops,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  LinearGradient generateGradientWithOpacity(double opacity) {
    final baseGradient = generateGradient();

    return LinearGradient(
      colors: baseGradient.colors.map((c) => c.withOpacity(opacity)).toList(),
      stops: baseGradient.stops,
      begin: baseGradient.begin,
      end: baseGradient.end,
    );
  }
}
