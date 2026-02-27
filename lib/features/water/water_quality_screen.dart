import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/theme.dart';

class WaterQualityScreen extends StatefulWidget {
  final String tankId;
  final String tankName;

  const WaterQualityScreen({
    super.key,
    required this.tankId,
    required this.tankName,
  });

  @override
  State<WaterQualityScreen> createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers
  final _phController = TextEditingController();
  final _salinityController = TextEditingController();
  final _doController = TextEditingController(); // Dissolved Oxygen
  final _tempController = TextEditingController();
  final _ammoniaController = TextEditingController();
  final _alkalinityController = TextEditingController();

  @override
  void dispose() {
    _phController.dispose();
    _salinityController.dispose();
    _doController.dispose();
    _tempController.dispose();
    _ammoniaController.dispose();
    _alkalinityController.dispose();
    super.dispose();
  }

  Future<void> _saveWaterLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      await Supabase.instance.client.from('water_tests').insert({
        'tank_id': widget.tankId,
        'user_id': userId,
        'recorded_at': DateTime.now().toIso8601String(),
        'ph': double.tryParse(_phController.text),
        'salinity': double.tryParse(_salinityController.text),
        'dissolved_oxygen': double.tryParse(_doController.text),
        'temperature': double.tryParse(_tempController.text),
        'ammonia': double.tryParse(_ammoniaController.text),
        'alkalinity': double.tryParse(_alkalinityController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Water quality recorded successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Quality: ${widget.tankName}'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Parameters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gray800),
              ),
              const SizedBox(height: 16),
              _buildInput(_phController, 'pH Level', 'e.g. 7.5', (v) {
                final n = double.tryParse(v ?? '');
                if (n == null) return 'Required';
                if (n < 0 || n > 14) return 'Invalid pH (0-14)';
                return null;
              }),
              _buildInput(_salinityController, 'Salinity (ppt)', 'e.g. 15', (v) {
                 final n = double.tryParse(v ?? '');
                 if (n != null && n < 0) return 'Cannot be negative';
                 return null;
              }),
              _buildInput(_doController, 'Dissolved Oxygen (ppm)', 'e.g. 5.0', (v) {
                 final n = double.tryParse(v ?? '');
                 if (n != null && n < 0) return 'Cannot be negative';
                 return null;
              }),
              _buildInput(_tempController, 'Temperature (°C)', 'e.g. 28', null),
              const Divider(height: 32),
              const Text(
                'Toxicity Indicators',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gray800),
              ),
              const SizedBox(height: 16),
              _buildInput(_ammoniaController, 'Ammonia (ppm)', 'e.g. 0.1', null),
              _buildInput(_alkalinityController, 'Alkalinity (ppm)', 'e.g. 120', null),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveWaterLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Save Water Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller, 
    String label, 
    String hint, 
    String? Function(String?)? validator
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}