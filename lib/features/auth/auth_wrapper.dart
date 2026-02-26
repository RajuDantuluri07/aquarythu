import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../dashboard/main_screen.dart';
import '../farm/farm_provider.dart';
import '../tank/tank_provider.dart';
import 'splash_screen.dart';
import 'login_screen.dart';

/// A widget that listens to the authentication state and displays either the
/// [LoginScreen] or the main app screen ([MainScreen]).
/// It also handles loading initial app data after a user is authenticated.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {

  @override
  Widget build(BuildContext context) {
    // Use Supabase's auth state stream to react to login/logout events in real-time.
    // This is more reliable than manual checks or timers.
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // While waiting for the first auth event, show the splash screen.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData && snapshot.data?.session != null) {
          // User is authenticated. Use a dedicated widget to load initial data only once.
          return const _DataInitializer(child: MainScreen());
        }

        // User is not authenticated, show the login screen.
        return const LoginScreen();
      },
    );
  }
}

/// A helper widget that loads essential app data once after authentication
/// and then displays its child.
class _DataInitializer extends StatefulWidget {
  final Widget child;
  const _DataInitializer({required this.child});

  @override
  State<_DataInitializer> createState() => _DataInitializerState();
}

class _DataInitializerState extends State<_DataInitializer> {
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    // Start loading data when this widget is first built.
    // We use a Future in the state to prevent re-fetching on rebuilds.
    _initFuture = _loadInitialData();
  }

  /// Loads essential data like farms and tanks.
  Future<void> _loadInitialData() async {
    // Ensure the context is mounted before using it.
    if (!mounted) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Using context.read is safe here as it's outside the build method.
      final farmProvider = context.read<FarmProvider>();
      await farmProvider.loadFarms(userId);

      if (mounted && farmProvider.currentFarm != null) {
        await context.read<TankProvider>().loadTanks(farmProvider.currentFarm!.id);
      }
    } catch (e) {
      debugPrint('Error loading initial data in AuthWrapper: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        // Once loading is done, show the main app.
        return widget.child;
      },
    );
  }
}