import '../../domain/entities/availability.dart';

class AvailabilityModel extends Availability {
  const AvailabilityModel({
    required super.id,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.slotDuration,
    required super.isAvailable,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];

    final normalizedDate = rawDate is String
        ? rawDate.substring(0, 10)
        : (rawDate as DateTime).toIso8601String().substring(0, 10);

    return AvailabilityModel(
      id: (json['_id'] ?? json['id']).toString(),
      date: normalizedDate,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      slotDuration: (json['slotDuration'] as num?)?.toInt() ?? 30,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'slotDuration': slotDuration,
      'isAvailable': isAvailable,
    };
  }
}
