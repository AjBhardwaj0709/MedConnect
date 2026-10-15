import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medconnect_frontend/features/doctor/presentation/screens/doctor_notifications_screen.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';

import '../features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import '../features/doctor/presentation/screens/doctor_profile_screen.dart';
import '../features/doctor/presentation/screens/doctor_availability_screen.dart';
import '../features/doctor/presentation/screens/doctor_appointments_screen.dart';
import '../features/doctor/presentation/screens/doctor_prescriptions_screen.dart';
import '../features/doctor/presentation/screens/doctor_medical_reports_screen.dart';
import '../features/doctor/presentation/screens/doctor_chat_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    // =========================
    // AUTHENTICATION ROUTES
    // =========================

    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),

    // =========================
    // DOCTOR ROUTES
    // =========================
    GoRoute(
      path: '/doctor/dashboard',
      name: 'doctorDashboard',
      builder: (context, state) => const DoctorDashboardScreen(),
    ),

    GoRoute(
      path: '/doctor/profile',
      name: 'doctorProfile',
      builder: (context, state) => const DoctorProfileScreen(),
    ),

    GoRoute(
      path: '/doctor/availability',
      name: 'doctorAvailability',
      builder: (context, state) => const DoctorAvailabilityScreen(),
    ),

    GoRoute(
      path: '/doctor/appointments',
      name: 'doctorAppointments',
      builder: (context, state) => const DoctorAppointmentsScreen(),
    ),
GoRoute(
      path: '/doctor/notifications',
      builder: (context, state) => const DoctorNotificationsScreen(),
    ),
    GoRoute(
      path: '/doctor/prescriptions',
      name: 'doctorPrescriptions',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is Map<String, dynamic>) {
          return DoctorPrescriptionsScreen(
            patientId: extra['patientId']?.toString() ?? '',
            patientName: extra['patientName']?.toString() ?? '',
          );
        }

        return const DoctorPrescriptionsScreen();
      },
    ),

    GoRoute(
      path: '/doctor/medical-reports',
      name: 'doctorMedicalReports',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is Map<String, dynamic>) {
          return DoctorMedicalReportsScreen(
            patientId: extra['patientId']?.toString() ?? '',
            patientName: extra['patientName']?.toString() ?? '',
          );
        }

        return const DoctorMedicalReportsScreen();
      },
    ),

    GoRoute(
      path: '/doctor/chat',
      name: 'doctorChat',
      builder: (context, state) => const DoctorChatScreen(),
    ),
  ],

  // =========================
  // ERROR PAGE
  // =========================
  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text('The requested page could not be found.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  },
);
