import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/date_utils.dart';
import 'water_quality_model.dart';
import 'water_quality_provider.dart';

class WaterQualityLogScreen extends StatefulWidget {
  final String tankId;
  const WaterQualityLogScreen({super.key, required this.tankId});

  @override
  State<WaterQualityLogScreen> createState() => _WaterQualityLogScreenState();
}

class _WaterQualityLogScreenState extends State<WaterQualityLogScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  final _phController = TextEditingController();
  final _ammoniaController = TextEditingController();
  final _nitriteController = TextEditingController();
  final _salinityController = TextEditingController();
  final _tempController = TextEditingController();
  final _doController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _phController.dispose();
    _ammoniaController.dispose();
    _nitriteController.dispose();
    _salinityController.dispose();
    _tempController.dispose();
    _doController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Water Quality'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(AppDateUtils.getFormattedDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_phController, 'pH', 'e.g., 7.8')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_tempController, 'Temperature (°C)', 'e.g., 28.5')),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_ammoniaController, 'Ammonia (ppm)', 'e.g., 0.25')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_nitriteController, 'Nitrite (ppm)', 'e.g., 0.1')),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_salinityController, 'Salinity (ppt)', 'e.g., 15')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_doController, 'D.O. (ppm)', 'e.g., 5.5')),
            ]),
            const SizedBox(height: 16),
            TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveEntry, style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Save Water Log')),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) => TextFormField(controller: controller, decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true));

  void _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final entry = WaterQualityEntry(id: '', tankId: widget.tankId, date: _selectedDate, ph: double.tryParse(_phController.text), ammonia: double.tryParse(_ammoniaController.text), nitrite: double.tryParse(_nitriteController.text), salinity: double.tryParse(_salinityController.text), temperature: double.tryParse(_tempController.text), dissolvedOxygen: double.tryParse(_doController.text), notes: _notesController.text);
      
      final waterQualityProvider = context.read<WaterQualityProvider>();
      await waterQualityProvider.addEntry(entry);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
