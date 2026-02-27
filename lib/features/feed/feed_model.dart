// lib/features/feed/feed_model.dart
import 'package:flutter/foundation.dart';

@immutable
class FeedEntry {
  final String id;
  final String tankId;
  final DateTime? executedAt;
  final double feedQuantity;
  final String feedType;
  final String mixInstructions;
  final String? trayStatus; // 'completed', 'little_left', 'half', 'too_much'
  final double? trayScore;

  const FeedEntry({
    required this.id,
    required this.tankId,
    this.executedAt,
    required this.feedQuantity,
    required this.feedType,
    this.mixInstructions = '',
    this.trayStatus,
    this.trayScore,
  });

  factory FeedEntry.fromJson(Map<String, dynamic> json) {
    return FeedEntry(
      id: json['id'],
      tankId: json['tank_id'],
      executedAt: json['executed_at'] != null ? DateTime.parse(json['executed_at']) : null,
      feedQuantity: (json['feed_quantity'] as num).toDouble(),
      feedType: json['feed_type'],
      mixInstructions: json['mix_instructions'] ?? '',
      trayStatus: json['tray_status'],
      trayScore: (json['tray_score'] as num?)?.toDouble(),
    );
  }
}