import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_profile_screen.dart';

import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: MedConnectApp()));
}

class MedConnectApp extends StatelessWidget {
  const MedConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF167D9A)),
        scaffoldBackgroundColor: const Color(0xFFF5F9FC),
      ),
      // home: const LoginScreen(),
      home: const DoctorProfileScreen(
        initialName: 'Rahul Sharma',
        initialEmail: 'rahul@example.com',
        initialSpecialization: 'Cardiology',
        initialQualification: 'MBBS, MD',
        initialRegistrationNumber: 'MED12345',
        initialExperience: 5,
        initialConsultationFee: 500,
        initialAddress: 'Rohtak, Haryana',
        verificationStatus: 'Pending',
      ),
    );
  }
}
