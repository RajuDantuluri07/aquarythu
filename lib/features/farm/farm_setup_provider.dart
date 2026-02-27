import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../dashboard/farm.dart';
import '../tank/tank_model.dart';
import 'blind_feed_schedule.dart'; // Assumes this model is updated or compatible
import 'farm_repository.dart';

class FarmSetupNotifier extends ChangeNotifier {
  String _farmName = '';
  String get farmName => _farmName;

  final List<Tank> _tanks = [];
  List<Tank> get tanks => List.unmodifiable(_tanks);

  final _uuid = const Uuid();
  final FarmRepository _repository;

  FarmSetupNotifier({FarmRepository? repository})
      : _repository = repository ?? FarmRepository() {
    // Start with one empty tank form
    addTank();
  }

  void updateFarmName(String name) {
    _farmName = name;
    notifyListeners();
  }

  void addTank() {
    _tanks.add(
      Tank(
        id: _uuid.v4(), // Temporary client-side ID
        farmId: '', // Will be assigned on save
        name: '',
        stockingDate: DateTime.now(),
        size: 0.0,
        initialSeed: 0,
        plSize: null,
      ),
    );
    notifyListeners();
  }

  void updateTank(int index, Tank tank) {
    if (index >= 0 && index < _tanks.length) {
      _tanks[index] = tank;
      notifyListeners();
    }
  }

  void removeTank(int index) {
    if (index >= 0 && index < _tanks.length) {
      _tanks.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> saveFarm(String userId) async {
    if (_farmName.trim().isEmpty) {
      throw Exception('Farm name cannot be empty');
    }

    if (_tanks.isEmpty) {
      throw Exception('At least one tank is required');
    }

    for (var i = 0; i < _tanks.length; i++) {
      final tank = _tanks[i];
      if (tank.name.trim().isEmpty) {
        throw Exception('Tank ${i + 1} name cannot be empty');
      }
      if ((tank.size ?? 0) <= 0) {
        throw Exception('Tank ${i + 1} area must be greater than 0');
      }
    }

    final farmId = _uuid.v4();

    final farm = Farm(
      id: farmId,
      userId: userId,
      name: _farmName,
    );

    // Assign the generated farmId to all tanks
    final tanksToSave = _tanks.map((tank) {
      // Manually creating a new Tank as copyWith is not guaranteed on the model
      return Tank(
        id: tank.id,
        farmId: farmId,
        name: tank.name,
        size: tank.size,
        stockingDate: tank.stockingDate,
        initialSeed: tank.initialSeed,
        plSize: tank.plSize,
        checkTrays: tank.checkTrays,
        biomass: tank.biomass,
        blindDuration: tank.blindDuration,
        blindWeek1: tank.blindWeek1,
        blindStd: tank.blindStd,
        blindSchedule: tank.blindSchedule,
        hasTransitionedFromBlind: tank.hasTransitionedFromBlind,
        status: tank.status,
        healthStatus: tank.healthStatus,
        healthNotes: tank.healthNotes,
        deadCount: tank.deadCount,
      );
    }).toList();

    // Generate Blind Feed Schedules for DOC 1-30
    final List<BlindFeedSchedule> allSchedules = [];
    for (final tank in tanksToSave) {
      allSchedules.addAll(_generateBlindFeedSchedule(tank));
    }

    try {
      await _repository.createFarm(farm);
      await _repository.createTanks(tanksToSave);
      await _repository.createBlindFeedSchedules(allSchedules);
    } catch (e) {
      debugPrint('Error saving farm: $e');
      rethrow;
    }
  }

  List<BlindFeedSchedule> _generateBlindFeedSchedule(Tank tank) {
    final List<BlindFeedSchedule> schedules = [];
    // Logic based on PRD Module 2:
    // "System auto-generates: Blind feeding schedule (DOC 1–30) Based on: Stocking count, Acre size, Standard feed table"
    //
    // Simplified Standard Feed Table Logic (for MVP):
    // Base assumption: 100,000 PL requires ~2.0kg start, increasing daily.
    // Formula: (Stocking Count / 100,000) * (Base + (DOC * Increment))

    final double stockingRatio = (tank.initialSeed ?? 0) / 100000.0;

    for (int doc = 1; doc <= 30; doc++) {
      // Example progression:
      // DOC 1: 2.0 kg/100k -> DOC 30: ~13.6 kg/100k
      double baseFeedPer100k = 2.0 + ((doc - 1) * 0.4);
      double dailyAmount = baseFeedPer100k * stockingRatio;

      // Feed Type Logic (Example)
      String feedType = doc <= 15 ? 'Starter 1' : 'Starter 2';

      schedules.add(BlindFeedSchedule(
        id: _uuid.v4(),
        tankId: tank.id,
        dayOfCulture: doc,
        dailyFeedAmount: double.parse(dailyAmount.toStringAsFixed(2)),
        feedType: feedType,
      ));
    }
    return schedules;
  }
}