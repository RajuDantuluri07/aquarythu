class HarvestEntry {
  final String id;
  final String tankId;
  final DateTime date;
  final double weight;
  final int? count;
  final double? price;
  
  HarvestEntry({
    required this.id,
    required this.tankId,
    required this.date,
    required this.weight,
    this.count,
    this.price,
  });
  
  factory HarvestEntry.fromJson(Map<String, dynamic> json) => HarvestEntry(
    id: json['id'],
    tankId: json['tank_id'],
    date: DateTime.parse(json['date']),
    weight: json['weight'].toDouble(),
    count: json['count'],
    price: json['price']?.toDouble(),
  );
}
