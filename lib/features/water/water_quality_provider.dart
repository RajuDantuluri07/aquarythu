import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/date_utils.dart';
import 'water_quality_model.dart';

class WaterQualityProvider extends ChangeNotifier {
  List<WaterQualityEntry> _entries = [];
  List<WaterQualityEntry> get entries => _entries;

  Future<void> loadEntries(String tankId) async {
    final response = await Supabase.instance.client
        .from('water_quality_entries')
        .select()
        .eq('tank_id', tankId)
        .order('date', ascending: false);
    _entries = (response as List).map((e) => WaterQualityEntry.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addEntry(WaterQualityEntry entry) async {
    final response = await Supabase.instance.client
        .from('water_quality_entries')
        .insert({
          'tank_id': entry.tankId,
          'date': AppDateUtils.getFormattedDate(entry.date),
          'ph': entry.ph,
          'ammonia': entry.ammonia,
          'nitrite': entry.nitrite,
          'salinity': entry.salinity,
          'temperature': entry.temperature,
          'dissolved_oxygen': entry.dissolvedOxygen,
          'notes': entry.notes,
        })
        .select()
        .single();
    _entries.insert(0, WaterQualityEntry.fromJson(response));
    notifyListeners();
  }
}