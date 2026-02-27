import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme.dart';
import 'feed_model.dart';

class FeedEntryCard extends StatelessWidget {
  final FeedEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete; // Changed from onEdit to onDelete to match usage

  const FeedEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete, // Changed from onEdit to onDelete
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
          '${entry.feedQuantity} kg - ${entry.feedType}', // Changed amount to feedQuantity
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Changed date to executedAt with null check
            Text(entry.executedAt != null 
                ? DateFormat('MMM d, yyyy - h:mm a').format(entry.executedAt!)
                : 'Date not set'),
            if (entry.mixInstructions.isNotEmpty)
              Text(
                'Note: ${entry.mixInstructions}',
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            // Add tray status if available
            if (entry.trayStatus != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(entry.trayStatus!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tray: ${entry.trayStatus!.replaceAll('_', ' ')}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray400),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'little_left':
        return Colors.orange;
      case 'half':
        return Colors.amber;
      case 'too_much':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}