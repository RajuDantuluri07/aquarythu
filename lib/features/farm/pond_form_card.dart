import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../dashboard/pond.dart';

class PondFormCard extends StatefulWidget {
  final int pondIndex;
  final Pond pond;
  final ValueChanged<Pond> onChanged;
  final VoidCallback onRemove;

  const PondFormCard({
    super.key,
    required this.pondIndex,
    required this.pond,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<PondFormCard> createState() => _PondFormCardState();
}

class _PondFormCardState extends State<PondFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _acreSizeController;
  late final TextEditingController _stockingCountController;
  late final TextEditingController _plPerM2Controller;
  late final TextEditingController _numberOfTraysController;
  late final TextEditingController _aerationHpController;
  late final TextEditingController _waterSourceController;
  late DateTime _stockingDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pond.name);
    _acreSizeController = TextEditingController(text: widget.pond.acreSize > 0 ? widget.pond.acreSize.toString() : '');
    _stockingCountController = TextEditingController(text: widget.pond.stockingCount > 0 ? widget.pond.stockingCount.toString() : '');
    _plPerM2Controller = TextEditingController(text: widget.pond.plPerM2 > 0 ? widget.pond.plPerM2.toString() : '');
    _numberOfTraysController = TextEditingController(text: widget.pond.numberOfTrays > 0 ? widget.pond.numberOfTrays.toString() : '');
    _aerationHpController = TextEditingController(text: widget.pond.aerationHp > 0 ? widget.pond.aerationHp.toString() : '');
    _waterSourceController = TextEditingController(text: widget.pond.waterSource);
    _stockingDate = widget.pond.stockingDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _acreSizeController.dispose();
    _stockingCountController.dispose();
    _plPerM2Controller.dispose();
    _numberOfTraysController.dispose();
    _aerationHpController.dispose();
    _waterSourceController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    final updatedPond = widget.pond.copyWith(
      name: _nameController.text,
      acreSize: double.tryParse(_acreSizeController.text) ?? 0.0,
      stockingCount: int.tryParse(_stockingCountController.text) ?? 0,
      plPerM2: int.tryParse(_plPerM2Controller.text) ?? 0,
      stockingDate: _stockingDate,
      numberOfTrays: int.tryParse(_numberOfTraysController.text) ?? 0,
      aerationHp: double.tryParse(_aerationHpController.text) ?? 0.0,
      waterSource: _waterSourceController.text,
    );
    widget.onChanged(updatedPond);
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
      _handleChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _handleChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pond ${widget.pondIndex + 1}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                  if (widget.pondIndex > 0)
                    IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.danger), onPressed: widget.onRemove),
                ],
              ),
              const Divider(height: 24),
              _buildTextField(controller: _nameController, label: 'Pond Name'),
              const SizedBox(height: 12),
              _buildTextField(controller: _acreSizeController, label: 'Acre Size', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(controller: _stockingCountController, label: 'Stocking Count', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(controller: _plPerM2Controller, label: 'PL per m²', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(controller: _numberOfTraysController, label: 'Number of Trays', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(controller: _aerationHpController, label: 'Aeration HP', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(controller: _waterSourceController, label: 'Water Source'),
              const SizedBox(height: 12),
              _buildDateField(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      keyboardType: keyboardType,
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildDateField(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Stocking Date',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMMMd().format(_stockingDate)),
            const Icon(Icons.calendar_today, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}