final brightnessPoints = [
  BrightnessPoint(0, 0, 0),
  BrightnessPoint(6, 0, 0), // 8:00 촛불색
  BrightnessPoint(7, 0, 20), // 23:00
  BrightnessPoint(7, 30, 70),
  BrightnessPoint(13, 0, 100),
  BrightnessPoint(21, 0, 40),
];

class BrightnessPoint {
  final int hour;
  final int minute;
  final int brightness;

  BrightnessPoint(this.hour, this.minute, this.brightness);

  int get totalMinutes => hour * 60 + minute;

  double get timeInHours => hour + minute / 60.0;
}

List<BrightnessPoint> completeBrightnessPoints(List<BrightnessPoint> original) {
  // 정렬 (totalMinutes 기준)
  final sortedPoints = [...brightnessPoints]
    ..sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));

  final first = sortedPoints.first; // 7,30,2000
  final last = sortedPoints.last; //23,30,8000

  final firstStop = first.totalMinutes / 1440; //0.3
  final lastStop = last.totalMinutes / 1440; //0.95

  final isFirstMissing = first.totalMinutes != 0;
  final isLastMissing = last.totalMinutes != 1439;

  if (first.brightness != last.brightness &&
      (isFirstMissing || isLastMissing)) {
    final ratio = (1.0 - lastStop) / ((1.0 - lastStop) + firstStop);
    final delta = (last.brightness - first.brightness).abs();
    int middleBrightness = last.brightness > first.brightness
        ? last.brightness - (delta * ratio).toInt()
        : last.brightness + (delta * ratio).toInt();

    if (isFirstMissing) {
      sortedPoints.insert(0, BrightnessPoint(0, 0, middleBrightness));
    }
    if (isLastMissing) {
      sortedPoints.add(BrightnessPoint(23, 59, middleBrightness));
    }
  }

  return sortedPoints;
}
