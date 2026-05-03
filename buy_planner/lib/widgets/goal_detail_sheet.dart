import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/buy_item.dart';
import '../providers/buy_provider.dart';
import '../utils/categories.dart';

class GoalDetailSheet extends StatefulWidget {
  final BuyItem item;
  const GoalDetailSheet({super.key, required this.item});
  @override
  State<GoalDetailSheet> createState() => _GoalDetailSheetState();
}

class _GoalDetailSheetState extends State<GoalDetailSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late String _category;
  DateTime? _targetDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _priceCtrl = TextEditingController(text: widget.item.price.toStringAsFixed(0));
    _category = widget.item.category;
    _targetDate = widget.item.targetDate;
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text) ?? widget.item.price;
    if (name.isEmpty) return;
    Provider.of<BuyProvider>(context, listen: false).editItem(
      widget.item.id, name: name, price: price, category: _category,
      targetDate: _targetDate, clearTargetDate: _targetDate == null && widget.item.targetDate != null,
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final cat = getCategoryByName(widget.item.category);
    final history = widget.item.fundHistory.reversed.take(10).toList();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            // Header
            Row(children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(cat.icon, color: cat.color, size: 26)),
              const SizedBox(width: 14),
              Expanded(child: _isEditing
                ? TextField(controller: _nameCtrl, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800), decoration: const InputDecoration(border: InputBorder.none, isDense: true))
                : Text(widget.item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A24)))),
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined, color: const Color(0xFFFF6D3B)),
                onPressed: () { if (_isEditing) _save(); else setState(() => _isEditing = true); },
              ),
            ]),
            const SizedBox(height: 24),

            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: widget.item.progress, minHeight: 10, backgroundColor: const Color(0xFFF0F0F5), color: widget.item.isCompleted ? const Color(0xFF4CAF50) : cat.color),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(fmt.format(widget.item.savedAmount), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cat.color)),
              Text('of ${fmt.format(widget.item.price)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF8A8A9E))),
            ]),
            const SizedBox(height: 8),
            Text('${(widget.item.progress * 100).toStringAsFixed(1)}% funded', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8A8A9E))),

            if (_isEditing) ...[
              const SizedBox(height: 20),
              TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Target Amount', prefixText: '₹ ', filled: true, fillColor: const Color(0xFFF8F9FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
              const SizedBox(height: 12),
              const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF8A8A9E))),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: goalCategories.map((c) {
                final sel = _category == c.name;
                return GestureDetector(
                  onTap: () => setState(() => _category = c.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: sel ? c.color.withValues(alpha: 0.15) : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? c.color : Colors.transparent)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(c.icon, size: 16, color: sel ? c.color : const Color(0xFF8A8A9E)), const SizedBox(width: 4), Text(c.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? c.color : const Color(0xFF8A8A9E)))]),
                  ),
                );
              }).toList()),
            ],

            // Fund History
            if (history.isNotEmpty) ...[
              const SizedBox(height: 28),
              const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A24))),
              const SizedBox(height: 12),
              ...history.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF0FFF4), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add, color: Color(0xFF4CAF50), size: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('+${fmt.format(entry.amount)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF4CAF50))),
                    Text(DateFormat('dd MMM yyyy, hh:mm a').format(entry.date), style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A9E))),
                  ])),
                ]),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
