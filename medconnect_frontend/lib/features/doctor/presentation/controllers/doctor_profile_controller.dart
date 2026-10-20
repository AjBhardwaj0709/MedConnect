

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medconnect_frontend/features/doctor/data/models/doctor_model.dart';
import 'package:medconnect_frontend/features/doctor/presentation/providers/doctor_profile_providers.dart';


class DoctorProfileController extends AsyncNotifier<DoctorProfileModel> {
  @override
  Future<DoctorProfileModel> build() {
    return ref.read(doctorProfileRepositoryProvider).getMyProfile();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final previousProfile = state.value;

    state = const AsyncLoading();

    try {
      final updatedProfile = await ref
          .read(doctorProfileRepositoryProvider)
          .updateProfile(data);

      state = AsyncData(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      // Keep the previous profile available to the screen if saving fails.
      if (previousProfile != null) {
        state = AsyncData(previousProfile);
      }

      rethrow;
    }
  }
  Future<DoctorProfileModel> uploadProfileImage(XFile image) async {
    final previousProfile = state.value;

    try {
      final updatedProfile = await ref
          .read(doctorProfileRepositoryProvider)
          .uploadProfileImage(image);

      state = AsyncData(updatedProfile);
        return updatedProfile;
    } catch (error, stackTrace) {
      if (previousProfile != null) {
        state = AsyncData(previousProfile);
      } else {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<void> deleteProfileImage() async {
    final previousProfile = state.value;

    try {
      final updatedProfile = await ref
          .read(doctorProfileRepositoryProvider)
          .deleteProfileImage();

      state = AsyncData(updatedProfile);
    } catch (error, stackTrace) {
      if (previousProfile != null) {
        state = AsyncData(previousProfile);
      } else {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<void> refreshProfile() async {
    state = const AsyncLoading();

    try {
      final profile = await ref
          .read(doctorProfileRepositoryProvider)
          .getMyProfile();

      state = AsyncData(profile);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
