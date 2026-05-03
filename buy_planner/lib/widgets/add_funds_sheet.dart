import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/buy_provider.dart';
import '../models/buy_item.dart';
import 'package:intl/intl.dart';

class AddFundsSheet extends StatefulWidget {
  final BuyItem item;
  const AddFundsSheet({super.key, required this.item});

  @override
  State<AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<AddFundsSheet> {
  final _amountController = TextEditingController();
  final _presets = [100, 500, 1000, 2000, 5000];

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;
    final justCompleted = Provider.of<BuyProvider>(context, listen: false).addFunds(widget.item.id, amount);
    Navigator.pop(context, justCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final remaining = widget.item.price - widget.item.savedAmount;
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

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
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            const Text('Add Savings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A24)), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(widget.item.name, style: const TextStyle(fontSize: 16, color: Color(0xFFFF6D3B), fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Remaining: ${fmt.format(remaining > 0 ? remaining : 0)}', style: const TextStyle(fontSize: 13, color: Color(0xFF8A8A9E), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            const Text('Quick Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF8A8A9E))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: _presets.map((a) => GestureDetector(
                onTap: () => _amountController.text = a.toString(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFFFFF0EB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFF6D3B).withValues(alpha: 0.3))),
                  child: Text('₹${NumberFormat('#,##,###').format(a)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFF6D3B))),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A24), fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Custom Amount', labelStyle: const TextStyle(color: Color(0xFF8A8A9E)), hintText: '1,500',
                filled: true, fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6D3B), width: 1.5)),
                prefixText: '₹ ', prefixStyle: const TextStyle(color: Color(0xFF1A1A24), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.number, onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: TextButton(
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE0E0E0)))),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A8A9E), fontWeight: FontWeight.bold)),
              )),
              const SizedBox(width: 16),
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6D3B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4),
                onPressed: _submit,
                child: const Text('Add Funds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}
