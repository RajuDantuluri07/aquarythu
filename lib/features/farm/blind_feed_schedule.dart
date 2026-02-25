import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Represents the auto-generated feeding schedule for the blind feeding phase (DOC 1-30).
@immutable
class BlindFeedSchedule {
  final String id;
  final String tankId;
  final int dayOfCulture;
  final double dailyFeedAmount;
  final String feedType;

  const BlindFeedSchedule({
    required this.id,
    required this.tankId,
    required this.dayOfCulture,
    required this.dailyFeedAmount,
    required this.feedType,
  });

  BlindFeedSchedule copyWith({
    String? id,
    String? tankId,
    int? dayOfCulture,
    double? dailyFeedAmount,
    String? feedType,
  }) {
    return BlindFeedSchedule(
      id: id ?? this.id,
      tankId: tankId ?? this.tankId,
      dayOfCulture: dayOfCulture ?? this.dayOfCulture,
      dailyFeedAmount: dailyFeedAmount ?? this.dailyFeedAmount,
      feedType: feedType ?? this.feedType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tank_id': tankId,
      'day_of_culture': dayOfCulture,
      'daily_feed_amount': dailyFeedAmount,
      'feed_type': feedType,
    };
  }

  factory BlindFeedSchedule.fromMap(Map<String, dynamic> map) {
    return BlindFeedSchedule(
      id: map['id'] ?? '',
      tankId: map['tank_id'] ?? '',
      dayOfCulture: map['day_of_culture']?.toInt() ?? 0,
      dailyFeedAmount: map['daily_feed_amount']?.toDouble() ?? 0.0,
      feedType: map['feed_type'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BlindFeedSchedule.fromJson(String source) => BlindFeedSchedule.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BlindFeedSchedule(id: $id, tankId: $tankId, dayOfCulture: $dayOfCulture, dailyFeedAmount: $dailyFeedAmount, feedType: $feedType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BlindFeedSchedule &&
        other.id == id &&
        other.tankId == tankId &&
        other.dayOfCulture == dayOfCulture &&
        other.dailyFeedAmount == dailyFeedAmount &&
        other.feedType == feedType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tankId.hashCode ^
        dayOfCulture.hashCode ^
        dailyFeedAmount.hashCode ^
        feedType.hashCode;
  }
}