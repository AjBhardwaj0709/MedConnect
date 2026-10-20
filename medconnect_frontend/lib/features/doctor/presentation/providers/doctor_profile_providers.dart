import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medconnect_frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:medconnect_frontend/features/doctor/data/datasources/doctor_remote_datasource.dart';
import 'package:medconnect_frontend/features/doctor/data/models/doctor_model.dart';
import 'package:medconnect_frontend/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:medconnect_frontend/features/doctor/domain/repositories/doctor_repository.dart';

import '../controllers/doctor_profile_controller.dart';

final doctorProfileRemoteDataSourceProvider =
    Provider<DoctorProfileRemoteDataSource>((ref) {
      return DoctorProfileRemoteDataSource(ref.watch(dioClientProvider));
    });

final doctorProfileRepositoryProvider = Provider<DoctorProfileRepository>((
  ref,
) {
  return DoctorProfileRepositoryImpl(
    ref.watch(doctorProfileRemoteDataSourceProvider),
  );
});

// Intentionally not autoDispose: the profile request/result stays cached while
// navigating within the app instead of being re-created whenever the screen
// briefly loses its listener.
final doctorProfileControllerProvider =
    AsyncNotifierProvider<DoctorProfileController, DoctorProfileModel>(
      DoctorProfileController.new,
    );
