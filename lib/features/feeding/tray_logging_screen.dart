import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../tank/tank_model.dart';
import '../farm/farm_repository.dart';
import 'models/tray_log.dart';

class TrayLoggingScreen extends StatefulWidget {
  final Tank tank;
  final String feedLogId;

  const TrayLoggingScreen({
    super.key,
    required this.tank,
    required this.feedLogId,
  });

  @override
  State<TrayLoggingScreen> createState() => _TrayLoggingScreenState();
}

class _TrayLoggingScreenState extends State<TrayLoggingScreen> {
  final Map<int, TrayStatus> _trayStatuses = {};
  final _repository = FarmRepository();
  final _uuid = const Uuid();
  bool _isSaving = false;

  void _onStatusSelected(int trayNumber, TrayStatus status) {
    setState(() {
      _trayStatuses[trayNumber] = status;
    });
  }

  // LOGIC: Calculate weighted average score based on PRD Module 5
  double get _calculatedScore {
    if (_trayStatuses.isEmpty) return 0.0;
    double total = 0;
    for (var status in _trayStatuses.values) {
      switch (status) {
        case TrayStatus.completed: total += 1.0; break;
        case TrayStatus.littleLeft: total += 0.75; break;
        case TrayStatus.half: total += 0.5; break;
        case TrayStatus.tooMuch: total += 0.25; break;
      }
    }
    return total / _trayStatuses.length;
  }

  Future<void> _saveLogs() async {
    if (_trayStatuses.length != widget.tank.checkTrays) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log status for all trays.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final logs = _trayStatuses.entries.map((entry) {
        return TrayLog(
          id: _uuid.v4(),
          feedRoundId: widget.feedLogId, // Model might still use old name internally if not updated
          trayNumber: entry.key,
          status: entry.value,
        );
      }).toList();

      await _repository.createTrayChecks(logs);

      // UPDATE: Save the calculated score to the main feed log
      await Supabase.instance.client.from('feed_logs').update({
        'tray_score': _calculatedScore,
        'tray_status': _calculatedScore >= 0.85 ? 'Optimal' : 'Needs Adjustment', // Simple text status
      }).eq('id', widget.feedLogId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tray logs saved successfully!')),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving logs: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tank.name} - Tray Logging'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.tank.checkTrays,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final trayNumber = index + 1;
                      return _buildTrayCard(trayNumber);
                    },
                  ),
                ),
                // UI: Show live score calculation
                if (_trayStatuses.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Efficiency Score:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${(_calculatedScore * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _trayStatuses.length == widget.tank.checkTrays
                          ? _saveLogs
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Save Tray Logs'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTrayCard(int trayNumber) {
    final currentStatus = _trayStatuses[trayNumber];
    final isCompleted = currentStatus != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCompleted
            ? const BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tray #$trayNumber',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TrayStatus.values.map((status) {
                final isSelected = currentStatus == status;
                return ChoiceChip(
                  label: Text(status.label),
                  selected: isSelected,
                  onSelected: (_) => _onStatusSelected(trayNumber, status),
                  selectedColor: _getColorForStatus(status),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForStatus(TrayStatus status) {
    switch (status) {
      case TrayStatus.completed:
        return AppColors.success;
      case TrayStatus.littleLeft:
        return AppColors.info;
      case TrayStatus.half:
        return AppColors.warning;
      case TrayStatus.tooMuch:
        return AppColors.danger;
    }
  }
}