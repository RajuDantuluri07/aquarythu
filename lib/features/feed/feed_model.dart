import 'package:flutter/foundation.dart';

@immutable
class FeedEntry {
  final String id;
  final String tankId;
  final DateTime date; // executed_at
  final double amount; // feed_quantity
  final String feedType;
  final String mixInstructions;

  const FeedEntry({
    required this.id,
    required this.tankId,
    required this.date,
    required this.amount,
    required this.feedType,
    this.mixInstructions = '',
  });

  factory FeedEntry.fromJson(Map<String, dynamic> json) {
    return FeedEntry(
      id: json['id'],
      tankId: json['tank_id'],
      date: DateTime.parse(json['executed_at'] ?? json['scheduled_at']),
      amount: (json['feed_quantity'] as num).toDouble(),
      feedType: json['feed_type'],
      mixInstructions: json['mix_instructions'] ?? '',
    );
  }
}