import '../../core/utils/date_utils.dart';

class Tank {
  final String id;
  final String farmId;
  final String name;
  final double? size;
  final DateTime stockingDate;
  final int? initialSeed;
  final String? plSize;
  final int checkTrays;
  double biomass;
  int blindDuration;
  int blindWeek1;
  int blindStd;
  List<dynamic>? blindSchedule;
  bool hasTransitionedFromBlind;
  String status;
  String? healthStatus;
  String? healthNotes;
  int deadCount;
  
  int get doc => AppDateUtils.getDaysOld(stockingDate);
  
  Tank({
    required this.id,
    required this.farmId,
    required this.name,
    this.size,
    required this.stockingDate,
    this.initialSeed,
    this.plSize,
    this.checkTrays = 2,
    this.biomass = 0,
    this.blindDuration = 30,
    this.blindWeek1 = 2,
    this.blindStd = 4,
    this.blindSchedule,
    this.hasTransitionedFromBlind = false,
    this.status = 'active',
    this.healthStatus = 'healthy',
    this.healthNotes,
    this.deadCount = 0,
  });
  
  Tank copyWith({
    String? id,
    String? farmId,
    String? name,
    double? size,
    DateTime? stockingDate,
    int? initialSeed,
    String? plSize,
    int? checkTrays,
    double? biomass,
    int? blindDuration,
    int? blindWeek1,
    int? blindStd,
    List<dynamic>? blindSchedule,
    bool? hasTransitionedFromBlind,
    String? status,
    String? healthStatus,
    String? healthNotes,
    int? deadCount,
  }) {
    return Tank(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      size: size ?? this.size,
      stockingDate: stockingDate ?? this.stockingDate,
      initialSeed: initialSeed ?? this.initialSeed,
      plSize: plSize ?? this.plSize,
      checkTrays: checkTrays ?? this.checkTrays,
      biomass: biomass ?? this.biomass,
      blindDuration: blindDuration ?? this.blindDuration,
      blindWeek1: blindWeek1 ?? this.blindWeek1,
      blindStd: blindStd ?? this.blindStd,
      blindSchedule: blindSchedule ?? this.blindSchedule,
      hasTransitionedFromBlind: hasTransitionedFromBlind ?? this.hasTransitionedFromBlind,
      status: status ?? this.status,
      healthStatus: healthStatus ?? this.healthStatus,
      healthNotes: healthNotes ?? this.healthNotes,
      deadCount: deadCount ?? this.deadCount,
    );
  }

  factory Tank.fromJson(Map<String, dynamic> json) => Tank(
    id: json['id'],
    farmId: json['farm_id'],
    name: json['name'],
    size: (json['size'] ?? json['acre_size'])?.toDouble(), // Map acre_size
    stockingDate: DateTime.parse(json['stocking_date']),
    initialSeed: json['initial_seed'] ?? json['stocking_count'], // Map stocking_count
    plSize: json['pl_size']?.toString(), // pl_per_m2 is int in DB, plSize is String here
    checkTrays: json['check_trays'] ?? json['number_of_trays'] ?? 2, // Map number_of_trays
    biomass: (json['biomass'] ?? 0).toDouble(),
    blindDuration: json['blind_duration'] ?? 30,
    blindWeek1: json['blind_week1'] ?? 2,
    blindStd: json['blind_std'] ?? 4,
    blindSchedule: json['blind_schedule'],
    hasTransitionedFromBlind: json['has_transitioned'] ?? false,
    status: json['status'] ?? 'active',
    healthStatus: json['health_status'] ?? 'healthy',
    healthNotes: json['health_notes'],
    deadCount: json['dead_count'] ?? 0,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farm_id': farmId,
      'name': name,
      'size': size,
      'stocking_date': stockingDate.toIso8601String(),
      'initial_seed': initialSeed,
      'pl_size': plSize,
      'check_trays': checkTrays,
      'biomass': biomass,
      'blind_duration': blindDuration,
      'blind_week1': blindWeek1,
      'blind_std': blindStd,
      'blind_schedule': blindSchedule,
      'has_transitioned': hasTransitionedFromBlind,
      'status': status,
      'health_status': healthStatus,
      'health_notes': healthNotes,
      'dead_count': deadCount,
    };
  }
}