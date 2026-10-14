import 'package:flutter/material.dart';


import 'router.dart';


class MedConnectApp extends StatelessWidget {
  const MedConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MedConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF167D9A)),
        scaffoldBackgroundColor: const Color(0xFFF5F9FC),
      ),
      routerConfig: appRouter,
    );
  }
}
