import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'farm_model.dart';
import 'farm_provider.dart';

class EditFarmDialog extends StatefulWidget {
  final Farm farm;
  const EditFarmDialog({super.key, required this.farm});

  @override
  State<EditFarmDialog> createState() => _EditFarmDialogState();
}

class _EditFarmDialogState extends State<EditFarmDialog> {
  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController contactController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.farm.name);
    locationController = TextEditingController(text: widget.farm.location);
    contactController = TextEditingController(text: widget.farm.contact);
    phoneController = TextEditingController(text: widget.farm.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    contactController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Farm'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Farm Name')),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
            TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact Person')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final updatedFarm = Farm(
              id: widget.farm.id,
              name: nameController.text,
              location: locationController.text,
              contact: contactController.text,
              phone: phoneController.text,
            );
            await context.read<FarmProvider>().updateFarm(updatedFarm);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}