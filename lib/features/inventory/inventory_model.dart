class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final DateTime lastRestocked;
  final double? minThreshold;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.lastRestocked,
    this.minThreshold,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'] as String,
    name: json['name'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    unit: json['unit'] as String,
    category: json['category'] as String,
    lastRestocked: DateTime.parse(json['last_restocked'] as String),
    minThreshold: json['min_threshold'] != null ? (json['min_threshold'] as num).toDouble() : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'category': category,
    'last_restocked': lastRestocked.toIso8601String(),
    'min_threshold': minThreshold,
  };

  bool get isLowStock => minThreshold != null && quantity < minThreshold!;
}
