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
import '../farm/blind_feed_schedule_screen.dart';
import '../farm/blind_feed_schedule_provider.dart';

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
    final feedProvider = context.read<FeedProvider>();
    final harvestProvider = context.read<HarvestProvider>();
    final waterQualityProvider = context.read<WaterQualityProvider>();

    await feedProvider.loadEntries(widget.tank.id);
    await harvestProvider.loadHarvests(widget.tank.id);
    await waterQualityProvider.loadEntries(widget.tank.id);
  }

  Widget _buildFeedChart(List<FeedEntry> entries) {
    if (entries.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No feed data available')),
      );
    }

    // Sort entries by date to ensure chart renders correctly
    final sortedEntries = List<FeedEntry>.from(entries)..sort((a, b) => a.date.compareTo(b.date));

    // Group entries by date and sum amounts
    final Map<String, double> dailyAmounts = {};
    for (var entry in sortedEntries) {
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
            return const FlLine(
              color: AppColors.gray200,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
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
                      style: const TextStyle(
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
                    style: const TextStyle(
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
            bottom: const TabBar(
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
              _buildAnalyticsTab(feedProvider, harvestProvider),
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
              const StatCard(
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

  Widget _buildAnalyticsTab(FeedProvider feedProvider, HarvestProvider harvestProvider) {
    final totalFeed = feedProvider.entries.fold<double>(0, (sum, e) => sum + e.amount);
    final totalHarvest = harvestProvider.entries.fold<double>(0, (sum, e) => sum + e.weight);
    final fcr = totalHarvest > 0 ? totalFeed / totalHarvest : 0.0;
    final avgDailyFeed = feedProvider.entries.isEmpty ? 0.0 : totalFeed / (feedProvider.entries.length.toDouble());
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tank Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard('Total Feed', '${totalFeed.toStringAsFixed(1)} kg', AppColors.primary),
              _buildStatCard('Harvest Weight', '${totalHarvest.toStringAsFixed(1)} kg', AppColors.success),
              _buildStatCard('FCR', fcr.toStringAsFixed(2), AppColors.info),
              _buildStatCard('Avg Daily Feed', '${avgDailyFeed.toStringAsFixed(1)} kg', AppColors.warning),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Feed Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFeedDistributionChart(feedProvider.entries),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  Widget _buildFeedDistributionChart(List<FeedEntry> entries) {
    if (entries.isEmpty) {
      return const SizedBox(height: 100, child: Center(child: Text('No feed data')));
    }
    final feedByType = <String, double>{};
    for (var entry in entries) {
      feedByType[entry.feedType] = (feedByType[entry.feedType] ?? 0) + entry.amount;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: AppColors.gray300), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: feedByType.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12))),
              Text('${e.value.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildActionsTab() {
    final isBlindFeeding = widget.tank.doc <= 30;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isBlindFeeding) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (_) => BlindFeedScheduleProvider()),
                        ],
                        child: BlindFeedScheduleScreen(tank: widget.tank),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.schedule),
                label: const Text('Blind Feed Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
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
