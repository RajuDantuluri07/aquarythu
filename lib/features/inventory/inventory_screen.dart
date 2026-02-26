import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/date_utils.dart';
import 'inventory_model.dart';
import 'inventory_provider.dart';

class InventoryScreen extends StatefulWidget {
  final String farmId;
  const InventoryScreen({super.key, required this.farmId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadItems(widget.farmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final lowStockItems = inventoryProvider.lowStockItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Low Stock Alert
            if (lowStockItems.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  border: Border.all(color: AppColors.warning),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warningDark),
                        const SizedBox(width: 8),
                        Text(
                          '${lowStockItems.length} items below threshold',
                          style: const TextStyle(color: AppColors.warningDark, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...lowStockItems.map((item) => Text(
                      '${item.name}: ${item.quantity} ${item.unit}',
                      style: const TextStyle(color: AppColors.warningDark, fontSize: 12),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Inventory List
            const Text('All Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (inventoryProvider.items.isEmpty)
              const Center(child: Text('No inventory items yet'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: inventoryProvider.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) => _buildInventoryCard(inventoryProvider.items[index]),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: item.isLowStock ? AppColors.warning : AppColors.gray300,
        ),
        borderRadius: BorderRadius.circular(8),
        color: item.isLowStock ? AppColors.warningLight.withOpacity(0.3) : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    item.category,
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ],
              ),
              Row(
                children: [
                  if (item.isLowStock)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.warning, color: AppColors.warning, size: 20),
                    ),
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => _showEditItemDialog(context, item),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () => _deleteItem(item.id),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item.quantity} ${item.unit}', style: const TextStyle(fontSize: 14)),
              Text(
                'Last restocked: ${AppDateUtils.getShortDate(item.lastRestocked)}',
                style: const TextStyle(fontSize: 11, color: AppColors.gray600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _InventoryItemDialog(farmId: widget.farmId),
    );
  }

  void _showEditItemDialog(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (_) => _InventoryItemDialog(farmId: widget.farmId, item: item),
    );
  }

  Future<void> _deleteItem(String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<InventoryProvider>().deleteItem(itemId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

class _InventoryItemDialog extends StatefulWidget {
  final String farmId;
  final InventoryItem? item;

  const _InventoryItemDialog({required this.farmId, this.item});

  @override
  State<_InventoryItemDialog> createState() => _InventoryItemDialogState();
}

class _InventoryItemDialogState extends State<_InventoryItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _thresholdController;
  String _selectedUnit = 'kg';
  String _selectedCategory = 'Feed';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final List<String> _units = ['kg', 'liters', 'pieces', 'bags', 'boxes'];
  final List<String> _categories = ['Feed', 'Medicine', 'Equipment', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _thresholdController = TextEditingController(text: widget.item?.minThreshold?.toString() ?? '');
    _selectedUnit = widget.item?.unit ?? 'kg';
    _selectedCategory = widget.item?.category ?? 'Feed';
    _selectedDate = widget.item?.lastRestocked ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final item = InventoryItem(
        id: widget.item?.id ?? const Uuid().v4(),
        name: _nameController.text,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        category: _selectedCategory,
        lastRestocked: _selectedDate,
        minThreshold: _thresholdController.text.isEmpty ? null : double.parse(_thresholdController.text),
      );

      if (widget.item == null) {
        await context.read<InventoryProvider>().addItem(widget.farmId, item);
      } else {
        await context.read<InventoryProvider>().updateItem(item);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.item == null ? 'Item added' : 'Item updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => setState(() => _selectedUnit = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _thresholdController,
              decoration: const InputDecoration(labelText: 'Min Threshold (optional)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
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
          onPressed: _isSaving ? null : _save,
          child: _isSaving ? const SizedBox(height: 20, child: CircularProgressIndicator()) : const Text('Save'),
        ),
      ],
    );
  }
}
