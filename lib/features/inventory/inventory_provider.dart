import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'inventory_model.dart';

class InventoryProvider extends ChangeNotifier {
  List<InventoryItem> _items = [];
  List<InventoryItem> get items => _items;
  List<InventoryItem> get lowStockItems => _items.where((item) => item.isLowStock).toList();

  Future<void> loadItems(String farmId) async {
    try {
      final response = await Supabase.instance.client
          .from('inventory')
          .select()
          .eq('farm_id', farmId)
          .order('category');
      _items = (response as List).map((e) => InventoryItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    }
  }

  Future<void> addItem(String farmId, InventoryItem item) async {
    try {
      final response = await Supabase.instance.client
          .from('inventory')
          .insert({
            'id': item.id,
            'farm_id': farmId,
            'name': item.name,
            'quantity': item.quantity,
            'unit': item.unit,
            'category': item.category,
            'last_restocked': item.lastRestocked.toIso8601String(),
            'min_threshold': item.minThreshold,
          })
          .select()
          .single();
      _items.add(InventoryItem.fromJson(response));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding inventory item: $e');
      rethrow;
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      await Supabase.instance.client
          .from('inventory')
          .update({
            'quantity': item.quantity,
            'last_restocked': item.lastRestocked.toIso8601String(),
            'min_threshold': item.minThreshold,
          })
          .eq('id', item.id);
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating inventory item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await Supabase.instance.client
          .from('inventory')
          .delete()
          .eq('id', itemId);
      _items.removeWhere((i) => i.id == itemId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting inventory item: $e');
      rethrow;
    }
  }
}
