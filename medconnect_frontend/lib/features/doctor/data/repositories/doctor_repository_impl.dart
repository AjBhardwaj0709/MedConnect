

import 'package:medconnect_frontend/features/doctor/data/datasources/doctor_remote_datasource.dart';
import 'package:medconnect_frontend/features/doctor/data/models/doctor_model.dart';
import 'package:medconnect_frontend/features/doctor/domain/repositories/doctor_repository.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  DoctorProfileRepositoryImpl(this._remoteDataSource);

  final DoctorProfileRemoteDataSource _remoteDataSource;

  @override
  Future<DoctorProfileModel> getMyProfile() {
    return _remoteDataSource.getMyProfile();
  }

  @override
  Future<DoctorProfileModel> updateProfile(Map<String, dynamic> data) {
    return _remoteDataSource.updateProfile(data);
  }
}
