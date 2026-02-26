import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../auth/auth_provider.dart';
import '../tank/tank_provider.dart';
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
              try {
                await context.read<FarmProvider>().addFarm(
                      auth.user!.id,
                      nameController.text,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  _showAddTankFollowUp(context);
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

  void _showAddTankFollowUp(BuildContext context) {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Click the "+" button on your farm card to add a tank')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add Tank', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}