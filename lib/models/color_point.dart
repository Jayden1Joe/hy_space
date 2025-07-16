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
  final int kelvin;

  const ColorPoint(this.hour, this.minute, this.kelvin);

  int get totalMinutes => hour * 60 + minute;

  Color get color => getColorForKelvin(kelvin);
}
