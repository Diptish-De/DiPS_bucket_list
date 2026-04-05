import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/buy_provider.dart';
import '../models/buy_item.dart';

class AddFundsSheet extends StatefulWidget {
  final BuyItem item;
  const AddFundsSheet({super.key, required this.item});

  @override
  State<AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<AddFundsSheet> {
  final _amountController = TextEditingController();

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) return;

    Provider.of<BuyProvider>(context, listen: false).addFunds(widget.item.id, amount);
    Navigator.pop(context);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Add Savings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A24)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'For ${widget.item.name}',
            style: const TextStyle(fontSize: 15, color: Color(0xFF8A8A9E)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _amountController,
            autofocus: true,
            style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A24), fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: const TextStyle(color: Color(0xFF8A8A9E)),
              hintText: '5,000',
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF5C58FF), width: 1.5)),
              prefixText: '₹ ',
              prefixStyle: const TextStyle(color: Color(0xFF1A1A24), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: const Color(0xFFE0E0FF), width: 1),
                    )
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF5C58FF), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C58FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: const Color(0xFF5C58FF).withOpacity(0.4),
                  ),
                  onPressed: _submit,
                  child: const Text('Add Funds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
