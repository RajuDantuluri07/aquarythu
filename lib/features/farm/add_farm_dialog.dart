import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../auth/auth_provider.dart';
import '../tank/tank_dialog.dart';
import '../tank/tank_model.dart';
import 'farm_provider.dart';

class AddFarmDialog extends StatefulWidget {
  const AddFarmDialog({super.key});

  @override
  State<AddFarmDialog> createState() => _AddFarmDialogState();
}

class _AddFarmDialogState extends State<AddFarmDialog> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Farm'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Farm Name',
                hintText: 'e.g., Shree Shrimp Farm',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isNotEmpty) {
              final auth = context.read<AuthNotifier>();
              final farmProvider = context.read<FarmProvider>();
              try {
                await farmProvider.addFarm(
                  auth.user!.id,
                  nameController.text,
                );
                if (context.mounted) {
                  final newFarmId = farmProvider.currentFarm?.id;
                  Navigator.pop(context);
                  if (newFarmId != null) {
                    _showAddTankFollowUp(context, newFarmId);
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding farm: $e')),
                  );
                }
              }
            }
          },
          child: const Text('Save Farm'),
        ),
      ],
    );
  }

  void _showAddTankFollowUp(BuildContext context, String farmId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Farm Created! 🎉'),
        content: const Text(
          'Now set up your first tank to start tracking feeds and growth.\n\nTank setup takes just 2 minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip for Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showTankDialog(context, farmId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add Tank', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTankDialog(BuildContext context, String farmId, {Tank? tank}) {
    showDialog(
      context: context,
      builder: (context) => TankDialog(farmId: farmId, tank: tank),
    );
  }
}