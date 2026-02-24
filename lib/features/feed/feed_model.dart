class FeedEntry {
  final String id;
  final String tankId;
  final DateTime date;
  final double amount;
  final String? time;
  final String? trayResult;
  final List<String>? supplements;
  final String? reason;
  final bool healthObserved;
  final int mortality;
  final String? disease;
  
  FeedEntry({
    required this.id,
    required this.tankId,
    required this.date,
    required this.amount,
    this.time,
    this.trayResult,
    this.supplements,
    this.reason,
    this.healthObserved = false,
    this.mortality = 0,
    this.disease,
  });
  
  factory FeedEntry.fromJson(Map<String, dynamic> json) => FeedEntry(
    id: json['id'],
    tankId: json['tank_id'],
    date: DateTime.parse(json['date']),
    amount: json['amount'].toDouble(),
    time: json['time'],
    trayResult: json['tray_result'],
    supplements: json['supplements'] != null ? List<String>.from(json['supplements']) : null,
    reason: json['reason'],
    healthObserved: json['health_observed'] ?? false,
    mortality: json['mortality'] ?? 0,
    disease: json['disease'],
  );
}
