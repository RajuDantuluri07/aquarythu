import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// ========== IMPORTS FROM SEPARATE FILES ==========
import 'core/theme/theme.dart';
import 'core/utils/date_utils.dart';
import 'features/farm/farm_model.dart';
import 'features/tank/tank_model.dart';
import 'features/feed/feed_model.dart';
import 'features/water/water_quality_model.dart';
import 'features/harvest/harvest_model.dart';
import 'features/auth/auth_provider.dart';
import 'features/farm/farm_provider.dart';
import 'features/tank/tank_provider.dart';
import 'features/feed/feed_provider.dart';
import 'features/water/water_quality_provider.dart';
import 'features/harvest/harvest_provider.dart';
import 'core/widgets/stat_card.dart';
import 'features/tank/tank_card.dart';
import 'features/feed/feed_entry_card.dart';
import 'features/water/water_quality_entry_card.dart';
import 'core/widgets/section_header.dart';
import 'features/dashboard/home_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/analytics_screen.dart';
import 'features/feed/log_feed_screen.dart';
import 'features/water/log_water_quality_screen.dart';
import 'features/tank/tank_detail_screen.dart';
import 'features/dashboard/more_screen.dart';

// ========== SCREENS ==========

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _pageIndex = index),
        children: const [
          HomeScreen(),
          LogFeedScreen(),
          AnalyticsScreen(),
          MoreScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _pageIndex,
        onTap: (index) => _pageController.jumpToPage(index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray600,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Log Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_outlined), activeIcon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

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
        home: Consumer<AuthNotifier>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const MainScreen();
            }
            return LoginScreen();
          },
        ),
      ),
    );
  }
}