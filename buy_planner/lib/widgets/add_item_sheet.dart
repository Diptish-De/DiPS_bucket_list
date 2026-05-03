import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/buy_provider.dart';
import '../utils/categories.dart';
import '../utils/currency_formatter.dart';

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Other';
  DateTime? _targetDate;

  void _submit() {
    final name = _nameController.text.trim();
    final price = parseCurrencyInput(_priceController.text);

    if (name.isEmpty || price <= 0) return;

    Provider.of<BuyProvider>(context, listen: false)
        .addItem(name, price, category: _selectedCategory, targetDate: _targetDate);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF6D3B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset + 32, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Create New Goal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A24)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Name field
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A24), fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Goal Name',
                labelStyle: const TextStyle(color: Color(0xFF8A8A9E)),
                hintText: 'e.g. New Laptop',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6D3B), width: 1.5)),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Price field
            TextField(
              controller: _priceController,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A24), fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Goal Amount',
                labelStyle: const TextStyle(color: Color(0xFF8A8A9E)),
                hintText: '25,000',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6D3B), width: 1.5)),
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: Color(0xFF1A1A24), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
            ),
            const SizedBox(height: 20),

            // Category picker
            const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF8A8A9E))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: goalCategories.map((cat) {
                final isSelected = _selectedCategory == cat.name;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.color.withValues(alpha: 0.15) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? cat.color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, size: 18, color: isSelected ? cat.color : const Color(0xFF8A8A9E)),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? cat.color : const Color(0xFF8A8A9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Target date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF8A8A9E)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _targetDate != null
                            ? 'Target: ${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                            : 'Set a target date (optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _targetDate != null ? const Color(0xFF1A1A24) : const Color(0xFF8A8A9E),
                        ),
                      ),
                    ),
                    if (_targetDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _targetDate = null),
                        child: const Icon(Icons.close, size: 18, color: Color(0xFF8A8A9E)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D3B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFFFF6D3B).withValues(alpha: 0.4),
              ),
              onPressed: _submit,
              child: const Text('Create Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
