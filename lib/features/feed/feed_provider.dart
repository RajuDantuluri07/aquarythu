// lib/features/feed/feed_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'feed_model.dart'; // Add this import

class FeedProvider extends ChangeNotifier {
  List<FeedEntry> _entries = [];
  List<FeedEntry> get entries => _entries;

  final supabase = Supabase.instance.client;

  Future<void> loadEntries(String tankId) async {
    try {
      final response = await supabase
          .from('feed_entries')
          .select()
          .eq('tank_id', tankId)
          .order('executed_at', ascending: false);

      _entries = (response as List).map((e) => FeedEntry.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading feed entries: $e');
    }
  }

  Future<void> addFeedEntry(FeedEntry entry) async {
    try {
      final response = await supabase
          .from('feed_entries')
          .insert({
            'id': entry.id,
            'tank_id': entry.tankId,
            'executed_at': entry.executedAt?.toIso8601String(),
            'feed_quantity': entry.feedQuantity,
            'feed_type': entry.feedType,
            'mix_instructions': entry.mixInstructions,
            'tray_status': entry.trayStatus,
            'tray_score': entry.trayScore,
          })
          .select()
          .single();

      final newEntry = FeedEntry.fromJson(response);
      _entries.insert(0, newEntry);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding feed entry: $e');
    }
  }

  // Add other methods as needed
}