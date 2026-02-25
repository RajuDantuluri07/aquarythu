import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../auth/auth_provider.dart';
import 'farm_setup_provider.dart';
import 'widgets/pond_form_card.dart';

class FarmSetupScreen extends StatelessWidget {
  const FarmSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FarmSetupNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Farm Setup'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Consumer<FarmSetupNotifier>(
          builder: (context, notifier, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Farm Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: notifier.updateFarmName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifier.ponds.length,
                    itemBuilder: (context, index) {
                      final pond = notifier.ponds[index];
                      return PondFormCard(
                        key: ValueKey(pond.id), // Use temporary ID as key
                        pondIndex: index,
                        pond: pond,
                        onChanged: (updatedPond) => notifier.updatePond(index, updatedPond),
                        onRemove: () => notifier.removePond(index),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: notifier.addPond,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Pond'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      final auth = context.read<AuthNotifier>();
                      final userId = auth.user?.id;

                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You must be logged in to save a farm.')),
                        );
                        return;
                      }

                      try {
                        await notifier.saveFarm(userId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Farm saved successfully!')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving farm: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Save Farm & Ponds'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}