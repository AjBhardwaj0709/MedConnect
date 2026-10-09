import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}
