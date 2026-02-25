import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../feed/log_feed_screen.dart';
import 'analytics_screen.dart';
import '../tank/tank_provider.dart';
import 'home_screen.dart';
import 'more_screen.dart';

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
        children: [
          const HomeScreen(),
          Consumer<TankProvider>(
            builder: (context, tankProvider, _) {
              if (tankProvider.tanks.isEmpty) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Log Feed'),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  body: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Please add a tank on the dashboard before logging feed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.gray600, fontSize: 16),
                      ),
                    ),
                  ),
                );
              }
              return LogFeedScreen(tankId: tankProvider.tanks.first.id);
            },
          ),
          const AnalyticsScreen(),
          const MoreScreen(),
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