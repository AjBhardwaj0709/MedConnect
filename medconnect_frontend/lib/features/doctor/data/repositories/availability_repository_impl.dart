import '../../domain/entities/availability.dart';
import '../../domain/repositories/availability_repository.dart';
import '../datasources/availability_remote_data_source.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  AvailabilityRepositoryImpl(this._remoteDataSource);

  final AvailabilityRemoteDataSource _remoteDataSource;

  @override
  Future<List<Availability>> getAvailability() {
    return _remoteDataSource.getAvailability();
  }

  @override
  Future<Availability> createAvailability({
    required String date,
    required String startTime,
    required String endTime,
    required int slotDuration,
  }) {
    return _remoteDataSource.createAvailability(
      date: date,
      startTime: startTime,
      endTime: endTime,
      slotDuration: slotDuration,
    );
  }

  @override
  Future<Availability> updateAvailability({
    required String id,
    required String date,
    required String startTime,
    required String endTime,
    required int slotDuration,
    required bool isAvailable,
  }) {
    return _remoteDataSource.updateAvailability(
      id: id,
      date: date,
      startTime: startTime,
      endTime: endTime,
      slotDuration: slotDuration,
      isAvailable: isAvailable,
    );
  }

  @override
  Future<void> deleteAvailability(String id) {
    return _remoteDataSource.deleteAvailability(id);
  }
}
