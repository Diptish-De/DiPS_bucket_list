import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/buy_item.dart';
import '../utils/categories.dart';

class ItemCard extends StatelessWidget {
  final BuyItem item;
  final VoidCallback onAddFunds;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final String? timeEstimate;

  const ItemCard({super.key, required this.item, required this.onAddFunds, required this.onDelete, this.onTap, this.timeEstimate});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final cat = getCategoryByName(item.category);
    final progress = item.progress;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Dismissible(
        key: ValueKey(item.id),
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(20)),
          child: const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.white), SizedBox(width: 8), Text('Add Funds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.delete_outline, color: Colors.white)]),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onAddFunds();
            return false;
          } else {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Delete Goal?', style: TextStyle(fontWeight: FontWeight.w800)),
                content: Text('Remove "${item.name}" permanently?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFE53935)))),
                ],
              ),
            ) ?? false;
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) onDelete();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: InkWell(
            onTap: onTap ?? onAddFunds,
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                  child: Icon(cat.icon, color: cat.color, size: 26),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: const Color(0xFFF0F0F5), color: item.isCompleted ? const Color(0xFF4CAF50) : cat.color),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        Text('${fmt.format(item.savedAmount)} / ${fmt.format(item.price)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8A8A9E))),
                        const Spacer(),
                        if (item.isCompleted)
                          const Text('✅ Done', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF4CAF50)))
                        else if (timeEstimate != null)
                          Text(timeEstimate!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFF6D3B)))
                        else if (item.daysLeft != null)
                          Text('${item.daysLeft}d left', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: item.daysLeft! < 30 ? const Color(0xFFE53935) : const Color(0xFF8A8A9E))),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
