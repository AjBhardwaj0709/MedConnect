import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:medconnect_frontend/features/doctor/presentation/providers/doctor_profile_providers.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_profile_screen.dart';

class DoctorProfileConnectedScreen extends ConsumerWidget {
  const DoctorProfileConnectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('PROFILE CONNECTED SCREEN: build called');

    final profileState = ref.watch(doctorProfileControllerProvider);

    return profileState.when(
      loading: () {
        debugPrint('PROFILE STATE: loading');

        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stackTrace) {
        debugPrint('PROFILE STATE ERROR: $error');
        debugPrintStack(stackTrace: stackTrace);

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Could not load doctor profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(doctorProfileControllerProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      data: (profile) {
        debugPrint('PROFILE STATE: data received');
        debugPrint('PROFILE NAME: ${profile.name}');
        debugPrint('PROFILE EMAIL: ${profile.email}');

        return DoctorProfileScreen(
          initialName: profile.name,
          initialEmail: profile.email,
          initialSpecialization: profile.specialization,
          initialQualification: profile.qualification,
          initialRegistrationNumber: profile.registrationNumber,
          initialExperience: profile.experience,
          initialConsultationFee: profile.consultationFee,
          initialAddress: profile.clinicAddress,
          verificationStatus: profile.verificationStatus,
          onUploadImage: (image) async {
            final updatedProfile = await ref
                .read(doctorProfileControllerProvider.notifier)
                .uploadProfileImage(image);

            debugPrint(
              'UPDATED PROFILE IMAGE URL: ${updatedProfile.profileImage}',
            );

            return updatedProfile.profileImage;
          },

          onDeleteImage: () async {
            await ref
                .read(doctorProfileControllerProvider.notifier)
                .deleteProfileImage();
          },

          onSave: (data) async {
            debugPrint('PROFILE UPDATE: save button called');
            debugPrint('PROFILE UPDATE DATA: $data');

            await ref
                .read(doctorProfileControllerProvider.notifier)
                .updateProfile({
                  'name': data['name'],
                  'specialization': data['specialization'],
                  'qualification': data['qualification'],
                  'experience': data['experience'],
                  'consultationFee': data['consultationFee'],
                  'clinicAddress': data['address'],
                });
          },
        );
      },
    );
  }
}
