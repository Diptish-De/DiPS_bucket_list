import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/buy_provider.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});
  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<BuyProvider>(context, listen: false);
    _nameCtrl = TextEditingController(text: p.userName);
    _emailCtrl = TextEditingController(text: p.userEmail);
  }

  void _save() {
    final p = Provider.of<BuyProvider>(context, listen: false);
    p.setUserName(_nameCtrl.text.trim().isEmpty ? 'DiPS' : _nameCtrl.text.trim());
    p.setUserEmail(_emailCtrl.text.trim());
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Settings saved!', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF4CAF50),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _exportData() {
    final p = Provider.of<BuyProvider>(context, listen: false);
    final data = p.exportData();
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('📋 Data copied to clipboard!', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFFFF6D3B),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: EdgeInsets.only(bottom: bottomInset + 32, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(10)))),
        const SizedBox(height: 20),
        const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A24)), textAlign: TextAlign.center),
        const SizedBox(height: 28),

        // Profile section
        const Text('PROFILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF8A8A9E), letterSpacing: 1)),
        const SizedBox(height: 12),

        // Profile pic with change hint
        Center(child: Stack(children: [
          const CircleAvatar(radius: 40, backgroundImage: AssetImage('dips-img.png'), backgroundColor: Color(0xFFF0F0F5)),
          Positioned(bottom: 0, right: 0, child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: const Color(0xFFFF6D3B), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
          )),
        ])),
        const SizedBox(height: 6),
        const Center(child: Text('Tap to change photo', style: TextStyle(fontSize: 11, color: Color(0xFFBBBBCC)))),
        const SizedBox(height: 16),

        // Name
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A24), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Display Name', labelStyle: const TextStyle(color: Color(0xFF8A8A9E)),
            filled: true, fillColor: const Color(0xFFF8F9FA),
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF8A8A9E)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6D3B), width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),

        // Email
        TextField(
          controller: _emailCtrl,
          style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A24), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Email (for backup)', labelStyle: const TextStyle(color: Color(0xFF8A8A9E)),
            hintText: 'your@email.com',
            filled: true, fillColor: const Color(0xFFF8F9FA),
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8A8A9E)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6D3B), width: 1.5)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),

        // Data section
        const Text('DATA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF8A8A9E), letterSpacing: 1)),
        const SizedBox(height: 12),

        // Export
        _settingsTile(Icons.upload_outlined, 'Export Data', 'Copy all data to clipboard', _exportData),
        const SizedBox(height: 24),

        // Save button
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6D3B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          onPressed: _save,
          child: const Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ])),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Icon(icon, color: const Color(0xFFFF6D3B), size: 22),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A24))),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9E))),
          ])),
          const Icon(Icons.chevron_right, color: Color(0xFFBBBBCC)),
        ]),
      ),
    );
  }
}
