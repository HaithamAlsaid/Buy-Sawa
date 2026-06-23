import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';

class AuthBottomSheet extends StatelessWidget {
  const AuthBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is no longer used — navigation goes directly to LoginScreen
    return const SizedBox.shrink();
  }
}

