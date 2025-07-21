final brightnessPoints = [
  BrightnessPoint(6, 0, 0, 2000), // 8:00
  BrightnessPoint(7, 0, 20, 2000), // 23:00
  BrightnessPoint(7, 30, 70, 8000),
  BrightnessPoint(13, 0, 100),
  BrightnessPoint(21, 0, 40),
  BrightnessPoint(23, 59, 0, 2000),
];

class BrightnessPoint {
  final int hour;
  final int minute;
  final int brightness;
  int? kelvin;

  BrightnessPoint(this.hour, this.minute, this.brightness, [this.kelvin]);

  int get totalMinutes => hour * 60 + minute;

  double get timeInHours => hour + minute / 60.0;
}
