import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/buy_provider.dart';
import '../utils/categories.dart';
import '../utils/time_format.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BuyProvider>(context);
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final timeline = provider.calculateTimeline();
    final totalMonths = provider.totalCompletionMonths;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(children: [
        // Header
        Container(
          color: const Color(0xFF1E1E1E),
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 24, right: 24, bottom: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your Journey', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            if (provider.expectedMonthlySavings > 0 && totalMonths > 0)
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFFF6D3B).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(formatShortETA(totalMonths), style: const TextStyle(color: Color(0xFFFF6D3B), fontSize: 13, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Text('to complete all ${timeline.length} goals', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              ])
            else
              const Text('Set monthly savings in Settings to see your timeline', style: TextStyle(color: Colors.white38, fontSize: 13)),
          ]),
        ),

        // Timeline Content
        Expanded(
          child: timeline.isEmpty
              ? const Center(child: Text('Add goals and set monthly savings\nto see your timeline here.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8A8A9E), fontSize: 15)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  itemCount: timeline.length,
                  itemBuilder: (context, index) {
                    final alloc = timeline[index];
                    final item = alloc.item;
                    final cat = getCategoryByName(item.category);
                    final isFirst = index == 0;
                    final isLast = index == timeline.length - 1;
                    final isCompleted = item.isCompleted;

                    return IntrinsicHeight(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Timeline line + dot
                        SizedBox(
                          width: 40,
                          child: Column(children: [
                            // Top connector
                            if (!isFirst) Container(width: 2, height: 20, color: const Color(0xFFE0E0E0)),
                            // Dot
                            Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFirst && !isCompleted ? const Color(0xFFFF6D3B) : isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
                                border: Border.all(color: isFirst && !isCompleted ? const Color(0xFFFF6D3B) : Colors.transparent, width: 3),
                                boxShadow: isFirst && !isCompleted ? [BoxShadow(color: const Color(0xFFFF6D3B).withValues(alpha: 0.3), blurRadius: 8)] : [],
                              ),
                              child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                            ),
                            // Bottom connector
                            if (!isLast) Expanded(child: Container(width: 2, color: const Color(0xFFE0E0E0))),
                          ]),
                        ),
                        const SizedBox(width: 12),

                        // Card
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isFirst && !isCompleted ? Border.all(color: const Color(0xFFFF6D3B).withValues(alpha: 0.3), width: 1.5) : null,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              // Header row
                              Row(children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(cat.icon, color: cat.color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isCompleted ? const Color(0xFF8A8A9E) : const Color(0xFF1A1A24))),
                                  Text(item.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cat.color)),
                                ])),
                                if (isFirst && !isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFFF6D3B), borderRadius: BorderRadius.circular(8)),
                                    child: const Text('NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                                  ),
                              ]),
                              const SizedBox(height: 14),

                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(value: item.progress, minHeight: 6, backgroundColor: const Color(0xFFF0F0F5), color: isCompleted ? const Color(0xFF4CAF50) : cat.color),
                              ),
                              const SizedBox(height: 10),

                              // Stats
                              Row(children: [
                                _miniStat('Saved', fmt.format(item.savedAmount)),
                                const SizedBox(width: 16),
                                _miniStat('Remaining', fmt.format(item.remaining)),
                                const Spacer(),
                                if (alloc.currentMonthlyAmount > 0 && !isCompleted)
                                  _miniStat('Per Month', fmt.format(alloc.currentMonthlyAmount)),
                              ]),

                              if (!isCompleted && alloc.completionMonths > 0) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(color: const Color(0xFFFFF8F5), borderRadius: BorderRadius.circular(10)),
                                  child: Row(children: [
                                    const Icon(Icons.schedule, size: 14, color: Color(0xFFFF6D3B)),
                                    const SizedBox(width: 6),
                                    Text('Completes ${formatShortETA(alloc.completionMonths)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF6D3B))),
                                    const SizedBox(width: 8),
                                    Text('(${formatMonths(alloc.completionMonths)})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8A8A9E))),
                                  ]),
                                ),
                              ],

                              if (isCompleted) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(color: const Color(0xFFF0FFF4), borderRadius: BorderRadius.circular(10)),
                                  child: const Row(children: [
                                    Icon(Icons.check_circle, size: 14, color: Color(0xFF4CAF50)),
                                    SizedBox(width: 6),
                                    Text('Goal Achieved! 🎉', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4CAF50))),
                                  ]),
                                ),
                              ],
                            ]),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Widget _miniStat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFBBBBCC))),
    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A1A24))),
  ]);
}
