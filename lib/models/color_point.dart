import 'package:flutter/material.dart';
import 'package:hy_space/utils/get_color_for_kelvin.dart';

final colorPoints = [
  ColorPoint(3, 0, 8000),
  ColorPoint(7, 30, 8000),
  ColorPoint(22, 00, 2000),
];

class ColorPoint {
  final int hour;
  final int minute;
  int kelvin;

  ColorPoint(this.hour, this.minute, this.kelvin);

  int get totalMinutes => hour * 60 + minute;

  Color get color => getColorForKelvin(kelvin);

  /// 주어진 ColorPoint 리스트를 시간 순으로 정렬한 후,
  /// 각 ColorPoint에서 색상(Color)만 추출하여 Gradient용 리스트로 반환한다.
  /// 즉, 시간 흐름에 따른 색상 그라디언트를 만들기 위한 준비 함수.
  ///
  /// 예: [ColorPoint(6:00, blue), ColorPoint(12:00, white), ColorPoint(18:00, orange)]
  /// → [blue, white, orange]
  static List<Color> toGradientColors(List<ColorPoint> points) {
    // 원본 리스트를 복사하고 시간 순으로 정렬
    final sorted = [...points]
      ..sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));

    // 정렬된 리스트에서 color만 추출해 반환
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

    // 1.1 00:00과 23:59가 없으면 추가
    final first = sortedPoints.first; // 7,30,2000
    final last = sortedPoints.last; //23,30,8000

    final firstStop = first.totalMinutes / 1440; //0.3
    final lastStop = last.totalMinutes / 1440; //0.95

    final isFirstMissing = first.totalMinutes != 0;
    final isLastMissing = last.totalMinutes != 1439;

    if (first.kelvin != last.kelvin && (isFirstMissing || isLastMissing)) {
      final ratio = (1.0 - lastStop) / ((1.0 - lastStop) + firstStop);
      final delta = (last.kelvin - first.kelvin).abs();
      int middleKelvin = last.kelvin > first.kelvin
          ? last.kelvin - (delta * ratio).toInt()
          : last.kelvin + (delta * ratio).toInt();

      if (isFirstMissing) {
        sortedPoints.insert(0, ColorPoint(0, 0, middleKelvin));
      }
      if (isLastMissing) {
        sortedPoints.add(ColorPoint(23, 59, middleKelvin));
      }
    }

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
