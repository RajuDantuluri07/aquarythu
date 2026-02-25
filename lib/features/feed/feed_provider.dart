import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'feed_model.dart';

class FeedProvider extends ChangeNotifier {
  List<FeedEntry> _entries = [];
  List<FeedEntry> get entries => _entries;
  bool _isLoading = false;

  Future<void> loadEntries(String tankId) async {
    if (_isLoading) return;
    _isLoading = true;
    
    try {
      final response = await Supabase.instance.client
          .from('feed_logs')
          .select()
          .eq('tank_id', tankId)
          .eq('is_completed', true)
          .order('executed_at', ascending: false);

      _entries = (response as List).map((e) => FeedEntry.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading feed entries: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> logFeed({
    required String tankId,
    required double quantity,
    required String feedType,
    required String mixInstructions,
    required DateTime dateTime,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    
    final response = await Supabase.instance.client
        .from('feed_logs')
        .insert({
          'tank_id': tankId,
          'scheduled_at': dateTime.toIso8601String(),
          'executed_at': dateTime.toIso8601String(),
          'feed_quantity': quantity,
          'feed_type': feedType,
          'mix_instructions': mixInstructions,
          'executed_by': user?.id,
          'is_completed': true,
        })
        .select()
        .single();

    final newEntry = FeedEntry.fromJson(response);
    _entries.insert(0, newEntry);
    notifyListeners();
  }
}