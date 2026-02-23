import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// ========== THEME & COLORS ==========
class AppColors {
  static const primary = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF1976D2);
  static const primaryLight = Color(0xFFE3F2FD);
  static const success = Color(0xFF4CAF50);
  static const successDark = Color(0xFF2E7D32);
  static const successLight = Color(0xFFE8F5E9);
  static const danger = Color(0xFFF44336);
  static const dangerLight = Color(0xFFFFEBEE);
  static const warning = Color(0xFFFF9800);
  static const warningDark = Color(0xFFEF6C00);
  static const warningLight = Color(0xFFFFF3E0);
  static const info = Color(0xFF00BCD4);
  static const infoLight = Color(0xFFE0F7FA);
  
  // Grays
  static const gray50 = Color(0xFFFAFAFA);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFEEEEEE);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray400 = Color(0xFFBDBDBD);
  static const gray500 = Color(0xFF9E9E9E);
  static const gray600 = Color(0xFF757575);
  static const gray700 = Color(0xFF616161);
  static const gray800 = Color(0xFF424242);
  static const gray900 = Color(0xFF212121);
}

// ========== DATE UTILITIES ==========
class AppDateUtils {
  static String getFormattedDate([DateTime? date]) {
    final d = date ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
  
  static int getDaysOld(DateTime stockingDate) {
    final today = DateTime.now();
    final start = DateTime(
      stockingDate.year,
      stockingDate.month,
      stockingDate.day,
    );
    final now = DateTime(today.year, today.month, today.day);
    return now.difference(start).inDays;
  }
  
  static String getDisplayDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }
  
  static String getShortDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }
}

// ========== MODELS ==========
class Farm {
  final String id;
  final String name;
  final String? location;
  final String? contact;
  final String? phone;
  
  Farm({
    required this.id,
    required this.name,
    this.location,
    this.contact,
    this.phone,
  });
  
  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
    id: json['id'],
    name: json['name'],
    location: json['location'],
    contact: json['contact'],
    phone: json['phone'],
  );
}

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

// ========== PROVIDERS ==========
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _authStateSubscription;
  User? _user;

  AuthNotifier() {
    _user = Supabase.instance.client.auth.currentUser;
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  User? get user => _user;

  Future<bool> signIn(String email, String password) async {
    try {
      print("🔐 Attempting login with: $email");
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      print("✅ Login successful!");
      return true;
    } on AuthException catch (e) {
      print("❌ Auth Error: ${e.message}");
      return false;
    } catch (e) {
      print("❌ Unexpected error: $e");
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      print("📝 Attempting signup with: $email");
      await Supabase.instance.client.auth
          .signUp(email: email, password: password);
      print("✅ Signup request sent. Please check your email for confirmation.");
      return true;
    } on AuthException catch (e) {
      print("❌ Auth Error: ${e.message}");
      return false;
    } catch (e) {
      print("❌ Unexpected error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        print("🔐 Attempting Google login for web...");
        return await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          // For web, configure redirect URLs in your Supabase project settings.
        );
      } else {
        // Mobile-specific implementation
        print("🔐 Attempting Google login for mobile...");

        // IMPORTANT: Replace with your actual Google Cloud web client ID
        const webClientId = '782759620106-3uvpbdnvsog7fto0ckiht7p6evv3cgjs.apps.googleusercontent.com';

        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: webClientId,
        );

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          print("Google sign-in was cancelled by user.");
          return false;
        }
        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (accessToken == null || idToken == null) {
          throw 'Google sign-in failed: Missing token.';
        }

        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        print("✅ Google login successful!");
        return true;
      }
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      return false;
    }
  }

  bool get isAuthenticated => _user != null;
}

class FarmProvider extends ChangeNotifier {
  List<Farm> _farms = [];
  Farm? _currentFarm;
  
  List<Farm> get farms => _farms;
  Farm? get currentFarm => _currentFarm;

  Future<void> loadFarms(String userId) async {
    final response = await Supabase.instance.client
        .from('farms')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    _farms = (response as List).map((e) => Farm.fromJson(e)).toList();
    if (_farms.isNotEmpty && _currentFarm == null) {
      _currentFarm = _farms.first;
    }
    notifyListeners();
  }

