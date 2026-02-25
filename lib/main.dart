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
import 'features/water/water_quality_provider.dart';
import 'features/harvest/harvest_provider.dart';

// ========== MAIN APP ==========
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://vwdzrzdvmgoqezatjhbr.supabase.co',
      anonKey: 'sb_publishable_z_5942T3HoGRt-eXcVcU5w_Isd3pDVz',
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const MyApp());
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
        ChangeNotifierProvider(create: (_) => WaterQualityProvider()),
        ChangeNotifierProvider(create: (_) => HarvestProvider()),
      ],
      child: MaterialApp(
        title: 'AquaRythu',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.light(
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