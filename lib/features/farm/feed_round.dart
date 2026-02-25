import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Represents a single feeding round execution.
/// Covers both Blind Feeding (Module 3) and Tray Feeding (Module 5) events.
@immutable
class FeedRound {
  final String id;
  final String pondId;
  final DateTime scheduledAt;
  final DateTime? executedAt; // Timestamp when worker marks complete
  final double feedQuantity; // Final quantity (edited by supervisor)
  final String feedType;
  final String mixInstructions;
  final String? executedBy; // User ID of the worker
  final bool isCompleted;

  const FeedRound({
    required this.id,
    required this.pondId,
    required this.scheduledAt,
    this.executedAt,
    required this.feedQuantity,
    required this.feedType,
    required this.mixInstructions,
    this.executedBy,
    this.isCompleted = false,
  });

  FeedRound copyWith({
    String? id,
    String? pondId,
    DateTime? scheduledAt,
    DateTime? executedAt,
    double? feedQuantity,
    String? feedType,
    String? mixInstructions,
    String? executedBy,
    bool? isCompleted,
  }) {
    return FeedRound(
      id: id ?? this.id,
      pondId: pondId ?? this.pondId,
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
      'pond_id': pondId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'executed_at': executedAt?.toIso8601String(),
      'feed_quantity': feedQuantity,
      'feed_type': feedType,
      'mix_instructions': mixInstructions,
      'executed_by': executedBy,
      'is_completed': isCompleted,
    };
  }

  factory FeedRound.fromMap(Map<String, dynamic> map) {
    return FeedRound(
      id: map['id'] ?? '',
      pondId: map['pond_id'] ?? '',
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

  factory FeedRound.fromJson(String source) => FeedRound.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FeedRound(id: $id, pondId: $pondId, scheduledAt: $scheduledAt, executedAt: $executedAt, feedQuantity: $feedQuantity, feedType: $feedType, mixInstructions: $mixInstructions, executedBy: $executedBy, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FeedRound &&
        other.id == id &&
        other.pondId == pondId &&
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
        pondId.hashCode ^
        scheduledAt.hashCode ^
        executedAt.hashCode ^
        feedQuantity.hashCode ^
        feedType.hashCode ^
        mixInstructions.hashCode ^
        executedBy.hashCode ^
        isCompleted.hashCode;
  }
}