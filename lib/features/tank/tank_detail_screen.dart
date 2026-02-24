import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/date_utils.dart';
import '../feed/feed_entry_card.dart';
import '../../core/widgets/stat_card.dart';
import '../water/water_quality_entry_card.dart';
import '../feed/feed_model.dart';
import 'tank_model.dart';
import '../feed/feed_provider.dart';
import '../harvest/harvest_provider.dart';
import '../water/water_quality_provider.dart';
import '../feed/log_feed_screen.dart';
import '../water/log_water_quality_screen.dart';

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
                    builder: (_) => LogFeedScreen(tankId: widget.tank.id),
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
