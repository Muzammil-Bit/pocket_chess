class TimeControl {
  const TimeControl({
    required this.initialTime,
    this.increment = Duration.zero,
  });

  final Duration initialTime;
  final Duration increment;

  String get label {
    final minutes = initialTime.inMinutes;
    final incSeconds = increment.inSeconds;
    if (incSeconds > 0) {
      return '$minutes | $incSeconds';
    }
    return '$minutes min';
  }

  String get category {
    final totalSeconds = initialTime.inSeconds + (increment.inSeconds * 40);
    if (totalSeconds < 180) return 'Bullet';
    if (totalSeconds < 600) return 'Blitz';
    if (totalSeconds < 1800) return 'Rapid';
    return 'Classical';
  }

  Map<String, dynamic> toJson() => {
    'initialTimeMs': initialTime.inMilliseconds,
    'incrementMs': increment.inMilliseconds,
  };

  static TimeControl fromJson(Map<String, dynamic> json) {
    return TimeControl(
      initialTime: Duration(
        milliseconds: (json['initialTimeMs'] as int?) ?? 300000,
      ),
      increment: Duration(
        milliseconds: (json['incrementMs'] as int?) ?? 0,
      ),
    );
  }

  static const presets = [
    TimeControl(initialTime: Duration(minutes: 1)),
    TimeControl(initialTime: Duration(minutes: 2), increment: Duration(seconds: 1)),
    TimeControl(initialTime: Duration(minutes: 3)),
    TimeControl(initialTime: Duration(minutes: 3), increment: Duration(seconds: 2)),
    TimeControl(initialTime: Duration(minutes: 5)),
    TimeControl(initialTime: Duration(minutes: 5), increment: Duration(seconds: 3)),
    TimeControl(initialTime: Duration(minutes: 10)),
    TimeControl(initialTime: Duration(minutes: 15), increment: Duration(seconds: 10)),
    TimeControl(initialTime: Duration(minutes: 30)),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeControl &&
          initialTime == other.initialTime &&
          increment == other.increment;

  @override
  int get hashCode => Object.hash(initialTime, increment);
}
