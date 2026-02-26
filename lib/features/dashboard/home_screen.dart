import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../tank/tank_card.dart';
import '../farm/farm_model.dart';
import '../tank/tank_model.dart';
import '../auth/auth_provider.dart';
import '../farm/farm_provider.dart';
import '../tank/tank_provider.dart';
import '../tank/tank_detail_screen.dart';
import '../tank/tank_dialog.dart';
import '../farm/add_farm_dialog.dart';
import '../farm/edit_farm_dialog.dart';

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
      try {
        final farmProvider = context.read<FarmProvider>();
        // Only load if farms list is empty (not already loaded)
        if (farmProvider.farms.isEmpty) {
          await farmProvider.loadFarms(auth.user!.id);
        }
        
        if (context.mounted) {
          final updatedFarmProvider = context.read<FarmProvider>();
          if (updatedFarmProvider.currentFarm != null) {
            await context.read<TankProvider>().loadTanks(updatedFarmProvider.currentFarm!.id);
          }
        }
      } catch (e) {
        debugPrint('Error loading data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = context.watch<FarmProvider>();
    final tankProvider = context.watch<TankProvider>();
    final feedProvider = context.watch<FeedProvider>();

    // Calculate global feed metrics
    final totalBiomass = tankProvider.tanks.fold<double>(0, (sum, tank) => sum + tank.biomass);
    final totalFeedToday = feedProvider.entries
        .where((entry) => 
          entry.date.day == DateTime.now().day &&
          entry.date.month == DateTime.now().month &&
          entry.date.year == DateTime.now().year)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final totalFeedAllTime = feedProvider.entries.fold<double>(0, (sum, entry) => sum + entry.amount);

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
                  decoration: const BoxDecoration(
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
                                const Icon(Icons.agriculture, color: Colors.white, size: 18),
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
                        child: const Icon(Icons.agriculture, size: 40, color: AppColors.primary),
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
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: AppColors.warningDark, size: 20),
                            SizedBox(width: 8),
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
                            child: const Icon(Icons.agriculture, color: AppColors.primary),
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
                                  style: const TextStyle(color: AppColors.gray600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: AppColors.gray600),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.gray600),
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
                        icon: const Icon(Icons.compare_arrows, size: 18),
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
                            const Expanded(
                              child: StatCard(
                                label: 'Feed Consumed',
                                value: '0 kg',
                                icon: Icons.food_bank,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
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
                            const Expanded(
                              child: StatCard(
                                label: 'Feed Today',
                                value: '0 kg',
                                icon: Icons.today,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
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

                    // Tanks Section
                    SectionHeader(
                      title: 'Tanks',
                      icon: Icons.water,
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        onPressed: () {
                          // The method `_showTankDialog` already handles both adding and editing.
                          // We call it without the `tank` parameter to add a new one.
                          if (farmProvider.currentFarm != null) {
                            _showTankDialog(
                                context, farmProvider.currentFarm!.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a farm first.'),
                              ),
                            );
                          }
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
                  ListView.builder(
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
                                    _showEditFarmDialog(context, farm); // This calls the method below which uses EditFarmDialog
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
    showDialog(
      context: context,
      builder: (context) => const AddFarmDialog(),
    );
  }

  void _showEditFarmDialog(BuildContext context, Farm farm) {
    showDialog(
      context: context,
      builder: (context) => EditFarmDialog(farm: farm),
    );
  }

  void _showTankDialog(BuildContext context, String farmId, {Tank? tank}) {
    showDialog(
      context: context,
      builder: (context) => TankDialog(farmId: farmId, tank: tank),
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
