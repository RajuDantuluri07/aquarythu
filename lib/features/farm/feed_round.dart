import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Represents a single feeding round execution.
/// Covers both Blind Feeding (Module 3) and Tray Feeding (Module 5) events.
@immutable
class FeedLog {
  final String id;
  final String tankId;
  final DateTime scheduledAt;
  final DateTime? executedAt; // Timestamp when worker marks complete
  final double feedQuantity; // Final quantity (edited by supervisor)
  final String feedType;
  final String mixInstructions;
  final String? executedBy; // User ID of the worker
  final bool isCompleted;

  const FeedLog({
    required this.id,
    required this.tankId,
    required this.scheduledAt,
    this.executedAt,
    required this.feedQuantity,
    required this.feedType,
    required this.mixInstructions,
    this.executedBy,
    this.isCompleted = false,
  });

  FeedLog copyWith({
    String? id,
    String? tankId,
    DateTime? scheduledAt,
    DateTime? executedAt,
    double? feedQuantity,
    String? feedType,
    String? mixInstructions,
    String? executedBy,
    bool? isCompleted,
  }) {
    return FeedLog(
      id: id ?? this.id,
      tankId: tankId ?? this.tankId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      executedAt: executedAt ?? this.executedAt,
      feedQuantity: feedQuantity ?? this.feedQuantity,
      feedType: feedType ?? this.feedType,
      mixInstructions: mixInstructions ?? this.mixInstructions,
      executedBy: executedBy ?? this.executedBy,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tank_id': tankId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'executed_at': executedAt?.toIso8601String(),
      'feed_quantity': feedQuantity,
      'feed_type': feedType,
      'mix_instructions': mixInstructions,
      'executed_by': executedBy,
      'is_completed': isCompleted,
    };
  }

  factory FeedLog.fromMap(Map<String, dynamic> map) {
    return FeedLog(
      id: map['id'] ?? '',
      tankId: map['tank_id'] ?? '',
      scheduledAt: DateTime.parse(map['scheduled_at']),
      executedAt: map['executed_at'] != null ? DateTime.parse(map['executed_at']) : null,
      feedQuantity: map['feed_quantity']?.toDouble() ?? 0.0,
      feedType: map['feed_type'] ?? '',
      mixInstructions: map['mix_instructions'] ?? '',
      executedBy: map['executed_by'],
      isCompleted: map['is_completed'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedLog.fromJson(String source) => FeedLog.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FeedLog(id: $id, tankId: $tankId, scheduledAt: $scheduledAt, executedAt: $executedAt, feedQuantity: $feedQuantity, feedType: $feedType, mixInstructions: $mixInstructions, executedBy: $executedBy, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FeedLog &&
        other.id == id &&
        other.tankId == tankId &&
        other.scheduledAt == scheduledAt &&
        other.executedAt == executedAt &&
        other.feedQuantity == feedQuantity &&
        other.feedType == feedType &&
        other.mixInstructions == mixInstructions &&
        other.executedBy == executedBy &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tankId.hashCode ^
        scheduledAt.hashCode ^
        executedAt.hashCode ^
        feedQuantity.hashCode ^
        feedType.hashCode ^
        mixInstructions.hashCode ^
        executedBy.hashCode ^
        isCompleted.hashCode;
  }
}