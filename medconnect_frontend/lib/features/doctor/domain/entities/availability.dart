class Availability {
  const Availability({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
    required this.isAvailable,
  });

  final String id;

  /// Date-only value in YYYY-MM-DD format.
  final String date;

  /// 24-hour time, e.g. 09:00.
  final String startTime;
  final String endTime;

  final int slotDuration;
  final bool isAvailable;

  int get totalSlots {
    final start = _minutes(startTime);
    final end = _minutes(endTime);

    if (end <= start || slotDuration <= 0) return 0;

    return (end - start) ~/ slotDuration;
  }

  List<String> get generatedSlots {
    final start = _minutes(startTime);
    final end = _minutes(endTime);
    final slots = <String>[];

    if (slotDuration <= 0 || end <= start) return slots;

    for (
      var minute = start;
      minute + slotDuration <= end;
      minute += slotDuration
    ) {
      final hour = minute ~/ 60;
      final mins = minute % 60;

      slots.add(
        '${hour.toString().padLeft(2, '0')}:'
        '${mins.toString().padLeft(2, '0')}',
      );
    }

    return slots;
  }

  static int _minutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;

    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }
}
