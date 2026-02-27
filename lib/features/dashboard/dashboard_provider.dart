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
          .inFilter('tank_id', tankIds);
      
      final allFeedLogs = (feedLogsResponse as List).map((e) => FeedEntry.fromJson(e)).toList();

      // Step 3: Get harvest entries for FCR calculation
      final harvestResponse = await Supabase.instance.client
          .from('harvest_entries')
          .select('weight_kg')
          .inFilter('tank_id', tankIds);

      final totalHarvestWeight = (harvestResponse as List).fold<double>(0, (sum, item) => sum + ((item['weight_kg'] as num?)?.toDouble() ?? 0));

      // Step 4: Calculate Metrics
      _calculateMetrics(allFeedLogs, totalHarvestWeight);

    } catch (e) {
      debugPrint('Error fetching dashboard metrics: $e');
      _resetMetrics();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateMetrics(List<FeedEntry> logs, double totalHarvestWeight) {
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
    // Formula: Total Feed / Total Harvest Weight
    if (totalHarvestWeight > 0) {
      _averageFCR = _totalFeedConsumed / totalHarvestWeight;
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
