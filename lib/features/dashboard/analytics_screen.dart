import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../tank/tank_model.dart';
import '../feed/feed_provider.dart';
import '../harvest/harvest_provider.dart';
import '../tank/tank_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();
    final harvestProvider = context.watch<HarvestProvider>();
    final tankProvider = context.watch<TankProvider>();
    
    final totalFeed = feedProvider.entries.fold<double>(0, (sum, e) => sum + e.amount);
    final totalHarvest = harvestProvider.entries.fold<double>(0, (sum, e) => sum + e.weight);
    final avgFcr = totalHarvest > 0 ? totalFeed / totalHarvest : 0.0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Global Metrics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMetricCard('Total Feed Used', '${totalFeed.toStringAsFixed(2)} kg', AppColors.primary),
            const SizedBox(height: 12),
            _buildMetricCard('Total Harvest', '${totalHarvest.toStringAsFixed(2)} kg', AppColors.success),
            const SizedBox(height: 12),
            _buildMetricCard('Avg Feed Conversion Ratio', avgFcr.toStringAsFixed(2), AppColors.info),
            const SizedBox(height: 24),
            const Text('Active Tanks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTankList(tankProvider.tanks),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  Widget _buildTankList(List<Tank> tanks) {
    if (tanks.isEmpty) {
      return const Text('No tanks available', style: TextStyle(color: AppColors.gray600));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tanks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final tank = tanks[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: AppColors.gray300), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Expanded(child: Text(tank.name, style: const TextStyle(fontWeight: FontWeight.w500))),
            Text('Biomass: ${tank.biomass.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
          ]),
        );
      },
    );
  }
}
