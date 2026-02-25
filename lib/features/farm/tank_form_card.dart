import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../tank/tank_model.dart';

class TankFormCard extends StatefulWidget {
  final int tankIndex;
  final Tank tank;
  final ValueChanged<Tank> onChanged;
  final VoidCallback onRemove;

  const TankFormCard({
    super.key,
    required this.tankIndex,
    required this.tank,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<TankFormCard> createState() => _TankFormCardState();
}

class _TankFormCardState extends State<TankFormCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _sizeController;
  late final TextEditingController _seedController;
  late final TextEditingController _plSizeController;
  late DateTime _stockingDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tank.name);
    _sizeController = TextEditingController(text: widget.tank.size?.toString() ?? '');
    _seedController = TextEditingController(text: widget.tank.initialSeed?.toString() ?? '');
    _plSizeController = TextEditingController(text: widget.tank.plSize ?? '');
    _stockingDate = widget.tank.stockingDate ?? DateTime.now();

    _nameController.addListener(_onChanged);
    _sizeController.addListener(_onChanged);
    _seedController.addListener(_onChanged);
    _plSizeController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onChanged);
    _sizeController.removeListener(_onChanged);
    _seedController.removeListener(_onChanged);
    _plSizeController.removeListener(_onChanged);
    _nameController.dispose();
    _sizeController.dispose();
    _seedController.dispose();
    _plSizeController.dispose();
    super.dispose();
  }

  void _onChanged() {
    widget.onChanged(
      widget.tank.copyWith(
        name: _nameController.text,
        size: double.tryParse(_sizeController.text),
        initialSeed: int.tryParse(_seedController.text),
        plSize: _plSizeController.text,
        stockingDate: _stockingDate,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _stockingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _stockingDate) {
      setState(() {
        _stockingDate = picked;
      });
      _onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tank ${widget.tankIndex + 1}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove Tank',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tank Name / Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeController,
                    decoration: const InputDecoration(
                      labelText: 'Area (acres)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _seedController,
                    decoration: const InputDecoration(
                      labelText: 'Stocking Count',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _plSizeController,
              decoration: const InputDecoration(
                labelText: 'PL Size',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Stocking Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat.yMMMd().format(_stockingDate)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}