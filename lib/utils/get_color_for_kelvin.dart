import 'package:flutter/material.dart';

const Map<int, Color> kelvinMap = {
  2000: Color.fromRGBO(255, 167, 108, 1), // 촛불색
  4000: Color.fromRGBO(255, 245, 206, 1), // 주백색 웜 화이트
  5000: Color.fromARGB(255, 242, 245, 255), // 주광색 쿨 화이트 가장 자연광에 가까운 색
  6000: Color.fromARGB(255, 199, 224, 255), // 시원한 주광색
  8000: Color.fromARGB(255, 159, 191, 255), // 찬 푸른빛
};

Color getColorForKelvin(int kelvin) {
  if (kelvin <= 2000) return kelvinMap[2000]!;
  if (kelvin >= 8000) return kelvinMap[8000]!;

  final keys = kelvinMap.keys.toList()..sort();

  for (int i = 0; i < keys.length - 1; i++) {
    final lower = keys[i];
    final upper = keys[i + 1];

    if (kelvin >= lower && kelvin <= upper) {
      final t = (kelvin - lower) / (upper - lower);
      return Color.lerp(kelvinMap[lower], kelvinMap[upper], t)!;
    }
  }

  return kelvinMap[4000]!; // fallback (절대 도달 안함, 안전장치)
}
