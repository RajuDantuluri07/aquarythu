import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/main_screen.dart';
import 'splash_screen.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

/// A widget that listens to the authentication state and displays either the
/// [LoginScreen] or the main app screen ([MoreScreen] for now).
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Show splash screen for 2 seconds to simulate loading/branding
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SplashScreen();

    final auth = context.watch<AuthNotifier>();

    if (auth.isAuthenticated) {
      // If the user is authenticated, show the main part of the app.
      return const MainScreen();
    } else {
      // If the user is not authenticated, show the login screen.
      return const LoginScreen();
    }
  }
}