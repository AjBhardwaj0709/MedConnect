import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medconnect_frontend/core/network/api_exception.dart';

import 'package:medconnect_frontend/features/doctor/presentation/providers/doctor_profile_providers.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_profile_screen.dart';

class DoctorProfileConnectedScreen extends ConsumerWidget {
  const DoctorProfileConnectedScreen({super.key});

  String _errorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    // DioClient wraps Dio errors in ApiException, but handle both shapes so
    // the screen still displays a useful message if the error comes unwrapped.
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring('Exception: '.length);
      }
      return message;
    }

    return error.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(doctorProfileControllerProvider);

    return profileState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        final message = _errorMessage(error);
        final isForbidden = error is ApiException && error.statusCode == 403;

        return Scaffold(
          appBar: AppBar(title: const Text('My Profile')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isForbidden
                        ? Icons.lock_outline_rounded
                        : Icons.cloud_off_outlined,
                    size: 48,
                    color: isForbidden ? Colors.orange : Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isForbidden
                        ? 'Access to this profile is restricted'
                        : 'Could not load doctor profile',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(doctorProfileControllerProvider.notifier)
                          .refreshProfile();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      data: (profile) => DoctorProfileScreen(
        initialName: profile.name,
        initialEmail: profile.email,
        initialSpecialization: profile.specialization,
        initialQualification: profile.qualification,
        initialRegistrationNumber: profile.registrationNumber,
        initialExperience: profile.experience,
        initialConsultationFee: profile.consultationFee,
        initialAddress: profile.clinicAddress,
        verificationStatus: profile.verificationStatus,
        initialProfileImage: profile.profileImage,
        onUploadImage: (image) async {
          final updatedProfile = await ref
              .read(doctorProfileControllerProvider.notifier)
              .uploadProfileImage(image);
          return updatedProfile.profileImage;
        },
        onDeleteImage: () async {
          await ref
              .read(doctorProfileControllerProvider.notifier)
              .deleteProfileImage();
        },
        onSave: (data) async {
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
      ),
    );
  }
}