  Future<void> addFarm(String userId, String name, {String? location, String? contact, String? phone}) async {
    final response = await Supabase.instance.client
        .from('farms')
        .insert({
          'user_id': userId,
          'name': name,
          'location': location,
          'contact': contact,
          'phone': phone,
        })
        .select()
        .single();
    _farms.add(Farm.fromJson(response));
    if (_farms.length == 1) _currentFarm = _farms.first;
    notifyListeners();
  }

  void selectFarm(Farm farm) {
    _currentFarm = farm;
    notifyListeners();
  }

  Future<void> updateFarm(Farm farm) async {
    final response = await Supabase.instance.client
        .from('farms')
        .update({
          'name': farm.name,
          'location': farm.location,
          'contact': farm.contact,
          'phone': farm.phone,
        })
        .eq('id', farm.id)
        .select()
        .single();
    final index = _farms.indexWhere((f) => f.id == farm.id);
    if (index != -1) {
      _farms[index] = Farm.fromJson(response);
    }
    notifyListeners();
  }

  Future<void> deleteFarm(String farmId) async {
    await Supabase.instance.client.from('farms').delete().eq('id', farmId);
    _farms.removeWhere((f) => f.id == farmId);
    notifyListeners();
  }
}

class TankProvider extends ChangeNotifier {
  List<Tank> _tanks = [];
  List<Tank> get tanks => _tanks;

