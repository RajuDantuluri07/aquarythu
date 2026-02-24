import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/date_utils.dart';
import 'harvest_model.dart';

class HarvestProvider extends ChangeNotifier {
  List<HarvestEntry> _entries = [];
  List<HarvestEntry> get entries => _entries;
  
  double get totalHarvest => _entries.fold(0, (sum, e) => sum + e.weight);

  Future<void> loadHarvests(String tankId) async {
    final response = await Supabase.instance.client
        .from('harvest_entries')
        .select()
        .eq('tank_id', tankId);
    _entries = (response as List).map((e) => HarvestEntry.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addHarvest(HarvestEntry entry) async {
    final response = await Supabase.instance.client
        .from('harvest_entries')
        .insert({
          'tank_id': entry.tankId,
          'date': AppDateUtils.getFormattedDate(entry.date),
          'weight': entry.weight,
          'count': entry.count,
          'price': entry.price,
        })
        .select()
        .single();
    _entries.add(HarvestEntry.fromJson(response));
    notifyListeners();
  }
}
