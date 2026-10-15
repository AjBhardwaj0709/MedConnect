// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:medconnect_frontend/app/app.dart';

// void main() {
//   runApp(const ProviderScope(child: MedConnectApp()));
// }


import 'package:flutter/material.dart';

import 'features/doctor/presentation/screens/doctor_notifications_screen.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DoctorNotificationsScreen(
        notifications: [
          {
            'id': 'NOT-001',
            'title': 'New Appointment',
            'message': 'Amit Sharma has requested an appointment.',
            'type': 'appointment',
            'time': '10 minutes ago',
            'isRead': false,
          },
          {
            'id': 'NOT-002',
            'title': 'Prescription Reminder',
            'message': 'Please review the patient prescription.',
            'type': 'prescription',
            'time': '1 hour ago',
            'isRead': false,
          },
          {
            'id': 'NOT-003',
            'title': 'Account Update',
            'message': 'Your doctor profile is awaiting verification.',
            'type': 'system',
            'time': 'Yesterday',
            'isRead': true,
          },
        ],
      ),
    ),
  );
}
