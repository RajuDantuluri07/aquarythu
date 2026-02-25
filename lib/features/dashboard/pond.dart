import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Represents a single pond within a farm, based on PRD Module 2.
@immutable
class Pond {
  final String id;
  final String farmId;
  final String name;
  final double acreSize;
  final int stockingCount;
  final int plPerM2;
  final DateTime stockingDate;
  final int numberOfTrays;
  final double aerationHp;
  final String waterSource;

  const Pond({
    required this.id,
    required this.farmId,
    required this.name,
    required this.acreSize,
    required this.stockingCount,
    required this.plPerM2,
    required this.stockingDate,
    required this.numberOfTrays,
    required this.aerationHp,
    required this.waterSource,
  });

  Pond copyWith({
    String? id,
    String? farmId,
    String? name,
    double? acreSize,
    int? stockingCount,
    int? plPerM2,
    DateTime? stockingDate,
    int? numberOfTrays,
    double? aerationHp,
    String? waterSource,
  }) {
    return Pond(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      acreSize: acreSize ?? this.acreSize,
      stockingCount: stockingCount ?? this.stockingCount,
      plPerM2: plPerM2 ?? this.plPerM2,
      stockingDate: stockingDate ?? this.stockingDate,
      numberOfTrays: numberOfTrays ?? this.numberOfTrays,
      aerationHp: aerationHp ?? this.aerationHp,
      waterSource: waterSource ?? this.waterSource,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farm_id': farmId,
      'name': name,
      'acre_size': acreSize,
      'stocking_count': stockingCount,
      'pl_per_m2': plPerM2,
      'stocking_date': stockingDate.toIso8601String(),
      'number_of_trays': numberOfTrays,
      'aeration_hp': aerationHp,
      'water_source': waterSource,
    };
  }

  factory Pond.fromMap(Map<String, dynamic> map) {
    return Pond(
      id: map['id'] ?? '',
      farmId: map['farm_id'] ?? '',
      name: map['name'] ?? '',
      acreSize: map['acre_size']?.toDouble() ?? 0.0,
      stockingCount: map['stocking_count']?.toInt() ?? 0,
      plPerM2: map['pl_per_m2']?.toInt() ?? 0,
      stockingDate: DateTime.parse(map['stocking_date']),
      numberOfTrays: map['number_of_trays']?.toInt() ?? 0,
      aerationHp: map['aeration_hp']?.toDouble() ?? 0.0,
      waterSource: map['water_source'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Pond.fromJson(String source) => Pond.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Pond(id: $id, farmId: $farmId, name: $name, acreSize: $acreSize, stockingCount: $stockingCount, plPerM2: $plPerM2, stockingDate: $stockingDate, numberOfTrays: $numberOfTrays, aerationHp: $aerationHp, waterSource: $waterSource)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pond &&
        other.id == id &&
        other.farmId == farmId &&
        other.name == name &&
        other.acreSize == acreSize &&
        other.stockingCount == stockingCount &&
        other.plPerM2 == plPerM2 &&
        other.stockingDate == stockingDate &&
        other.numberOfTrays == numberOfTrays &&
        other.aerationHp == aerationHp &&
        other.waterSource == waterSource;
  }

  @override
  int get hashCode {
    return id.hashCode ^ farmId.hashCode ^ name.hashCode ^ acreSize.hashCode ^ stockingCount.hashCode ^ plPerM2.hashCode ^ stockingDate.hashCode ^ numberOfTrays.hashCode ^ aerationHp.hashCode ^ waterSource.hashCode;
  }
}