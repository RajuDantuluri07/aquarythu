import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'blind_feed_schedule.dart';
import 'farm_repository.dart';

class BlindFeedScheduleScreen extends StatefulWidget {
  final String pondId;
  final String pondName;

  const BlindFeedScheduleScreen({
    super.key,
    required this.pondId,
    required this.pondName,
  });

  @override
  State<BlindFeedScheduleScreen> createState() => _BlindFeedScheduleScreenState();
}

class _BlindFeedScheduleScreenState extends State<BlindFeedScheduleScreen> {
  late Future<List<BlindFeedSchedule>> _scheduleFuture;
  final _repository = FarmRepository();

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _repository.getBlindFeedSchedule(widget.pondId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pondName} - Blind Feeding'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<BlindFeedSchedule>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No schedule found for this pond.\n(Only available for DOC 1-30)',
                textAlign: TextAlign.center,
              ),
            );
          }

          final schedule = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: schedule.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = schedule[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    '${item.dayOfCulture}',
                    style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text('DOC ${item.dayOfCulture}'),
                subtitle: Text('Feed Type: ${item.feedType}'),
                trailing: Text(
                  '${item.dailyFeedAmount.toStringAsFixed(2)} kg',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}