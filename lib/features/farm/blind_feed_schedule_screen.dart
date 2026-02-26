import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../tank/tank_model.dart';
import 'blind_feed_schedule.dart';
import 'blind_feed_schedule_provider.dart';

class BlindFeedScheduleScreen extends StatefulWidget {
  final Tank tank;

  const BlindFeedScheduleScreen({
    super.key,
    required this.tank,
  });

  @override
  State<BlindFeedScheduleScreen> createState() => _BlindFeedScheduleScreenState();
}

class _BlindFeedScheduleScreenState extends State<BlindFeedScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlindFeedScheduleProvider>().loadSchedules(widget.tank.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BlindFeedScheduleProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tank.name} - Blind Feed (DOC 1-30)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.schedules.isEmpty
              ? const Center(child: Text('No blind feed schedules'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          border: Border.all(color: AppColors.info),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tank: ${widget.tank.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              'Stocking: ${widget.tank.initialSeed ?? 0} | Area: ${widget.tank.size ?? 0} acres',
                              style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                            ),
                            const SizedBox(height: 6),
                            const Text('Tap to edit feed & type', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.schedules.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, index) => _buildScheduleCard(context, provider, provider.schedules[index]),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, BlindFeedScheduleProvider provider, BlindFeedSchedule schedule) {
    return GestureDetector(
      onTap: () => _showEditDialog(context, provider, schedule),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('DOC ${schedule.dayOfCulture}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schedule.feedType, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('${schedule.dailyFeedAmount.toStringAsFixed(2)} kg', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, size: 18, color: AppColors.gray600),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, BlindFeedScheduleProvider provider, BlindFeedSchedule schedule) {
    final feedController = TextEditingController(text: schedule.dailyFeedAmount.toStringAsFixed(2));
    String selectedFeedType = schedule.feedType;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit DOC ${schedule.dayOfCulture}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: feedController,
              decoration: const InputDecoration(labelText: 'Daily Feed (kg)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedFeedType,
              decoration: const InputDecoration(labelText: 'Feed Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Starter 1', child: Text('Starter 1')),
                DropdownMenuItem(value: 'Starter 2', child: Text('Starter 2')),
                DropdownMenuItem(value: 'Grower 1', child: Text('Grower 1')),
                DropdownMenuItem(value: 'Grower 2', child: Text('Grower 2')),
              ],
              onChanged: (v) => selectedFeedType = v ?? schedule.feedType,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.updateSchedule(schedule.copyWith(
                  dailyFeedAmount: double.tryParse(feedController.text) ?? schedule.dailyFeedAmount,
                  feedType: selectedFeedType,
                ));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}