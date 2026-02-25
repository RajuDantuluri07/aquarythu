import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Represents a single farm entity.
@immutable
class Farm {
  final String id;
  final String userId;
  final String name;

  const Farm({
    required this.id,
    required this.userId,
    required this.name,
  });

  Farm copyWith({
    String? id,
    String? userId,
    String? name,
  }) {
    return Farm(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
    };
  }

  factory Farm.fromMap(Map<String, dynamic> map) {
    return Farm(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Farm.fromJson(String source) => Farm.fromMap(json.decode(source));

  @override
  String toString() => 'Farm(id: $id, userId: $userId, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Farm && other.id == id && other.userId == userId && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ name.hashCode;
}