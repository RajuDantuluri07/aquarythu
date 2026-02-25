import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/main_screen.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

/// A widget that listens to the authentication state and displays either the
/// [LoginScreen] or the main app screen ([MoreScreen] for now).
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
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