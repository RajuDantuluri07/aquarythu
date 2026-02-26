import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/date_utils.dart';
import 'tank_model.dart';
import 'tank_provider.dart';

class TankDialog extends StatefulWidget {
  final String farmId;
  final Tank? tank;

  const TankDialog({super.key, required this.farmId, this.tank});

  @override
  State<TankDialog> createState() => _TankDialogState();
}

class _TankDialogState extends State<TankDialog> {
  late TextEditingController nameController;
  late TextEditingController sizeController;
  late TextEditingController seedController;
  late TextEditingController plSizeController;
  late DateTime selectedDate;
  late int blindWeek1;
  late int blindStd;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.tank?.name);
    sizeController = TextEditingController(text: widget.tank?.size?.toString());
    seedController = TextEditingController(text: widget.tank?.initialSeed?.toString());
    plSizeController = TextEditingController(text: widget.tank?.plSize);
    selectedDate = widget.tank?.stockingDate ?? DateTime.now();

    final initialBlindWeek1 = widget.tank?.blindWeek1;
    const validWeek1 = [2, 3, 4];
    blindWeek1 =
        (initialBlindWeek1 != null && validWeek1.contains(initialBlindWeek1)) ? initialBlindWeek1 : 2;

    final initialBlindStd = widget.tank?.blindStd;
    const validStd = [3, 4, 5];
    blindStd =
        (initialBlindStd != null && validStd.contains(initialBlindStd)) ? initialBlindStd : 4;
  }

  @override
  void dispose() {
    nameController.dispose();
    sizeController.dispose();
    seedController.dispose();
    plSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tank != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Tank' : 'Add New Tank'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tank Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: sizeController,
                    decoration: const InputDecoration(labelText: 'Area (acres)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: seedController,
                    decoration: const InputDecoration(labelText: 'Stocking Count'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: plSizeController,
                    decoration: const InputDecoration(labelText: 'PL Size'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Stocking Date'),
                      child: Text(AppDateUtils.getFormattedDate(selectedDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: blindWeek1,
                    decoration: const InputDecoration(labelText: 'Week 1 Feeds'),
                    items: const [
                      DropdownMenuItem(value: 2, child: Text('2 Feeds')),
                      DropdownMenuItem(value: 3, child: Text('3 Feeds')),
                      DropdownMenuItem(value: 4, child: Text('4 Feeds')),
                    ],
                    onChanged: (value) => setState(() => blindWeek1 = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: blindStd,
                    decoration: const InputDecoration(labelText: 'Standard Feeds'),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 Feeds')),
                      DropdownMenuItem(value: 4, child: Text('4 Feeds')),
                      DropdownMenuItem(value: 5, child: Text('5 Feeds')),
                    ],
                    onChanged: (value) => setState(() => blindStd = value!),
                  ),
                ),
              ],
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
            final newTankData = Tank(
              id: widget.tank?.id ?? '',
              farmId: widget.farmId,
              name: nameController.text,
              size: double.tryParse(sizeController.text),
              stockingDate: selectedDate,
              initialSeed: int.tryParse(seedController.text),
              plSize: plSizeController.text,
              blindWeek1: blindWeek1,
              blindStd: blindStd,
            );
            if (isEditing) {
              await context.read<TankProvider>().updateTank(newTankData);
            } else {
              await context.read<TankProvider>().addTank(newTankData);
            }
            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Update Tank' : 'Save Tank'),
        ),
      ],
    );
  }
}