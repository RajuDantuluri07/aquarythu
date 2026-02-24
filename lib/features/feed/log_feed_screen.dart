import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/date_utils.dart';
import '../tank/tank_model.dart';
import '../tank/tank_provider.dart';
import 'feed_model.dart';
import 'feed_provider.dart';

enum FeedMode { blind, tray }

class LogFeedScreen extends StatefulWidget {
  final String? tankId;
  const LogFeedScreen({super.key, this.tankId});

  @override
  State<LogFeedScreen> createState() => _LogFeedScreenState();
}

class _LogFeedScreenState extends State<LogFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTankId;
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();
  String _trayResult = 'empty'; // Default to best case
  DateTime _selectedDate = DateTime.now();
  FeedMode _mode = FeedMode.blind;
  
  // State for supplements
  final List<String> _availableSupplements = ['Probiotics', 'Minerals', 'Binder', 'Vitamin C', 'Gut Pro'];
  final List<String> _selectedSupplements = [];

  @override
  void initState() {
    super.initState();
    _selectedTankId = widget.tankId;
    _timeController.text = DateFormat('HH:mm').format(DateTime.now());
    
    // Auto-detect mode based on tank DOC if tank is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.tankId != null) {
        final tank = context.read<TankProvider>().tanks.firstWhere((t) => t.id == widget.tankId);
        setState(() {
          _mode = (tank.doc > tank.blindDuration) ? FeedMode.tray : FeedMode.blind;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tankProvider = context.watch<TankProvider>();
    final tank = _selectedTankId != null 
        ? tankProvider.tanks.firstWhere((t) => t.id == _selectedTankId, orElse: () => tankProvider.tanks.first)
        : null;
    
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: const Text("Log Feed"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        actions: [
          if (tank != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray300),
              ),
              child: ToggleButtons(
                isSelected: [_mode == FeedMode.blind, _mode == FeedMode.tray],
                onPressed: (index) {
                  setState(() {
                    _mode = index == 0 ? FeedMode.blind : FeedMode.tray;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: AppColors.primary,
                color: AppColors.gray600,
                constraints: const BoxConstraints(minHeight: 36, minWidth: 60),
                children: const [
                  Text("Blind", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  Text("Tray", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Tank Selector (if not passed)
            if (widget.tankId == null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: _selectedTankId,
                  decoration: const InputDecoration(
                    labelText: 'Select Tank',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: tankProvider.tanks.map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Text(t.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTankId = value;
                      // Auto switch mode based on new tank
                      final t = tankProvider.tanks.firstWhere((t) => t.id == value);
                      _mode = (t.doc > t.blindDuration) ? FeedMode.tray : FeedMode.blind;
                    });
                  },
                ),
              ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedTankId == null 
                  ? const Center(child: Text("Please select a tank"))
                  : _mode == FeedMode.blind
                    ? _buildBlindFeed(tank!)
                    : _buildTrayFeed(tank!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BLIND FEED ----------------

  Widget _buildBlindFeed(Tank tank) {
    // Calculate rough schedule based on tank settings
    final feedsPerDay = tank.blindStd; 
    final times = ['06:00', '10:00', '14:00', '18:00', '22:00'];
    final displayTimes = times.take(feedsPerDay).toList();
    
    // Calculate amount per feed (simple logic: biomass * 5% / feeds)
    // In real app, this would be more complex
    final dailyFeed = tank.biomass > 0 ? tank.biomass * 0.05 : 2.0;
    final perFeed = dailyFeed / feedsPerDay;

    return ListView(
      key: const ValueKey("blind"),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Day ${tank.doc} Plan",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Blind Phase",
                        style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Total Target: ${dailyFeed.toStringAsFixed(1)} kg",
                  style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Based on ${tank.initialSeed} stock count",
                  style: TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text("Schedule", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray600)),
        const SizedBox(height: 10),
        ...displayTimes.map((time) => _feedTile(time, perFeed)),
      ],
    );
  }

  Widget _feedTile(String time, double kg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.access_time, color: AppColors.primary, size: 20),
        ),
        title: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("${kg.toStringAsFixed(2)} kg recommended"),
        trailing: ElevatedButton(
          onPressed: () {
            _amountController.text = kg.toStringAsFixed(2);
            _timeController.text = time;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Feed'),
                content: Text('Log ${kg.toStringAsFixed(2)} kg for $time?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitFeed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: const Text("Log"),
        ),
      ),
    );
  }

  // ---------------- TRAY FEED ----------------

  Widget _buildTrayFeed(Tank tank) {
    final feedProvider = context.watch<FeedProvider>();
    // Get last feed for context
    final lastFeed = feedProvider.entries.isNotEmpty ? feedProvider.entries.first : null;

    double? suggestedAmount;
    String? suggestionReason;
    Color? suggestionColor;
    Color? suggestionLightColor;
    IconData? suggestionIcon;

    if (lastFeed != null) {
      final lastAmount = lastFeed.amount;
      final lastTrayResult = lastFeed.trayResult;

      if (lastTrayResult == 'empty') {
        suggestedAmount = lastAmount * 1.10;
        suggestionReason = "Last tray was empty. (+10%)";
        suggestionColor = AppColors.success;
        suggestionLightColor = AppColors.successLight;
        suggestionIcon = Icons.arrow_upward_rounded;
      } else if (lastTrayResult == 'too-much') {
        suggestedAmount = lastAmount * 0.90;
        suggestionReason = "Last tray was full. (-10%)";
        suggestionColor = AppColors.danger;
        suggestionLightColor = AppColors.dangerLight;
        suggestionIcon = Icons.arrow_downward_rounded;
      } else if (lastTrayResult == 'little') {
        suggestedAmount = lastAmount;
        suggestionReason = "Last tray had little left. (No change)";
        suggestionColor = AppColors.info;
        suggestionLightColor = AppColors.infoLight;
        suggestionIcon = Icons.horizontal_rule_rounded;
      }
    }

    return SingleChildScrollView(
      key: const ValueKey("tray"),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last Feed Context Card
          if (lastFeed != null)
            Card(
              elevation: 0,
              color: AppColors.infoLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: AppColors.info),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Last Feed", style: TextStyle(fontSize: 12, color: AppColors.info)),
                        Text(
                          "${lastFeed.amount}kg @ ${lastFeed.time}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gray900),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lastFeed.trayResult?.toUpperCase() ?? '-',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Suggestion Card
          if (suggestedAmount != null) ...[
            const SizedBox(height: 24),
            const Text("Next Feed Suggestion", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                _amountController.text = suggestedAmount!.toStringAsFixed(2);
              },
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 0,
                color: suggestionLightColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: suggestionColor!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(suggestionIcon, color: suggestionColor, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${suggestedAmount.toStringAsFixed(2)} kg",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: suggestionColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              suggestionReason!,
                              style: TextStyle(color: suggestionColor.withOpacity(0.8), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.touch_app_outlined, color: AppColors.gray500),
                    ],
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // 1. Amount Input
          const Text("Feed Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: "0.0",
              suffixText: "kg",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),

          const SizedBox(height: 24),

          // 2. Tray Status Selector
          const Text("Check Tray Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _trayStatusButton("Empty", "empty", AppColors.success)),
              const SizedBox(width: 8),
              Expanded(child: _trayStatusButton("Little", "little", AppColors.warning)),
              const SizedBox(width: 8),
              Expanded(child: _trayStatusButton("Full", "too-much", AppColors.danger)),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Supplements
          const Text("Supplements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSupplements.map((s) {
              final isSelected = _selectedSupplements.contains(s);
              return FilterChip(
                label: Text(s),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSupplements.add(s);
                    } else {
                      _selectedSupplements.remove(s);
                    }
                  });
                },
                selectedColor: AppColors.primaryLight,
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.gray700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.gray300),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitFeed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: const Text(
                "LOG FEED ENTRY",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trayStatusButton(String label, String value, Color color) {
    final isSelected = _trayResult == value;
    return GestureDetector(
      onTap: () => setState(() => _trayResult = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Column(
          children: [
            Icon(
              value == 'empty' ? Icons.check_circle_outline : 
              value == 'little' ? Icons.remove_circle_outline : Icons.cancel_outlined,
              color: isSelected ? Colors.white : color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.gray700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeed() async {
    if (_formKey.currentState!.validate() && _selectedTankId != null) {
      final entry = FeedEntry(
        id: '', // Generated by DB
        tankId: _selectedTankId!,
        date: _selectedDate,
        amount: double.parse(_amountController.text),
        time: _timeController.text,
        trayResult: _trayResult,
        supplements: _selectedSupplements.isNotEmpty ? _selectedSupplements : null,
      );
      
      await context.read<FeedProvider>().addEntry(entry);
      if (context.mounted) Navigator.pop(context);
    } else if (_selectedTankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tank first')),
      );
    }
  }
}
