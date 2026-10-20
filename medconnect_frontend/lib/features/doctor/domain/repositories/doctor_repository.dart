

import 'package:medconnect_frontend/features/doctor/data/models/doctor_model.dart';

abstract class DoctorProfileRepository {
  Future<DoctorProfileModel> getMyProfile();

  Future<DoctorProfileModel> updateProfile(Map<String, dynamic> data);
}
