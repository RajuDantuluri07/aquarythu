import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import 'farm_repository.dart';
import 'feed_round.dart';
import '../feeding/tray_logging_screen.dart';
import '../tank/tank_model.dart';

class PendingFeedRoundsList extends StatefulWidget {
  const PendingFeedRoundsList({super.key});

  @override
  State<PendingFeedRoundsList> createState() => _PendingFeedRoundsListState();
}

class _PendingFeedRoundsListState extends State<PendingFeedRoundsList> {
  final _repository = FarmRepository();
  late Future<List<({FeedLog round, Tank tank})>> _pendingRoundsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _pendingRoundsFuture = _repository.getPendingFeedLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Feed Rounds',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                onPressed: _refresh,
              ),
            ],
          ),
        ),
        FutureBuilder<List<({FeedLog round, Tank tank})>>(
          future: _pendingRoundsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ));
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading rounds: ${snapshot.error}', style: const TextStyle(color: AppColors.danger)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No pending feed rounds. Good job!', style: TextStyle(color: AppColors.gray600)),
              );
            }

            final rounds = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rounds.length,
              itemBuilder: (context, index) {
                final item = rounds[index];
                return _buildFeedRoundCard(context, item.round, item.tank);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeedRoundCard(BuildContext context, FeedLog round, Tank tank) {
    final timeFormat = DateFormat.jm();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: AppColors.warning.withOpacity(0.2),
          child: const Icon(Icons.access_time, color: AppColors.warning),
        ),
        title: Text(
          tank.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Scheduled: ${timeFormat.format(round.scheduledAt)}'),
            Text('Feed: ${round.feedQuantity}kg (${round.feedType})'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrayLoggingScreen(
                  tank: tank,
                  feedLogId: round.id,
                ),
              ),
            );
            _refresh(); // Refresh list after returning from logging
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Log Trays'),
        ),
      ),
    );
  }
}