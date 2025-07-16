import 'package:flutter/material.dart';

const Map<int, Color> kelvinMap = {
  2000: Color.fromARGB(255, 255, 187, 120),
  4000: Color.fromARGB(255, 255, 223, 189),
  5000: Color.fromARGB(255, 240, 232, 219),
  6000: Color.fromRGBO(203, 227, 255, 1),
  8000: Color.fromARGB(255, 169, 198, 255),
};

Color getColorForKelvin(int kelvin) {
  if (kelvin <= 2000) return kelvinMap[2000]!;
  if (kelvin >= 8000) return kelvinMap[8000]!;

  final keys = kelvinMap.keys.toList()..sort(); // [2000,4000,5000,6000,8000]

  for (int i = 0; i < keys.length - 1; i++) {
    final lower = keys[i];
    final upper = keys[i + 1];

    if (kelvin >= lower && kelvin <= upper) {
      //캘빈 값이 구간안에 있으면
      final t =
          (kelvin - lower) /
          (upper -
              lower); //보간 비율 계산 2200일 경우 (2200 - 2000) / (3000 - 2000) = 0.2 0에서 1사이 값
      return Color.lerp(
        kelvinMap[lower],
        kelvinMap[upper],
        t,
      )!; //캘빈값 사이를 비율 만큼 계산한 컬러를 돌려줌
    }
  }

  return kelvinMap[4000]!; // fallback (절대 도달 안함, 안전장치)
}
