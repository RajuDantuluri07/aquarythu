import 'package:flutter/material.dart';

import 'feed_model.dart';
import '../../core/theme/theme.dart';

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

  Color get _statusColor {
    switch (entry.trayResult) {
      case 'empty': return AppColors.success;
      case 'little': return AppColors.info;
      case 'half': return AppColors.warning;
      case 'too-much': return AppColors.danger;
      case 'pending': return AppColors.warning;
      default: return AppColors.gray500;
    }
  }

  String get _statusText {
    switch (entry.trayResult) {
      case 'empty': return 'Empty';
      case 'little': return 'Little Left';
      case 'half': return 'Half Left';
      case 'too-much': return 'Too Much';
      case 'pending': return 'Pending';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${entry.amount.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '@ ${entry.time ?? '--:--'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    if (entry.supplements != null && entry.supplements!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: entry.supplements!.map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: Icon(Icons.edit, size: 18, color: AppColors.gray500),
                    onPressed: onEdit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}