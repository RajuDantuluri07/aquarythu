import 'package:flutter/material.dart';
import '../dashboard/pond.dart';

class PondFormCard extends StatelessWidget {
  final int pondIndex;
  final Pond pond;
  final ValueChanged<Pond> onChanged;
  final VoidCallback onRemove;

  const PondFormCard({
    Key? key,
    required this.pondIndex,
    required this.pond,
    required this.onChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pond ${pondIndex + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: pond.name,
              decoration: const InputDecoration(labelText: 'Pond Name'),
              onChanged: (value) {
                onChanged(pond.copyWith(name: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}