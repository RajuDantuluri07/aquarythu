import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/date_utils.dart';
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
    final response = await Supabase.instance.client
        .from('tanks')
        .insert({
          'farm_id': tank.farmId,
          'name': tank.name,
          'size': tank.size,
          'stocking_date': AppDateUtils.getFormattedDate(tank.stockingDate),
          'initial_seed': tank.initialSeed,
          'pl_size': tank.plSize,
          'check_trays': tank.checkTrays,
          'blind_duration': tank.blindDuration,
          'blind_week1': tank.blindWeek1,
          'blind_std': tank.blindStd,
        })
        .select()
        .single();
    _tanks.add(Tank.fromJson(response));
    notifyListeners();
  }

  Future<void> updateTank(Tank tank) async {
    await Supabase.instance.client
        .from('tanks')
        .update({
          'name': tank.name,
          'size': tank.size,
          'stocking_date': AppDateUtils.getFormattedDate(tank.stockingDate),
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
}
