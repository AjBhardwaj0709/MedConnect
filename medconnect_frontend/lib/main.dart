import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_appointments_screen.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_patient_details_screen.dart';

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
      home: const DoctorPatientDetailsScreen(
        patientId: 'PAT-1001',
        patientName: 'Amit Sharma',
        email: 'amit@example.com',

        age: 32,
        gender: 'Male',
        bloodGroup: 'O+',
        address: 'Rohtak, Haryana',
        appointments: [
          {
            'date': '2026-10-10',
            'status': 'Completed',
            'reason': 'General consultation',
          },
          {'date': '2026-10-15', 'status': 'Confirmed', 'reason': 'Follow-up'},
        ],
      ),
    );
  }
}
