import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../feed/feed_model.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _totalFeedConsumed = 0;
  double get totalFeedConsumed => _totalFeedConsumed;

  double _averageFCR = 0;
  double get averageFCR => _averageFCR;

  double _feedToday = 0;
  double get feedToday => _feedToday;

  Future<void> fetchDashboardMetrics(String farmId) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: Get all tank IDs for the given farm
      final tanksResponse = await Supabase.instance.client
          .from('tanks')
          .select('id')
          .eq('farm_id', farmId);

      final tankIds = (tanksResponse as List).map<String>((tank) => tank['id'] as String).toList();

      if (tankIds.isEmpty) {
        _resetMetrics();
        return;
      }

      // Step 2: Get all feed logs for those tanks
      final feedLogsResponse = await Supabase.instance.client
          .from('feed_logs')
          .select()
          .in_('tank_id', tankIds);
      
      final allFeedLogs = (feedLogsResponse as List).map((e) => FeedEntry.fromJson(e)).toList();

      // Step 3: Calculate Metrics
      _calculateMetrics(allFeedLogs);

    } catch (e) {
      debugPrint('Error fetching dashboard metrics: $e');
      _resetMetrics();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateMetrics(List<FeedEntry> logs) {
    if (logs.isEmpty) {
      _resetMetrics();
      return;
    }

    // Calculate Total Feed Consumed
    _totalFeedConsumed = logs.fold(0, (sum, entry) => sum + (entry.feedQuantity ?? 0));

    // Calculate Feed Today
    final today = DateUtils.dateOnly(DateTime.now());
    _feedToday = logs
        .where((entry) =>
            entry.executedAt != null &&
            DateUtils.isSameDay(entry.executedAt, today))
        .fold(0, (sum, entry) => sum + (entry.feedQuantity ?? 0));

    // Calculate Average FCR (Feed Conversion Ratio)
    // NOTE: This is a placeholder calculation. A real FCR calculation
    // requires harvest data (Total Biomass Gained / Total Feed).
    // For now, we'll simulate a simple ratio.
    // This will be improved when harvest feature is integrated.
    if (_totalFeedConsumed > 0) {
      // This is a dummy calculation.
      _averageFCR = 1.5; 
    } else {
      _averageFCR = 0;
    }
    
    notifyListeners();
  }

  void _resetMetrics() {
    _totalFeedConsumed = 0;
    _averageFCR = 0;
    _feedToday = 0;
    notifyListeners();
  }
}
