import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';

final authControllerProvider = NotifierProvider<AuthController, bool>(
  AuthController.new,
);
