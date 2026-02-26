import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'blind_feed_schedule.dart';

class BlindFeedScheduleProvider extends ChangeNotifier {
  List<BlindFeedSchedule> _schedules = [];
  List<BlindFeedSchedule> get schedules => _schedules;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadSchedules(String tankId) async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final response = await Supabase.instance.client
          .from('blind_feed_schedule')
          .select()
          .eq('tank_id', tankId)
          .order('day_of_culture', ascending: true);
      _schedules = (response as List)
          .map((e) => BlindFeedSchedule.fromMap(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading blind feed schedules: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> generateSchedules(String tankId, {required int initialSeed, required double areaAcres}) async {
    try {
      _schedules.clear();
      final schedules = _generateBlindFeedSchedule(tankId, initialSeed, areaAcres);
      
      // Save to database
      final data = schedules.map((s) => s.toMap()).toList();
      await Supabase.instance.client.from('blind_feed_schedule').insert(data);
      
      _schedules = schedules;
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating blind feed schedules: $e');
      rethrow;
    }
  }

  Future<void> updateSchedule(BlindFeedSchedule schedule) async {
    try {
      await Supabase.instance.client
          .from('blind_feed_schedule')
          .update({
            'daily_feed_amount': schedule.dailyFeedAmount,
            'feed_type': schedule.feedType,
          })
          .eq('id', schedule.id);
      
      final index = _schedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        _schedules[index] = schedule;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating blind feed schedule: $e');
      rethrow;
    }
  }

  List<BlindFeedSchedule> _generateBlindFeedSchedule(
    String tankId,
    int initialSeed,
    double areaAcres,
  ) {
    final List<BlindFeedSchedule> schedules = [];
    const uuid = Uuid();

    // Standard blind feeding schedule (DOC 1-30)
    // Feed amounts based on stocking density and area
    final feedPerAcrePerDay = (initialSeed / 10000) * 0.05; // Approximate formula
    final totalFeedPerDay = feedPerAcrePerDay * areaAcres;

    for (int doc = 1; doc <= 30; doc++) {
      // Adjust feed based on DOC phase
      double dailyFeed = totalFeedPerDay;
      String feedType = 'Starter 1';

      if (doc <= 10) {
        dailyFeed = totalFeedPerDay * 0.5;
        feedType = 'Starter 1';
      } else if (doc <= 20) {
        dailyFeed = totalFeedPerDay * 0.75;
        feedType = 'Starter 2';
      } else {
        dailyFeed = totalFeedPerDay;
        feedType = 'Grower 1';
      }

      schedules.add(
        BlindFeedSchedule(
          id: uuid.v4(),
          tankId: tankId,
          dayOfCulture: doc,
          dailyFeedAmount: dailyFeed,
          feedType: feedType,
        ),
      );
    }

    return schedules;
  }
}
