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
  
  factory Tank.fromJson(Map<String, dynamic> json) => Tank(
    id: json['id'],
    farmId: json['farm_id'],
    name: json['name'],
    size: json['size']?.toDouble(),
    stockingDate: DateTime.parse(json['stocking_date']),
    initialSeed: json['initial_seed'],
    plSize: json['pl_size'],
    checkTrays: json['check_trays'] ?? 2,
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
}