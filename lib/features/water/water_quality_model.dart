class WaterQualityEntry {
  final String id;
  final String tankId;
  final DateTime date;
  final double? ph;
  final double? ammonia;
  final double? nitrite;
  final double? salinity;
  final double? temperature;
  final double? dissolvedOxygen;
  final String? notes;

  WaterQualityEntry({
    required this.id,
    required this.tankId,
    required this.date,
    this.ph,
    this.ammonia,
    this.nitrite,
    this.salinity,
    this.temperature,
    this.dissolvedOxygen,
    this.notes,
  });

  factory WaterQualityEntry.fromJson(Map<String, dynamic> json) => WaterQualityEntry(
    id: json['id'],
    tankId: json['tank_id'],
    date: DateTime.parse(json['date']),
    ph: json['ph']?.toDouble(),
    ammonia: json['ammonia']?.toDouble(),
    nitrite: json['nitrite']?.toDouble(),
    salinity: json['salinity']?.toDouble(),
    temperature: json['temperature']?.toDouble(),
    dissolvedOxygen: json['dissolved_oxygen']?.toDouble(),
    notes: json['notes'],
  );
}