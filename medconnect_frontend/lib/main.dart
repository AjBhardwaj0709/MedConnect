import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_appointments_screen.dart';


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
      home: const DoctorAppointmentsScreen(
        appointments: [
          {
            '_id': 'demo-appointment-1',
            'patientName': 'Amit Sharma',
            'status': 'Pending',
            'date': '2026-10-12',
            'time': '10:30 AM',
            'reason': 'General consultation',
          },
          {
            '_id': 'demo-appointment-2',
            'patientName': 'Priya Verma',
            'status': 'Confirmed',
            'date': '2026-10-12',
            'time': '11:00 AM',
            'reason': 'Follow-up consultation',
          },
          {
            '_id': 'demo-appointment-3',
            'patientName': 'Rahul Kumar',
            'status': 'Completed',
            'date': '2026-10-10',
            'time': '02:00 PM',
            'reason': 'Regular check-up',
          },
        ],
      ),
    );
  }
}
