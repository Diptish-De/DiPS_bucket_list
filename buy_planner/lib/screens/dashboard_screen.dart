import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/buy_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/add_funds_sheet.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/goal_detail_sheet.dart';
import '../widgets/celebration_screen.dart';
import '../utils/time_format.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;

  void _showAddItemSheet() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AddItemSheet());
  }

  void _showSettings() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const SettingsSheet());
  }

  void _showGoalDetail(item) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => GoalDetailSheet(item: item));
  }

  void _showAddFunds(item) async {
    final provider = Provider.of<BuyProvider>(context, listen: false);
    double oldSaved = item.savedAmount;
    final result = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddFundsSheet(item: item));

    if (!mounted) return;

    // Check milestone
    int? milestone = provider.checkMilestoneCrossed(item.id, oldSaved);
    if (milestone != null && !item.isCompleted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🎯 ${item.name} hit $milestone%!', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF6D3B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }

    // Check completion
    if (result == true) {
      HapticFeedback.heavyImpact();
      Navigator.push(context, PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => CelebrationScreen(goalName: item.name),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BuyProvider>(context);
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final totalTarget = provider.totalTarget;
    final overallProgress = totalTarget > 0 ? (provider.totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
    final timeline = provider.calculateTimeline();
    final timelineMap = {for (var a in timeline) a.item.id: a};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemSheet,
        backgroundColor: const Color(0xFFFF6D3B),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 36, color: Colors.white),
      ),
      body: !provider.isInit
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6D3B)))
          : Column(children: [
              // Fixed Header
              Container(
                color: const Color(0xFF1E1E1E),
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 24, right: 16, bottom: 20),
                child: Row(children: [
                  const CircleAvatar(radius: 22, backgroundImage: AssetImage('dips-img.png'), backgroundColor: Colors.white24),
                  const SizedBox(width: 14),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Welcome Back! 👋', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    SizedBox(height: 2),
                    Text('DiPS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ])),
                  IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 24), onPressed: _showSettings),
                ]),
              ),

              // Scrollable Content
              Expanded(child: _selectedTab == 0 ? _buildActiveTab(provider, fmt, timelineMap, overallProgress) : _buildCompletedTab(provider, fmt)),
            ]),
    );
  }

  Widget _buildActiveTab(BuyProvider provider, NumberFormat fmt, Map<String, GoalAllocation> timelineMap, double overallProgress) {
    final active = provider.activeItems;

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(20),
            shadowColor: const Color(0xFFFF6D3B).withValues(alpha: 0.3),
            child: child,
          ),
          child: child,
        );
      },
      header: Column(children: [
        // Gauge Card
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Column(children: [
            SizedBox(height: 100, width: 200, child: Stack(alignment: Alignment.bottomCenter, children: [
              CustomPaint(size: const Size(200, 100), painter: SemiCircleGaugePainter(progress: overallProgress, color: const Color(0xFFFF6D3B), backgroundColor: const Color(0xFFF0F0F5))),
              Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.stars_rounded, size: 32, color: Color(0xFFFF6D3B)),
                const SizedBox(height: 2),
                Text('${(overallProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black, height: 1)),
              ]),
            ])),
            const SizedBox(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _stat('Savings', fmt.format(provider.totalSaved), Colors.black),
              Container(height: 28, width: 1.5, color: const Color(0xFFF0F0F5)),
              _stat('Target', fmt.format(provider.totalTarget), Colors.black),
              if (provider.expectedMonthlySavings > 0 && provider.totalCompletionMonths > 0) ...[
                Container(height: 28, width: 1.5, color: const Color(0xFFF0F0F5)),
                _stat('All Done', formatShortETA(provider.totalCompletionMonths), const Color(0xFFFF6D3B)),
              ],
            ]),
          ]),
        ),
        const SizedBox(height: 24),

        // Tabs
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [
          _tab('Your Goals', provider.activeItems.length, 0),
          const SizedBox(width: 24),
          _tab('Completed', provider.completedItems.length, 1),
        ])),
        if (active.isNotEmpty)
          const Padding(padding: EdgeInsets.only(left: 24, top: 8, bottom: 4), child: Row(children: [
            Icon(Icons.drag_indicator, size: 14, color: Color(0xFFBBBBCC)),
            SizedBox(width: 4),
            Text('Hold & drag to reorder priority', style: TextStyle(fontSize: 11, color: Color(0xFFBBBBCC), fontWeight: FontWeight.w600)),
          ])),
        const SizedBox(height: 8),
      ]),
      itemCount: active.length,
      onReorder: (oldIdx, newIdx) {
        HapticFeedback.lightImpact();
        // Map active indices to global indices
        final allItems = provider.items;
        final activeIds = active.map((i) => i.id).toList();
        int globalOld = allItems.indexWhere((i) => i.id == activeIds[oldIdx]);
        int globalNew = allItems.indexWhere((i) => i.id == activeIds[newIdx < active.length ? newIdx : active.length - 1]);
        if (newIdx > oldIdx) globalNew += 1;
        provider.reorderItems(globalOld, globalNew);
      },
      itemBuilder: (context, index) {
        final item = active[index];
        final alloc = timelineMap[item.id];
        return Padding(
          key: ValueKey(item.id),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ItemCard(
            item: item,
            isTopPriority: index == 0,
            monthlyAllocation: alloc?.currentMonthlyAmount,
            completionMonths: alloc?.completionMonths,
            onAddFunds: () => _showAddFunds(item),
            onDelete: () => provider.deleteItem(item.id),
            onTap: () => _showGoalDetail(item),
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab(BuyProvider provider, NumberFormat fmt) {
    final completed = provider.completedItems;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // Gauge (same)
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.emoji_events, size: 32, color: Color(0xFFFF6D3B)),
            const SizedBox(width: 12),
            Text('${completed.length} Goal${completed.length != 1 ? 's' : ''} Achieved!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A24))),
          ]),
        ),
        const SizedBox(height: 24),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [
          _tab('Your Goals', provider.activeItems.length, 0),
          const SizedBox(width: 24),
          _tab('Completed', provider.completedItems.length, 1),
        ])),
        const SizedBox(height: 16),
        if (completed.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text('No completed goals yet.', style: TextStyle(color: Color(0xFF8A8A9E), fontSize: 15))))
        else
          ...completed.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ItemCard(item: item, onAddFunds: () {}, onDelete: () => provider.deleteItem(item.id), onTap: () => _showGoalDetail(item)),
          )),
      ],
    );
  }

  Widget _stat(String label, String value, Color color) => Column(children: [
    Text(label, style: const TextStyle(color: Color(0xFF8A8A9E), fontSize: 12, fontWeight: FontWeight.w600)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
  ]);

  Widget _tab(String label, int count, int index) {
    final sel = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: sel ? Colors.black : Colors.grey.shade400)),
          if (count > 0) ...[const SizedBox(width: 6), Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: sel ? const Color(0xFFFF6D3B) : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: sel ? Colors.white : Colors.grey.shade600)),
          )],
        ]),
        const SizedBox(height: 4),
        Container(width: sel ? 24 : 0, height: 3, decoration: BoxDecoration(color: const Color(0xFFFF6D3B), borderRadius: BorderRadius.circular(2))),
      ]),
    );
  }
}

class SemiCircleGaugePainter extends CustomPainter {
  final double progress; final Color color; final Color backgroundColor;
  SemiCircleGaugePainter({required this.progress, required this.color, required this.backgroundColor});
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = backgroundColor..strokeWidth = 20..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final fg = Paint()..color = color..strokeWidth = 20..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(rect, pi, pi, false, bg);
    canvas.drawArc(rect, pi, pi * progress, false, fg);
  }
  @override
  bool shouldRepaint(covariant SemiCircleGaugePainter old) => old.progress != progress;
}
