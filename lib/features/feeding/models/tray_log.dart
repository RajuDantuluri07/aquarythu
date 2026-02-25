import 'dart:convert';
import 'package:flutter/foundation.dart';

enum TrayStatus {
  completed,
  littleLeft,
  half,
  tooMuch;

  double get weight {
    switch (this) {
      case TrayStatus.completed:
        return 1.0;
      case TrayStatus.littleLeft:
        return 0.75;
      case TrayStatus.half:
        return 0.5;
      case TrayStatus.tooMuch:
        return 0.25;
    }
  }

  String get label {
    switch (this) {
      case TrayStatus.completed:
        return 'Completed';
      case TrayStatus.littleLeft:
        return 'Little Left';
      case TrayStatus.half:
        return 'Half';
      case TrayStatus.tooMuch:
        return 'Too Much';
    }
  }
}

@immutable
class TrayLog {
  final String id;
  final String feedRoundId;
  final int trayNumber;
  final TrayStatus status;

  const TrayLog({
    required this.id,
    required this.feedRoundId,
    required this.trayNumber,
    required this.status,
  });

  TrayLog copyWith({
    String? id,
    String? feedRoundId,
    int? trayNumber,
    TrayStatus? status,
  }) {
    return TrayLog(
      id: id ?? this.id,
      feedRoundId: feedRoundId ?? this.feedRoundId,
      trayNumber: trayNumber ?? this.trayNumber,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feed_round_id': feedRoundId,
      'tray_number': trayNumber,
      'status': status.name,
      'score': status.weight,
    };
  }

  factory TrayLog.fromMap(Map<String, dynamic> map) {
    return TrayLog(
      id: map['id'] ?? '',
      feedRoundId: map['feed_round_id'] ?? '',
      trayNumber: map['tray_number']?.toInt() ?? 0,
      status: TrayStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TrayStatus.completed,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory TrayLog.fromJson(String source) => TrayLog.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TrayLog(id: $id, feedRoundId: $feedRoundId, trayNumber: $trayNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrayLog &&
        other.id == id &&
        other.feedRoundId == feedRoundId &&
        other.trayNumber == trayNumber &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ feedRoundId.hashCode ^ trayNumber.hashCode ^ status.hashCode;
  }
}