  Future<void> loadTanks(String farmId) async {
    final response = await Supabase.instance.client
        .from('tanks')
        .select()
        .eq('farm_id', farmId);
    _tanks = (response as List).map((e) => Tank.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addTank(Tank tank) async {
    final response = await Supabase.instance.client
        .from('tanks')
        .insert({
          'farm_id': tank.farmId,
          'name': tank.name,
          'size': tank.size,
          'stocking_date': AppDateUtils.getFormattedDate(tank.stockingDate),
          'initial_seed': tank.initialSeed,
          'pl_size': tank.plSize,
          'check_trays': tank.checkTrays,
          'blind_duration': tank.blindDuration,
          'blind_week1': tank.blindWeek1,
          'blind_std': tank.blindStd,
        })
        .select()
        .single();
    _tanks.add(Tank.fromJson(response));
    notifyListeners();
  }

  Future<void> updateTank(Tank tank) async {
    await Supabase.instance.client
        .from('tanks')
        .update({
          'name': tank.name,
          'size': tank.size,
          'stocking_date': AppDateUtils.getFormattedDate(tank.stockingDate),
          'initial_seed': tank.initialSeed,
          'pl_size': tank.plSize,
          'check_trays': tank.checkTrays,
          'blind_duration': tank.blindDuration,
          'blind_week1': tank.blindWeek1,
          'blind_std': tank.blindStd,
          'health_status': tank.healthStatus,
          'health_notes': tank.healthNotes,
          'dead_count': tank.deadCount,
        })
        .eq('id', tank.id);
    final index = _tanks.indexWhere((t) => t.id == tank.id);
    if (index != -1) {
      _tanks[index] = tank;
    }
    notifyListeners();
  }

  Future<void> deleteTank(String tankId) async {
    await Supabase.instance.client
        .from('tanks')
        .delete()
        .eq('id', tankId);
    _tanks.removeWhere((t) => t.id == tankId);
    notifyListeners();
  }
}

class FeedProvider extends ChangeNotifier {
  List<FeedEntry> _entries = [];
  List<FeedEntry> get entries => _entries;

  double get totalFeed => _entries.fold(0, (sum, e) => sum + e.amount);
  
  double get todayFeed {
    final today = AppDateUtils.getFormattedDate();
    return _entries
        .where((e) => AppDateUtils.getFormattedDate(e.date) == today)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getFeedWastePercentage() {
    final validChecks = _entries.where((e) => 
        ['empty', 'little', 'half', 'too-much'].contains(e.trayResult)).toList();
    if (validChecks.isEmpty) return 0;
    final wasteChecks = validChecks.where((e) => 
        ['half', 'too-much'].contains(e.trayResult)).length;
    return (wasteChecks / validChecks.length) * 100;
  }

  int getPendingChecksCount() {
    return _entries.where((e) => e.trayResult == 'pending').length;
  }

  Future<void> loadEntries(String tankId) async {
    final response = await Supabase.instance.client
        .from('feed_entries')
        .select()
        .eq('tank_id', tankId)
        .order('date', ascending: false);
    _entries = (response as List).map((e) => FeedEntry.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addEntry(FeedEntry entry) async {
    final response = await Supabase.instance.client
        .from('feed_entries')
        .insert({
          'tank_id': entry.tankId,
          'date': AppDateUtils.getFormattedDate(entry.date),
          'amount': entry.amount,
          'time': entry.time,
          'tray_result': entry.trayResult,
          'supplements': entry.supplements,
          'reason': entry.reason,
          'health_observed': entry.healthObserved,
          'mortality': entry.mortality,
          'disease': entry.disease,
        })
        .select()
        .single();
    _entries.insert(0, FeedEntry.fromJson(response));
    notifyListeners();
  }

  Future<void> updateEntry(FeedEntry entry) async {
    await Supabase.instance.client
        .from('feed_entries')
        .update({
          'amount': entry.amount,
          'tray_result': entry.trayResult,
          'supplements': entry.supplements,
          'reason': entry.reason,
        })
        .eq('id', entry.id);
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
    }
    notifyListeners();
  }

  Future<void> deleteEntry(String entryId) async {
    await Supabase.instance.client
        .from('feed_entries')
        .delete()
        .eq('id', entryId);
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();
  }
}

class WaterQualityProvider extends ChangeNotifier {
  List<WaterQualityEntry> _entries = [];
  List<WaterQualityEntry> get entries => _entries;

  Future<void> loadEntries(String tankId) async {
    final response = await Supabase.instance.client
        .from('water_quality_entries')
        .select()
        .eq('tank_id', tankId)
        .order('date', ascending: false);
    _entries = (response as List).map((e) => WaterQualityEntry.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addEntry(WaterQualityEntry entry) async {
    final response = await Supabase.instance.client
        .from('water_quality_entries')
        .insert({
          'tank_id': entry.tankId,
          'date': AppDateUtils.getFormattedDate(entry.date),
          'ph': entry.ph,
          'ammonia': entry.ammonia,
          'nitrite': entry.nitrite,
          'salinity': entry.salinity,
          'temperature': entry.temperature,
          'dissolved_oxygen': entry.dissolvedOxygen,
          'notes': entry.notes,
        })
        .select()
        .single();
    _entries.insert(0, WaterQualityEntry.fromJson(response));
    notifyListeners();
  }
}

class HarvestProvider extends ChangeNotifier {
  List<HarvestEntry> _entries = [];
  List<HarvestEntry> get entries => _entries;
  
  double get totalHarvest => _entries.fold(0, (sum, e) => sum + e.weight);

  Future<void> loadHarvests(String tankId) async {
    final response = await Supabase.instance.client
        .from('harvest_entries')
        .select()
        .eq('tank_id', tankId);
    _entries = (response as List).map((e) => HarvestEntry.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addHarvest(HarvestEntry entry) async {
    final response = await Supabase.instance.client
        .from('harvest_entries')
        .insert({
          'tank_id': entry.tankId,
          'date': AppDateUtils.getFormattedDate(entry.date),
          'weight': entry.weight,
          'count': entry.count,
          'price': entry.price,
        })
        .select()
        .single();
    _entries.add(HarvestEntry.fromJson(response));
    notifyListeners();
  }
}

// ========== CUSTOM WIDGETS ==========

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: AppColors.gray400, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TankCard extends StatelessWidget {
  final Tank tank;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TankCard({
    super.key,
    required this.tank,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    if (tank.doc > 75) return AppColors.danger;
    if (tank.doc > 50) return AppColors.warning;
    return AppColors.success;
  }

  String get _phaseLabel {
    if (tank.doc <= 3) return 'Phase 1 · Stocking';
    if (tank.doc <= 15) return 'Phase 2 · Stabilisation';
    if (tank.doc <= 30) return 'Phase 3 · Biomass';
    return '';
  }

  String get _trayPhaseLabel {
    if (tank.status == 'inactive') return '';
    if (tank.doc <= tank.blindDuration && !tank.hasTransitionedFromBlind) {
      return 'Blind Feed Mode';
    } else if (tank.doc > tank.blindDuration && !tank.hasTransitionedFromBlind) {
      return 'Tray Training';
    } else if (tank.hasTransitionedFromBlind) {
      return 'Tray Active';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.gray200),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.water_drop, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tank.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900,
                                ),
                              ),
                              if (_phaseLabel.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _phaseLabel,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DOC ${tank.doc}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: AppColors.gray600),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Tank'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: AppColors.danger),
                              SizedBox(width: 8),
                              Text('Delete Tank', style: TextStyle(color: AppColors.danger)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem('Size', '${tank.size ?? '-'} ac'),
                        ),
                        Expanded(
                          child: _buildInfoItem('Stock', '${tank.initialSeed ?? 0}'),
                        ),
                        Expanded(
                          child: _buildInfoItem('Trays', '${tank.checkTrays}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem('Feed Today', '${tank.biomass.toStringAsFixed(1)} kg'),
                        ),
                        Expanded(
                          child: _buildStatItem('Total Feed', '${tank.biomass.toStringAsFixed(1)} kg'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.gray200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.scale, size: 14, color: AppColors.gray500),
                                const SizedBox(width: 4),
                                Text(
                                  'Biomass: ${tank.biomass.toStringAsFixed(0)} kg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.trending_up, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'FCR: 1.2',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_trayPhaseLabel.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.infoLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _trayPhaseLabel,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class FeedEntryCard extends StatelessWidget {
  final FeedEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const FeedEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onEdit,
  });

  Color get _statusColor {
    switch (entry.trayResult) {
      case 'empty': return AppColors.success;
      case 'little': return AppColors.info;
      case 'half': return AppColors.warning;
      case 'too-much': return AppColors.danger;
      case 'pending': return AppColors.warning;
      default: return AppColors.gray500;
    }
  }

  String get _statusText {
    switch (entry.trayResult) {
      case 'empty': return 'Empty';
      case 'little': return 'Little Left';
      case 'half': return 'Half Left';
      case 'too-much': return 'Too Much';
      case 'pending': return 'Pending';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${entry.amount.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '@ ${entry.time ?? '--:--'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    if (entry.supplements != null && entry.supplements!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: entry.supplements!.map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: Icon(Icons.edit, size: 18, color: AppColors.gray500),
                    onPressed: onEdit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterQualityEntryCard extends StatelessWidget {
  final WaterQualityEntry entry;

  const WaterQualityEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppDateUtils.getDisplayDate(entry.date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.gray700,
            ),
          ),
          const Divider(height: 24),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            children: [
              _buildParam('pH', entry.ph?.toStringAsFixed(1) ?? '-', Icons.science),
              _buildParam('Ammonia', entry.ammonia?.toStringAsFixed(2) ?? '-', Icons.warning_amber_rounded),
              _buildParam('Nitrite', entry.nitrite?.toStringAsFixed(2) ?? '-', Icons.dangerous_outlined),
              _buildParam('Salinity', entry.salinity?.toStringAsFixed(1) ?? '-', Icons.waves),
              _buildParam('Temp', '${entry.temperature?.toStringAsFixed(1) ?? '-'}°C', Icons.thermostat),
              _buildParam('DO', entry.dissolvedOxygen?.toStringAsFixed(1) ?? '-', Icons.air),
            ],
          ),
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Notes:',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gray600),
            ),
            const SizedBox(height: 4),
            Text(entry.notes!, style: TextStyle(color: AppColors.gray700)),
          ]
        ],
      ),
    );
  }

  Widget _buildParam(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.gray500),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.gray600)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray900)),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray200, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ========== SCREENS ==========

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AquaRythu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart Aquaculture Management',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: AppColors.gray500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: AppColors.gray500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final auth = context.read<AuthNotifier>();
                          final success = await auth.signIn(
                            emailController.text,
                            passwordController.text,
                          );
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Login failed'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        final auth = context.read<AuthNotifier>();
                        final success = await auth.signUp(
                          emailController.text,
                          passwordController.text,
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registration successful! Please check your email to confirm.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registration failed'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("OR", style: TextStyle(color: AppColors.gray600)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final auth = context.read<AuthNotifier>();
                          final success = await auth.signInWithGoogle();
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Google Sign-In failed. Please try again.'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        },
                        // IMPORTANT: Add 'assets/google_logo.png' to your project
                        // and declare it in pubspec.yaml
                        icon: Image.asset('assets/google_logo.png', height: 22.0),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gray700,
                          side: BorderSide(color: AppColors.gray300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthNotifier>();
    if (auth.user != null) {
      await context.read<FarmProvider>().loadFarms(auth.user!.id);
      if (context.mounted) {
        final farmProvider = context.read<FarmProvider>();
        if (farmProvider.currentFarm != null) {
          await context.read<TankProvider>().loadTanks(farmProvider.currentFarm!.id);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = context.watch<FarmProvider>();
    final tankProvider = context.watch<TankProvider>();

    // TODO: Calculate global feed metrics. This requires a larger architectural
    // change to fetch feed data for all tanks, possibly through a global provider
    // or backend aggregation, to avoid performance issues.
    final totalBiomass = tankProvider.tanks.fold<double>(0, (sum, tank) => sum + tank.biomass);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 80,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _showFarmSelector(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.agriculture, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    farmProvider.currentFarm?.name ?? 'Select Farm',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          AppDateUtils.getDisplayDate(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // First Time User Message
            if (farmProvider.farms.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 3),
                        ),
                        child: Icon(Icons.agriculture, size: 40, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to AquaRythu! 🎉',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'To get started, you need to add your first farm. This will unlock all features including feed tracking, applications, and price monitoring.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.gray600),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: AppColors.warningDark, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Important: All data is stored locally on this device only. Please use the backup feature regularly.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.warningDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showAddFarmDialog(context);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Your First Farm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Farm Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray200, width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.agriculture, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  farmProvider.currentFarm?.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${tankProvider.tanks.length} Tanks',
                                  style: TextStyle(color: AppColors.gray600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, color: AppColors.gray600),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: AppColors.gray600),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Key Metrics
                    SectionHeader(
                      title: 'Key Metrics',
                      icon: Icons.pie_chart,
                      trailing: TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.compare_arrows, size: 18),
                        label: const Text('Compare'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                label: 'Total Tanks',
                                value: '${tankProvider.tanks.length}',
                                icon: Icons.water_drop,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                label: 'Feed Consumed',
                                value: '0 kg',
                                icon: Icons.food_bank,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                label: 'Avg FCR',
                                value: '0.00',
                                icon: Icons.trending_up,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                label: 'Total Biomass',
                                value: '${totalBiomass.toStringAsFixed(0)} kg',
                                icon: Icons.scale,
                                color: AppColors.info,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                label: 'Feed Today',
                                value: '0 kg',
                                icon: Icons.today,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                label: 'Feed Waste %',
                                value: '0%',
                                icon: Icons.warning,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Inventory Section
                    SectionHeader(
                      title: 'Inventory',
                      icon: Icons.inventory,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '0 kg',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Text(
                                      'Feed Stock',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.gray600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Flexible(
                                      child: Text('Add Stock',
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.gray700,
                                      side: BorderSide(color: AppColors.gray300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '0 Items',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Text(
                                      'Medicine & Minerals',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.gray600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.medical_services, size: 16),
                                    label: const Flexible(
                                      child:
                                          Text('Manage', overflow: TextOverflow.ellipsis),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.gray700,
                                      side: BorderSide(color: AppColors.gray300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tanks Section
                    SectionHeader(
                      title: 'Tanks',
                      icon: Icons.water,
                      trailing: IconButton(
                        icon: Icon(Icons.add, color: AppColors.primary),
                        onPressed: () {
                          _showAddTankDialog(context, farmProvider.currentFarm!.id);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
            
            // Tanks List
            if (farmProvider.farms.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tank = tankProvider.tanks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TankCard(
                          tank: tank,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TankDetailScreen(tank: tank),
                              ),
                            );
                          },
                          onEdit: () => _showTankDialog(context, tank.farmId, tank: tank),
                          onDelete: () {
                            _showDeleteConfirmation(context, tank.id);
                          },
                        ),
                      );
                    },
                    childCount: tankProvider.tanks.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFarmSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<FarmProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Select Farm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.farms.length,
                      itemBuilder: (context, index) {
                        final farm = provider.farms[index];
                        final isSelected = farm.id == provider.currentFarm?.id;
                        return ListTile(
                          leading: Icon(
                            Icons.agriculture,
                            color: isSelected ? AppColors.primary : AppColors.gray500,
                          ),
                          title: Text(
                            farm.name,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.gray900,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            provider.selectFarm(farm);
                            context.read<TankProvider>().loadTanks(farm.id);
                            Navigator.pop(context);
                          },
                          trailing: isSelected
                              ? PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) {
                                    Navigator.pop(context); // Close bottom sheet first
                                    if (value == 'edit') {
                                      _showEditFarmDialog(context, farm);
                                    } else if (value == 'delete') {
                                      _showDeleteFarmConfirmationDialog(context, farm);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit Farm'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete Farm',
                                        style: TextStyle(color: AppColors.danger),
                                      ),
                                    ),
                                  ],
                                )
                              : isSelected
                                  ? const Icon(Icons.check, color: AppColors.primary)
                                  : null,
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.add, color: AppColors.primary),
                    title: const Text(
                      'Add New Farm',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddFarmDialog(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFarmDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Farm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Farm Name',
                  hintText: 'e.g., Shree Shrimp Farm',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Nellore, Andhra Pradesh',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person',
                  hintText: 'Farm Manager Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+91 XXXXX XXXXX',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final auth = context.read<AuthNotifier>();
                await context.read<FarmProvider>().addFarm(
                  auth.user!.id,
                  nameController.text,
                  location: locationController.text,
                  contact: contactController.text,
                  phone: phoneController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save Farm'),
          ),
        ],
      ),
    );
  }

  void _showEditFarmDialog(BuildContext context, Farm farm) {
    final nameController = TextEditingController(text: farm.name);
    final locationController = TextEditingController(text: farm.location);
    final contactController = TextEditingController(text: farm.contact);
    final phoneController = TextEditingController(text: farm.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Farm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Farm Name')),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
              TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact Person')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updatedFarm = Farm(
                id: farm.id,
                name: nameController.text,
                location: locationController.text,
                contact: contactController.text,
                phone: phoneController.text,
              );
              await context.read<FarmProvider>().updateFarm(updatedFarm);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showTankDialog(BuildContext context, String farmId, {Tank? tank}) {
    final isEditing = tank != null;
    final nameController = TextEditingController(text: tank?.name);
    final sizeController = TextEditingController(text: tank?.size?.toString());
    final seedController = TextEditingController(text: tank?.initialSeed?.toString());
    final plSizeController = TextEditingController(text: tank?.plSize);
    DateTime selectedDate = tank?.stockingDate ?? DateTime.now();

    // Default values for dropdowns
    int blindWeek1 = tank?.blindWeek1 ?? 2;
    int blindStd = tank?.blindStd ?? 4;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
          title: Text(isEditing ? 'Edit Tank' : 'Add New Tank'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tank Name',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sizeController,
                        decoration: const InputDecoration(
                          labelText: 'Area (acres)'
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: seedController,
                        decoration: const InputDecoration(
                          labelText: 'Stocking Count'
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: plSizeController,
                        decoration: const InputDecoration(
                          labelText: 'PL Size'
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Stocking Date',
                          ),
                          child: Text(
                            AppDateUtils.getFormattedDate(selectedDate),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: blindWeek1,
                        decoration: const InputDecoration(
                          labelText: 'Week 1 Feeds',
                        ),
                        items: const [
                          DropdownMenuItem(value: 2, child: Text('2 Feeds')),
                          DropdownMenuItem(value: 3, child: Text('3 Feeds')),
                          DropdownMenuItem(value: 4, child: Text('4 Feeds')),
                        ],
                        onChanged: (value) => setState(() => blindWeek1 = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: blindStd,
                        decoration: const InputDecoration(
                          labelText: 'Standard Feeds',
                        ),
                        items: const [
                          DropdownMenuItem(value: 3, child: Text('3 Feeds')),
                          DropdownMenuItem(value: 4, child: Text('4 Feeds')),
                          DropdownMenuItem(value: 5, child: Text('5 Feeds')),
                        ],
                        onChanged: (value) => setState(() => blindStd = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                final newTankData = Tank(
                  id: tank?.id ?? '',
                  farmId: farmId,
                  name: nameController.text,
                  size: double.tryParse(sizeController.text),
                  stockingDate: selectedDate,
                  initialSeed: int.tryParse(seedController.text),
                  plSize: plSizeController.text,
                  checkTrays: tank?.checkTrays ?? 2,
                  blindWeek1: blindWeek1,
                  blindStd: blindStd,
                );

                if (isEditing) {
                  await context.read<TankProvider>().updateTank(newTankData);
                } else {
                  await context.read<TankProvider>().addTank(newTankData);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update Tank' : 'Save Tank'),
            ),
          ],
        );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String tankId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Tank?'),
        content: const Text(
          'Are you sure you want to delete this tank? All associated data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<TankProvider>().deleteTank(tankId);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFarmConfirmationDialog(BuildContext context, Farm farm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete ${farm.name}?'),
        content: const Text(
          'Are you sure you want to delete this farm? All associated tanks and data will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<FarmProvider>().deleteFarm(farm.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Farm'),
          ),
        ],
      ),
    );
  }
}

class TankDetailScreen extends StatefulWidget {
  final Tank tank;
  const TankDetailScreen({super.key, required this.tank});

  @override
  State<TankDetailScreen> createState() => _TankDetailScreenState();
}

class _TankDetailScreenState extends State<TankDetailScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<FeedProvider>().loadEntries(widget.tank.id);
    await context.read<HarvestProvider>().loadHarvests(widget.tank.id);
    await context.read<WaterQualityProvider>().loadEntries(widget.tank.id);
  }

  Widget _buildFeedChart(List<FeedEntry> entries) {
    if (entries.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No feed data available')),
      );
    }

    // Group entries by date and sum amounts
    final Map<String, double> dailyAmounts = {};
    for (var entry in entries) {
      final dateKey = AppDateUtils.getShortDate(entry.date);
      dailyAmounts[dateKey] = (dailyAmounts[dateKey] ?? 0) + entry.amount;
    }

    final maxAmount = dailyAmounts.values.isEmpty
        ? 10.0 // Default max Y if no data
        : dailyAmounts.values.reduce((a, b) => a > b ? a : b);
    final maxYValue = (maxAmount * 1.2).ceilToDouble();

    final spots = dailyAmounts.values.toList().asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxYValue / 5).ceilToDouble(),
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.gray200,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.gray200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) { 
                final index = value.toInt();
                if (index >= 0 && index < dailyAmounts.keys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dailyAmounts.keys.elementAt(index),
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxYValue / 5).ceilToDouble(),
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${value.toInt()}kg',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.gray200, width: 1),
        ),
        minX: 0, 
        maxX: (spots.length - 1).toDouble(),
        minY: 0,
        maxY: maxYValue,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();
    final harvestProvider = context.watch<HarvestProvider>();
    final waterQualityProvider = context.watch<WaterQualityProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.tank.name), 
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Logs'),
                Tab(text: 'Water'),
                Tab(text: 'Analytics'),
                Tab(text: 'Actions'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              isScrollable: true,
            ),
          ),
          body: TabBarView(
            children: [
              _buildOverviewTab(feedProvider, harvestProvider),
              _buildLogsTab(feedProvider),
              _buildWaterQualityTab(waterQualityProvider),
              _buildAnalyticsTab(),
              _buildActionsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(FeedProvider feedProvider, HarvestProvider harvestProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              StatCard(
                label: 'Biomass',
                value: '${widget.tank.biomass.toStringAsFixed(0)} kg',
                icon: Icons.scale,
                color: AppColors.primary,
              ),
              StatCard(
                label: 'FCR',
                value: '1.20',
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
              StatCard(
                label: 'DOC',
                value: '${widget.tank.doc}',
                icon: Icons.calendar_today,
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Feed History Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Feed History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildFeedChart(feedProvider.entries),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Health & Water Quality
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Health & Environment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Health Status',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Healthy',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab(FeedProvider feedProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feedProvider.entries.length,
      itemBuilder: (context, index) {
        final entry = feedProvider.entries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FeedEntryCard(
            entry: entry,
            onTap: () {},
            onEdit: () {},
          ),
        );
      },
    );
  }

  Widget _buildWaterQualityTab(WaterQualityProvider provider) {
    if (provider.entries.isEmpty) {
      return const Center(child: Text('No water quality logs yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.entries.length,
      itemBuilder: (context, index) {
        final entry = provider.entries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WaterQualityEntryCard(entry: entry),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return const Center(
      child: Text('Analytics coming soon...'),
    );
  }

  Widget _buildActionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedLogScreen(tankId: widget.tank.id),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Log Feed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WaterQualityLogScreen(tankId: widget.tank.id),
                  ),
                );
              },
              icon: const Icon(Icons.water_drop),
              label: const Text('Log Water Quality'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.medical_services),
              label: const Text('Log Application'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaterQualityLogScreen extends StatefulWidget {
  final String tankId;
  const WaterQualityLogScreen({super.key, required this.tankId});

  @override
  State<WaterQualityLogScreen> createState() => _WaterQualityLogScreenState();
}

class _WaterQualityLogScreenState extends State<WaterQualityLogScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  final _phController = TextEditingController();
  final _ammoniaController = TextEditingController();
  final _nitriteController = TextEditingController();
  final _salinityController = TextEditingController();
  final _tempController = TextEditingController();
  final _doController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _phController.dispose();
    _ammoniaController.dispose();
    _nitriteController.dispose();
    _salinityController.dispose();
    _tempController.dispose();
    _doController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Water Quality'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(AppDateUtils.getFormattedDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_phController, 'pH', 'e.g., 7.8')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_tempController, 'Temperature (°C)', 'e.g., 28.5')),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_ammoniaController, 'Ammonia (ppm)', 'e.g., 0.25')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_nitriteController, 'Nitrite (ppm)', 'e.g., 0.1')),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_salinityController, 'Salinity (ppt)', 'e.g., 15')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_doController, 'D.O. (ppm)', 'e.g., 5.5')),
            ]),
            const SizedBox(height: 16),
            TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveEntry, style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Save Water Log')),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) => TextFormField(controller: controller, decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true));

  void _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final entry = WaterQualityEntry(id: '', tankId: widget.tankId, date: _selectedDate, ph: double.tryParse(_phController.text), ammonia: double.tryParse(_ammoniaController.text), nitrite: double.tryParse(_nitriteController.text), salinity: double.tryParse(_salinityController.text), temperature: double.tryParse(_tempController.text), dissolvedOxygen: double.tryParse(_doController.text), notes: _notesController.text);
      await context.read<WaterQualityProvider>().addEntry(entry);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class FeedLogScreen extends StatefulWidget {
  final String? tankId;
  const FeedLogScreen({super.key, this.tankId});

  @override
  State<FeedLogScreen> createState() => _FeedLogScreenState();
}

class _FeedLogScreenState extends State<FeedLogScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTankId;
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();
  String _trayResult = 'pending';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedTankId = widget.tankId;
    _timeController.text = DateFormat('HH:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final tankProvider = context.watch<TankProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Feed'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.tankId == null)
              DropdownButtonFormField<String>(
                value: _selectedTankId,
                decoration: const InputDecoration(
                  labelText: 'Select Tank',
                  border: OutlineInputBorder(),
                ),
                items: tankProvider.tanks.map((t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(t.name),
                )).toList(),
                onChanged: (value) => setState(() => _selectedTankId = value),
                validator: (v) => v == null ? 'Please select a tank' : null,
              ),
            
            const SizedBox(height: 16),

            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(AppDateUtils.getFormattedDate(_selectedDate)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (kg)',
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null && context.mounted) {
                        _timeController.text = time.format(context);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _trayResult,
              decoration: const InputDecoration(
                labelText: 'Tray Observation',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending Check')),
                DropdownMenuItem(value: 'empty', child: Text('Empty (All Eaten)')),
                DropdownMenuItem(value: 'little', child: Text('Little Left')),
                DropdownMenuItem(value: 'half', child: Text('Half Left')),
                DropdownMenuItem(value: 'too-much', child: Text('Too Much Left')),
              ],
              onChanged: (v) => setState(() => _trayResult = v!),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && _selectedTankId != null) {
                  final entry = FeedEntry(
                    id: '', // Generated by DB
                    tankId: _selectedTankId!,
                    date: _selectedDate,
                    amount: double.parse(_amountController.text),
                    time: _timeController.text,
                    trayResult: _trayResult,
                  );
                  
                  await context.read<FeedProvider>().addEntry(entry);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Global analytics coming soon...'),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _pageIndex = index),
        children: const [
          HomeScreen(),
          FeedLogScreen(),
          AnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _pageIndex,
        onTap: (index) => _pageController.jumpToPage(index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray600,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Log Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Analytics'),
        ],
      ),
    );
  }
}

// ========== MAIN APP ==========
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://vwdzrzdvmgoqezatjhbr.supabase.co',
      anonKey: 'sb_publishable_z_5942T3HoGRt-eXcVcU5w_Isd3pDVz',
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => TankProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => WaterQualityProvider()),
        ChangeNotifierProvider(create: (_) => HarvestProvider()),
      ],
      child: MaterialApp(
        title: 'AquaRythu',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.success,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
          ),
        ),
        home: Consumer<AuthNotifier>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const MainScreen();
            }
            return LoginScreen();
          },
        ),
      ),
    );
  }
}