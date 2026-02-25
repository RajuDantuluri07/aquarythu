import 'package:supabase_flutter/supabase_flutter.dart';

import '../dashboard/farm.dart';
import '../tank/tank_model.dart';
import 'blind_feed_schedule.dart';
import 'feed_round.dart'; // Contains FeedLog class now
import 'package:aquarythu/features/feeding/models/tray_log.dart';

class FarmRepository {
  final SupabaseClient _client;

  FarmRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<void> createFarm(Farm farm) async {
    await _client.from('farms').insert(farm.toMap());
  }

  Future<void> createTanks(List<Tank> tanks) async {
    if (tanks.isEmpty) return;
    final data = tanks.map((tank) => tank.toMap()).toList();
    await _client.from('tanks').insert(data);
  }

  Future<void> createBlindFeedSchedules(List<BlindFeedSchedule> schedules) async {
    if (schedules.isEmpty) return;
    final data = schedules.map((s) => s.toMap()).toList();
    await _client.from('blind_feed_schedule').insert(data);
  }

  Future<List<BlindFeedSchedule>> getBlindFeedSchedule(String tankId) async {
    final response = await _client
        .from('blind_feed_schedule')
        .select()
        .eq('tank_id', tankId)
        .order('day_of_culture', ascending: true);

    return (response as List).map((data) => BlindFeedSchedule.fromMap(data)).toList();
  }

  Future<void> createTrayChecks(List<TrayLog> logs) async {
    if (logs.isEmpty) return;
    final data = logs.map((log) => log.toMap()).toList();
    await _client.from('tray_checks').insert(data);
  }

  Future<List<({FeedLog round, Tank tank})>> getPendingFeedLogs() async {
    final response = await _client
        .from('feed_logs')
        .select('*, tanks(*)')
        .eq('is_completed', false)
        .order('scheduled_at');

    return (response as List).map((data) {
      final round = FeedLog.fromMap(data);
      final tankData = data['tanks'] as Map<String, dynamic>;
      final tank = Tank.fromJson(tankData);
      return (round: round, tank: tank);
    }).toList();
  }
}