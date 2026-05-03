import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/buy_provider.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});
  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TextEditingController _savingsController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BuyProvider>(context, listen: false);
    _savingsController = TextEditingController(
      text: provider.expectedMonthlySavings > 0 ? provider.expectedMonthlySavings.toStringAsFixed(0) : '',
    );
  }

  void _save() {
    final amount = double.tryParse(_savingsController.text) ?? 0.0;
    Provider.of<BuyProvider>(context, listen: false).setExpectedMonthlySavings(amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BuyProvider>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: EdgeInsets.only(bottom: bottomInset + 32, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 24),
          const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A24)), textAlign: TextAlign.center),
          const SizedBox(height: 28),

          // Dark mode toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(children: [
                  Icon(Icons.dark_mode_outlined, color: Color(0xFF8A8A9E)),
                  SizedBox(width: 12),
                  Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A24))),
                ]),
                Switch(
                  value: provider.isDarkMode,
                  onChanged: (_) => provider.toggleDarkMode(),
                  activeColor: const Color(0xFFFF6D3B),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Monthly savings input
          TextField(
            controller: _savingsController,
            style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A24), fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Monthly Savings Budget', labelStyle: const TextStyle(color: Color(0xFF8A8A9E)),
              hintText: '10,000', filled: true, fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6D3B), width: 1.5)),
              prefixText: '₹ ', prefixStyle: const TextStyle(color: Color(0xFF1A1A24), fontSize: 16, fontWeight: FontWeight.bold),
              helperText: 'Used to estimate time to reach each goal',
              helperStyle: const TextStyle(color: Color(0xFF8A8A9E), fontSize: 12),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 28),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6D3B), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _save,
            child: const Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
