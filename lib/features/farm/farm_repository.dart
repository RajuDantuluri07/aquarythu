import 'package:supabase_flutter/supabase_flutter.dart';

import '../dashboard/farm.dart';
import '../dashboard/pond.dart';
import 'blind_feed_schedule.dart';
import 'feed_round.dart';
import '../feeding/models/tray_log.dart';

class FarmRepository {
  final SupabaseClient _client;

  FarmRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<void> createFarm(Farm farm) async {
    await _client.from('farms').insert(farm.toMap());
  }

  Future<void> createPonds(List<Pond> ponds) async {
    if (ponds.isEmpty) return;
    final data = ponds.map((pond) => pond.toMap()).toList();
    await _client.from('ponds').insert(data);
  }

  Future<void> createBlindFeedSchedules(List<BlindFeedSchedule> schedules) async {
    if (schedules.isEmpty) return;
    final data = schedules.map((s) => s.toMap()).toList();
    await _client.from('blind_feed_schedule').insert(data);
  }

  Future<List<BlindFeedSchedule>> getBlindFeedSchedule(String pondId) async {
    final response = await _client
        .from('blind_feed_schedule')
        .select()
        .eq('pond_id', pondId)
        .order('day_of_culture', ascending: true);

    return (response as List).map((data) => BlindFeedSchedule.fromMap(data)).toList();
  }

  Future<void> createTrayLogs(List<TrayLog> logs) async {
    if (logs.isEmpty) return;
    final data = logs.map((log) => log.toMap()).toList();
    await _client.from('tray_logs').insert(data);
  }

  Future<List<({FeedRound round, Pond pond})>> getPendingFeedRounds() async {
    final response = await _client
        .from('feed_rounds')
        .select('*, ponds(*)')
        .eq('is_completed', false)
        .order('scheduled_at');

    return (response as List).map((data) {
      final round = FeedRound.fromMap(data);
      final pondData = data['ponds'] as Map<String, dynamic>;
      final pond = Pond.fromMap(pondData);
      return (round: round, pond: pond);
    }).toList();
  }
}