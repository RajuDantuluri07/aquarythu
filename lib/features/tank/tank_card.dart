import 'package:flutter/material.dart';

import 'tank_model.dart';
import '../../core/theme/theme.dart';

class TankCard extends StatelessWidget {
  final Tank tank;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TankCard({
    super.key,
    required this.tank,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    if (tank.doc > 75) return AppColors.danger;
    if (tank.doc > 50) return AppColors.warning;
    return AppColors.success;
  }

  String get _phaseLabel {
    if (tank.doc <= 3) return 'Phase 1 · Stocking';
    if (tank.doc <= 15) return 'Phase 2 · Stabilisation';
    if (tank.doc <= 30) return 'Phase 3 · Biomass';
    return '';
  }

  String get _trayPhaseLabel {
    if (tank.status == 'inactive') return '';
    if (tank.doc <= tank.blindDuration && !tank.hasTransitionedFromBlind) {
      return 'Blind Feed Mode';
    } else if (tank.doc > tank.blindDuration && !tank.hasTransitionedFromBlind) {
      return 'Tray Training';
    } else if (tank.hasTransitionedFromBlind) {
      return 'Tray Active';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.gray200),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.water_drop, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tank.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900,
                                ),
                              ),
                              if (_phaseLabel.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _phaseLabel,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DOC ${tank.doc}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: AppColors.gray600),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Tank'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: AppColors.danger),
                              SizedBox(width: 8),
                              Text('Delete Tank', style: TextStyle(color: AppColors.danger)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem('Size', '${tank.size ?? '-'} ac'),
                        ),
                        Expanded(
                          child: _buildInfoItem('Stock', '${tank.initialSeed ?? 0}'),
                        ),
                        Expanded(
                          child: _buildInfoItem('Trays', '${tank.checkTrays}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem('Feed Today', '${tank.biomass.toStringAsFixed(1)} kg'),
                        ),
                        Expanded(
                          child: _buildStatItem('Total Feed', '${tank.biomass.toStringAsFixed(1)} kg'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.gray200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.scale, size: 14, color: AppColors.gray500),
                                const SizedBox(width: 4),
                                Text(
                                  'Biomass: ${tank.biomass.toStringAsFixed(0)} kg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.trending_up, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'FCR: 1.2',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_trayPhaseLabel.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.infoLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _trayPhaseLabel,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.info,
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
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}