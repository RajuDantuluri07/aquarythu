import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../dashboard/farm.dart';
import '../dashboard/pond.dart';
import 'blind_feed_schedule.dart';
import 'farm_repository.dart';

class FarmSetupNotifier extends ChangeNotifier {
  String _farmName = '';
  String get farmName => _farmName;

  final List<Pond> _ponds = [];
  List<Pond> get ponds => List.unmodifiable(_ponds);

  final _uuid = const Uuid();
  final FarmRepository _repository;

  FarmSetupNotifier({FarmRepository? repository})
      : _repository = repository ?? FarmRepository() {
    // Start with one empty pond form
    addPond();
  }

  void updateFarmName(String name) {
    _farmName = name;
    notifyListeners();
  }

  void addPond() {
    _ponds.add(
      Pond(
        id: _uuid.v4(), // Temporary client-side ID
        farmId: '', // Will be assigned on save
        name: '',
        acreSize: 0.0,
        stockingCount: 0,
        plPerM2: 0,
        stockingDate: DateTime.now(),
        numberOfTrays: 0,
        aerationHp: 0.0,
        waterSource: '',
      ),
    );
    notifyListeners();
  }

  void updatePond(int index, Pond pond) {
    if (index >= 0 && index < _ponds.length) {
      _ponds[index] = pond;
      notifyListeners();
    }
  }

  void removePond(int index) {
    if (index >= 0 && index < _ponds.length) {
      _ponds.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> saveFarm(String userId) async {
    if (_farmName.trim().isEmpty) {
      throw Exception('Farm name cannot be empty');
    }

    if (_ponds.isEmpty) {
      throw Exception('At least one pond is required');
    }

    for (var i = 0; i < _ponds.length; i++) {
      final pond = _ponds[i];
      if (pond.name.trim().isEmpty) {
        throw Exception('Pond ${i + 1} name cannot be empty');
      }
      if (pond.acreSize <= 0) {
        throw Exception('Pond ${i + 1} acre size must be greater than 0');
      }
    }

    final farmId = _uuid.v4();

    final farm = Farm(
      id: farmId,
      userId: userId,
      name: _farmName,
    );

    // Assign the generated farmId to all ponds
    final pondsToSave = _ponds.map((pond) {
      return pond.copyWith(farmId: farmId);
    }).toList();

    // Generate Blind Feed Schedules for DOC 1-30
    final List<BlindFeedSchedule> allSchedules = [];
    for (final pond in pondsToSave) {
      allSchedules.addAll(_generateBlindFeedSchedule(pond));
    }

    try {
      await _repository.createFarm(farm);
      await _repository.createPonds(pondsToSave);
      await _repository.createBlindFeedSchedules(allSchedules);
    } catch (e) {
      debugPrint('Error saving farm: $e');
      rethrow;
    }
  }

  List<BlindFeedSchedule> _generateBlindFeedSchedule(Pond pond) {
    final List<BlindFeedSchedule> schedules = [];
    // Logic based on PRD Module 2:
    // "System auto-generates: Blind feeding schedule (DOC 1–30) Based on: Stocking count, Acre size, Standard feed table"
    //
    // Simplified Standard Feed Table Logic (for MVP):
    // Base assumption: 100,000 PL requires ~2.0kg start, increasing daily.
    // Formula: (Stocking Count / 100,000) * (Base + (DOC * Increment))

    final double stockingRatio = pond.stockingCount / 100000.0;

    for (int doc = 1; doc <= 30; doc++) {
      // Example progression:
      // DOC 1: 2.0 kg/100k -> DOC 30: ~13.6 kg/100k
      double baseFeedPer100k = 2.0 + ((doc - 1) * 0.4);
      double dailyAmount = baseFeedPer100k * stockingRatio;

      // Feed Type Logic (Example)
      String feedType = doc <= 15 ? 'Starter 1' : 'Starter 2';

      schedules.add(BlindFeedSchedule(
        id: _uuid.v4(),
        pondId: pond.id,
        dayOfCulture: doc,
        dailyFeedAmount: double.parse(dailyAmount.toStringAsFixed(2)),
        feedType: feedType,
      ));
    }
    return schedules;
  }
}