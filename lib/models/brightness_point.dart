final brightnessPoints = [
  BrightnessPoint(0, 0, 20),
  BrightnessPoint(1, 0, 0), // 7:30
  BrightnessPoint(6, 0, 0), // 8:00
  BrightnessPoint(7, 0, 20), // 23:00
  BrightnessPoint(7, 30, 70),
  BrightnessPoint(10, 0, 90),
  BrightnessPoint(13, 0, 100),
  BrightnessPoint(21, 0, 40),
];

class BrightnessPoint {
  final int hour;
  final int minute;
  final int brightness;

  const BrightnessPoint(this.hour, this.minute, this.brightness);

  int get totalMinutes => hour * 60 + minute;
}
