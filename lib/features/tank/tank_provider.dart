import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/date_utils.dart';
import '../farm/blind_feed_schedule.dart';
import 'tank_model.dart';

class TankProvider extends ChangeNotifier {
  List<Tank> _tanks = [];
  List<Tank> get tanks => _tanks;
  bool _isLoading = false;

  Future<void> loadTanks(String farmId) async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final response = await Supabase.instance.client
          .from('tanks')
          .select()
          .eq('farm_id', farmId);
      _tanks = (response as List).map((e) => Tank.fromJson(e)).toList();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addTank(Tank tank) async {
    try {
      // Generate UUID if not provided
      final tankId = tank.id.isNotEmpty ? tank.id : const Uuid().v4();
      final newTank = tank.id.isEmpty ? tank.copyWith(id: tankId) : tank;
      
      // Insert tank into database
      final response = await Supabase.instance.client
          .from('tanks')
          .insert({
            'id': tankId,
            'farm_id': newTank.farmId,
            'name': newTank.name,
            'size': newTank.size,
            'stocking_date': newTank.stockingDate.toIso8601String(),
            'initial_seed': newTank.initialSeed,
            'pl_size': newTank.plSize,
            'check_trays': newTank.checkTrays,
            'blind_duration': newTank.blindDuration,
            'blind_week1': newTank.blindWeek1,
            'blind_std': newTank.blindStd,
          })
          .select()
          .single();
      
      _tanks.add(Tank.fromJson(response));
      
      // Auto-generate blind feed schedules for DOC 1-30
      if (newTank.initialSeed != null && newTank.size != null) {
        await _generateAndSaveBlindSchedules(
          tankId,
          newTank.initialSeed!,
          newTank.size!,
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding tank: $e');
      rethrow;
    }
  }

  Future<void> updateTank(Tank tank) async {
    await Supabase.instance.client
        .from('tanks')
        .update({
          'name': tank.name,
          'size': tank.size,
          'stocking_date': tank.stockingDate.toIso8601String(),
          'initial_seed': tank.initialSeed,
          'pl_size': tank.plSize,
          'check_trays': tank.checkTrays,
          'blind_duration': tank.blindDuration,
          'blind_week1': tank.blindWeek1,
          'blind_std': tank.blindStd,
          'health_status': tank.healthStatus,
          'health_notes': tank.healthNotes,
          'dead_count': tank.deadCount,
        })
        .eq('id', tank.id);
    final index = _tanks.indexWhere((t) => t.id == tank.id);
    if (index != -1) {
      _tanks[index] = tank;
    }
    notifyListeners();
  }

  Future<void> deleteTank(String tankId) async {
    await Supabase.instance.client
        .from('tanks')
        .delete()
        .eq('id', tankId);
    _tanks.removeWhere((t) => t.id == tankId);
    notifyListeners();
  }

  Future<void> _generateAndSaveBlindSchedules(
    String tankId,
    int initialSeed,
    double areaAcres,
  ) async {
    try {
      final schedules = _generateBlindFeedSchedule(tankId, initialSeed, areaAcres);
      final data = schedules.map((s) => s.toMap()).toList();
      await Supabase.instance.client.from('blind_feed_schedule').insert(data);
    } catch (e) {
      debugPrint('Error generating blind feed schedules: $e');
      // Don't rethrow - allow tank to be created even if schedules fail
    }
  }

  List<BlindFeedSchedule> _generateBlindFeedSchedule(
    String tankId,
    int initialSeed,
    double areaAcres,
  ) {
    final List<BlindFeedSchedule> schedules = [];
    const uuid = Uuid();

    final feedPerAcrePerDay = (initialSeed / 10000) * 0.05;
    final totalFeedPerDay = feedPerAcrePerDay * areaAcres;

    for (int doc = 1; doc <= 30; doc++) {
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
