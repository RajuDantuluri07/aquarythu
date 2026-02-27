import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ========== IMPORTS FROM SEPARATE FILES ==========
import 'core/theme/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/auth_wrapper.dart';
import 'features/farm/farm_provider.dart';
import 'features/tank/tank_provider.dart';
import 'features/feed/feed_provider.dart';
import 'features/farm/blind_feed_schedule_provider.dart';
import 'features/water/water_quality_provider.dart';
import 'features/harvest/harvest_provider.dart';

// ========== MAIN APP ==========
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Use String.fromEnvironment to get keys from build command
    // Example: flutter build apk --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://vwdzrzdvmgoqezatjhbr.supabase.co');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseAnonKey.isEmpty) {
      throw 'SUPABASE_ANON_KEY is not provided. Please pass it as a --dart-define argument.';
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (e) {
    // If initialization fails, show an error screen instead of a blank one.
    runApp(ErrorApp(error: e.toString()));
    return; // Stop execution
  }

  // Run the main app only if Supabase initializes successfully.
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => TankProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => BlindFeedScheduleProvider()),
        ChangeNotifierProvider(create: (_) => WaterQualityProvider()),
        ChangeNotifierProvider(create: (_) => HarvestProvider()),
      ],
      child: MaterialApp(
        title: 'AquaRythu',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.success,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// A simple app to display an error message on a clean screen.
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Initialization Failed:\n\n$error', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}