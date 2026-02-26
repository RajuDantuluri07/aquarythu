import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'farm_model.dart';

class FarmProvider extends ChangeNotifier {
  List<Farm> _farms = [];
  Farm? _currentFarm;
  
  List<Farm> get farms => _farms;
  Farm? get currentFarm => _currentFarm;

  Future<void> loadFarms(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('farms')
          .select()
          .eq('user_id', userId)
          .order('created_at');
      _farms = (response as List).map((e) => Farm.fromJson(e)).toList();
      if (_farms.isNotEmpty && _currentFarm == null) {
        _currentFarm = _farms.first;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading farms: $e');
      rethrow;
    }
  }

  Future<void> addFarm(String userId, String name) async {
    try {
      final response = await Supabase.instance.client
          .from('farms')
          .insert({
            'user_id': userId,
            'name': name,
          })
          .select()
          .single();
      final newFarm = Farm.fromJson(response);
      _farms.add(newFarm);
      // Set as current farm if this is the first farm
      if (_farms.length == 1) {
        _currentFarm = newFarm;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding farm: $e');
      rethrow;
    }
  }

  void selectFarm(Farm farm) {
    _currentFarm = farm;
    notifyListeners();
  }

  Future<void> updateFarm(Farm farm) async {
    final response = await Supabase.instance.client
        .from('farms')
        .update({
          'name': farm.name,
        })
        .eq('id', farm.id)
        .select()
        .single();
    final index = _farms.indexWhere((f) => f.id == farm.id);
    if (index != -1) {
      _farms[index] = Farm.fromJson(response);
    }
    notifyListeners();
  }

  Future<void> deleteFarm(String farmId) async {
    await Supabase.instance.client.from('farms').delete().eq('id', farmId);
    _farms.removeWhere((f) => f.id == farmId);
    notifyListeners();
  }
}
