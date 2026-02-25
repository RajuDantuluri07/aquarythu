import 'package:flutter/material.dart';

import 'water_quality_model.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/date_utils.dart';

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
            style: const TextStyle(
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
            const Text(
              'Notes:',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gray600),
            ),
            const SizedBox(height: 4),
            Text(entry.notes!, style: const TextStyle(color: AppColors.gray700)),
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
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray900)),
      ],
    );
  }
}
