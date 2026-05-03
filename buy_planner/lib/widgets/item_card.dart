import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/buy_item.dart';
import '../utils/categories.dart';
import '../utils/time_format.dart';

class ItemCard extends StatelessWidget {
  final BuyItem item;
  final VoidCallback onAddFunds;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final double? monthlyAllocation;
  final double? completionMonths;
  final bool isTopPriority;

  const ItemCard({
    super.key, required this.item, required this.onAddFunds, required this.onDelete,
    this.onTap, this.monthlyAllocation, this.completionMonths, this.isTopPriority = false,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final cat = getCategoryByName(item.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Dismissible(
        key: ValueKey('dismiss_${item.id}'),
        background: Container(
          alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(20)),
          child: const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.white), SizedBox(width: 8), Text('Add Funds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.delete_outline, color: Colors.white)]),
        ),
        confirmDismiss: (dir) async {
          if (dir == DismissDirection.startToEnd) { onAddFunds(); return false; }
          return await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Goal?', style: TextStyle(fontWeight: FontWeight.w800)),
            content: Text('Remove "${item.name}" permanently?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFE53935)))),
            ],
          )) ?? false;
        },
        onDismissed: (dir) { if (dir == DismissDirection.endToStart) onDelete(); },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isTopPriority ? Border.all(color: const Color(0xFFFF6D3B).withValues(alpha: 0.3), width: 1.5) : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: InkWell(
            onTap: onTap ?? onAddFunds,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Row(children: [
                  // Category icon
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      if (isTopPriority && !item.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFFF6D3B), borderRadius: BorderRadius.circular(8)),
                          child: const Text('FUNDING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                        )
                      else if (!item.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(8)),
                          child: const Text('IN QUEUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF8A8A9E), letterSpacing: 0.5)),
                        ),
                      if (item.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(8)),
                          child: const Text('DONE ✓', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                        ),
                    ]),
                    const SizedBox(height: 6),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: item.progress, minHeight: 5, backgroundColor: const Color(0xFFF0F0F5), color: item.isCompleted ? const Color(0xFF4CAF50) : cat.color),
                    ),
                  ])),
                ]),
                const SizedBox(height: 10),
                // Bottom info row
                Row(children: [
                  Text('${fmt.format(item.savedAmount)} / ${fmt.format(item.price)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8A8A9E))),
                  const Spacer(),
                  if (monthlyAllocation != null && monthlyAllocation! > 0 && !item.isCompleted)
                    Text('${fmt.format(monthlyAllocation)}/mo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: cat.color)),
                  if (completionMonths != null && completionMonths! > 0 && !item.isCompleted) ...[
                    const SizedBox(width: 8),
                    Text(formatShortETA(completionMonths!), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFF6D3B))),
                  ],
                ]),
                // Milestone info
                if (!item.isCompleted && item.lastMilestonePercent < 100) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Text('Next: ${item.nextMilestonePercent}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF8A8A9E))),
                    const SizedBox(width: 6),
                    Text('(${fmt.format(item.amountToNextMilestone)} more)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFBBBBCC))),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
