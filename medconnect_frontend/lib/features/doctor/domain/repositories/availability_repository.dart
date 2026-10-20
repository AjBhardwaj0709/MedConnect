import '../entities/availability.dart';

abstract class AvailabilityRepository {
  Future<List<Availability>> getAvailability();

  Future<Availability> createAvailability({
    required String date,
    required String startTime,
    required String endTime,
    required int slotDuration,
  });

  Future<Availability> updateAvailability({
    required String id,
    required String date,
    required String startTime,
    required String endTime,
    required int slotDuration,
    required bool isAvailable,
  });

  Future<void> deleteAvailability(String id);
}
