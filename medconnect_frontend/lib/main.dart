import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_appointments_screen.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_chat_screen.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_medical_reports_screen.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_patient_details_screen.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_prescriptions_screen.dart';

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
      home: DoctorChatScreen(
        doctorName: 'Dr. Sharma',
        conversations: [
          {
            'id': 'CONV-001',
            'patientId': 'PAT-1001',
            'patientName': 'Amit Sharma',
            'lastMessage': 'Thank you, doctor.',
            'time': '10:30 AM',
            'unreadCount': 2,
          },
          {
            'id': 'CONV-002',
            'patientId': 'PAT-1002',
            'patientName': 'Priya Verma',
            'lastMessage': 'When should I come for follow-up?',
            'time': 'Yesterday',
            'unreadCount': 0,
          },
        ],
        initialMessages: [
          {
            'conversationId': 'CONV-001',
            'senderId': 'patient',
            'text': 'Hello doctor.',
            'time': '10:28 AM',
          },
          {
            'conversationId': 'CONV-001',
            'senderId': 'doctor',
            'text': 'Hello! How can I help you?',
            'time': '10:29 AM',
          },
        ],
      ),
    );
  }
}
