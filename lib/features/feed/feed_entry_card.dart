import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme.dart';
import 'feed_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: const Icon(Icons.restaurant, color: AppColors.primary),
        ),
        title: Text(
          '${entry.amount} kg - ${entry.feedType}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(DateFormat('MMM d, yyyy - h:mm a').format(entry.date)),
            if (entry.mixInstructions.isNotEmpty)
              Text(
                'Note: ${entry.mixInstructions}',
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
        onTap: onTap,
      ),
    );
  }
}