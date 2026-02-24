import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/date_utils.dart';
import 'feed_model.dart';

class FeedProvider extends ChangeNotifier {
  List<FeedEntry> _entries = [];
  List<FeedEntry> get entries => _entries;

  double get totalFeed => _entries.fold(0, (sum, e) => sum + e.amount);
  
  double get todayFeed {
    final today = AppDateUtils.getFormattedDate();
    return _entries
        .where((e) => AppDateUtils.getFormattedDate(e.date) == today)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getFeedWastePercentage() {
    final validChecks = _entries.where((e) => 
        ['empty', 'little', 'half', 'too-much'].contains(e.trayResult)).toList();
    if (validChecks.isEmpty) return 0;
    final wasteChecks = validChecks.where((e) => 
        ['half', 'too-much'].contains(e.trayResult)).length;
    return (wasteChecks / validChecks.length) * 100;
  }

  int getPendingChecksCount() {
    return _entries.where((e) => e.trayResult == 'pending').length;
  }

  Future<void> loadEntries(String tankId) async {
    final response = await Supabase.instance.client
        .from('feed_entries')
        .select()
        .eq('tank_id', tankId)
        .order('date', ascending: false);
    _entries = (response as List).map((e) => FeedEntry.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addEntry(FeedEntry entry) async {
    final response = await Supabase.instance.client
        .from('feed_entries')
        .insert({
          'tank_id': entry.tankId,
          'date': AppDateUtils.getFormattedDate(entry.date),
          'amount': entry.amount,
          'time': entry.time,
          'tray_result': entry.trayResult,
          'supplements': entry.supplements,
          'reason': entry.reason,
          'health_observed': entry.healthObserved,
          'mortality': entry.mortality,
          'disease': entry.disease,
        })
        .select()
        .single();
    _entries.insert(0, FeedEntry.fromJson(response));
    notifyListeners();
  }

  Future<void> updateEntry(FeedEntry entry) async {
    await Supabase.instance.client
        .from('feed_entries')
        .update({
          'amount': entry.amount,
          'tray_result': entry.trayResult,
          'supplements': entry.supplements,
          'reason': entry.reason,
        })
        .eq('id', entry.id);
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
    }
    notifyListeners();
  }

  Future<void> deleteEntry(String entryId) async {
    await Supabase.instance.client
        .from('feed_entries')
        .delete()
        .eq('id', entryId);
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();
  }
}
