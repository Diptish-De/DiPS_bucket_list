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
import '../utils/currency_formatter.dart';

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

  void _showProfileImage() {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: const Hero(tag: 'profile-pic', child: CircleAvatar(radius: 120, backgroundImage: AssetImage('dips-img.png'), backgroundColor: Colors.white24)),
      ),
    ));
  }

  void _showMonthlySavingsQuickEdit() {
    final provider = Provider.of<BuyProvider>(context, listen: false);
    final ctrl = TextEditingController(text: provider.expectedMonthlySavings > 0 ? provider.expectedMonthlySavings.toStringAsFixed(0) : '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Monthly Savings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      content: TextField(
        controller: ctrl, autofocus: true, keyboardType: TextInputType.number,
        inputFormatters: [CurrencyInputFormatter()],
        decoration: InputDecoration(
          prefixText: '₹ ', prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          hintText: '10,000', filled: true, fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6D3B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () { provider.setExpectedMonthlySavings(parseCurrencyInput(ctrl.text)); Navigator.pop(ctx); },
          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }

  void _showAddFunds(item) async {
    final provider = Provider.of<BuyProvider>(context, listen: false);
    double oldSaved = item.savedAmount;
    final result = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddFundsSheet(item: item));
    if (!mounted) return;
    int? milestone = provider.checkMilestoneCrossed(item.id, oldSaved);
    if (milestone != null && !item.isCompleted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🎯 ${item.name} hit $milestone%!', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF6D3B), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
    if (result == true) {
      HapticFeedback.heavyImpact();
      Navigator.push(context, PageRouteBuilder(opaque: false, pageBuilder: (_, __, ___) => CelebrationScreen(goalName: item.name), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)));
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
      floatingActionButton: FloatingActionButton(onPressed: _showAddItemSheet, backgroundColor: const Color(0xFFFF6D3B), elevation: 6, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.add, size: 36, color: Colors.white)),
      body: !provider.isInit
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6D3B)))
          : Column(children: [
              // ===== PREMIUM HEADER =====
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                ),
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 12, bottom: 20),
                child: Row(children: [
                  // Profile pic (tap to enlarge)
                  GestureDetector(
                    onTap: _showProfileImage,
                    child: Hero(
                      tag: 'profile-pic',
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFF6D3B), width: 2.5)),
                        child: CircleAvatar(radius: 22, backgroundImage: const AssetImage('dips-img.png'), backgroundColor: Colors.grey.shade800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Welcome Back! 👋', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 1),
                    Text(provider.userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ])),
                  // Monthly savings chip
                  GestureDetector(
                    onTap: _showMonthlySavingsQuickEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.savings_outlined, color: Color(0xFFFF6D3B), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          provider.expectedMonthlySavings > 0 ? fmt.format(provider.expectedMonthlySavings) : 'Set',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Dark mode toggle
                  IconButton(
                    icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined, color: Colors.white60, size: 22),
                    onPressed: () { HapticFeedback.lightImpact(); provider.toggleDarkMode(); },
                    tooltip: 'Toggle theme',
                  ),
                  // Settings
                  IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white60, size: 22), onPressed: _showSettings),
                ]),
              ),

              // ===== CONTENT =====
              Expanded(child: _selectedTab == 0 ? _buildActiveTab(provider, fmt, timelineMap, overallProgress) : _buildCompletedTab(provider, fmt)),
            ]),
    );
  }

  Widget _buildActiveTab(BuyProvider provider, NumberFormat fmt, Map<String, GoalAllocation> timelineMap, double overallProgress) {
    final active = provider.activeItems;
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      proxyDecorator: (child, index, animation) => AnimatedBuilder(animation: animation, builder: (_, child) => Material(elevation: 8, borderRadius: BorderRadius.circular(20), shadowColor: const Color(0xFFFF6D3B).withValues(alpha: 0.3), child: child), child: child),
      header: Column(children: [
        // Gauge
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))]),
          child: Column(children: [
            SizedBox(height: 90, width: 180, child: Stack(alignment: Alignment.bottomCenter, children: [
              CustomPaint(size: const Size(180, 90), painter: _GaugePainter(progress: overallProgress)),
              Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.stars_rounded, size: 28, color: Color(0xFFFF6D3B)),
                Text('${(overallProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black, height: 1)),
              ]),
            ])),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _stat('Savings', fmt.format(provider.totalSaved), Colors.black),
              Container(height: 24, width: 1, color: const Color(0xFFF0F0F5)),
              _stat('Target', fmt.format(provider.totalTarget), Colors.black),
              if (provider.expectedMonthlySavings > 0 && provider.totalCompletionMonths > 0) ...[
                Container(height: 24, width: 1, color: const Color(0xFFF0F0F5)),
                _stat('All Done', formatShortETA(provider.totalCompletionMonths), const Color(0xFFFF6D3B)),
              ],
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        // Tabs
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [
          _tab('Your Goals', provider.activeItems.length, 0),
          const SizedBox(width: 24),
          _tab('Completed', provider.completedItems.length, 1),
        ])),
        if (active.isNotEmpty)
          const Padding(padding: EdgeInsets.only(left: 24, top: 6, bottom: 2), child: Row(children: [
            Icon(Icons.drag_indicator, size: 13, color: Color(0xFFCCCCCC)),
            SizedBox(width: 4),
            Text('Hold & drag to set priority', style: TextStyle(fontSize: 10, color: Color(0xFFCCCCCC), fontWeight: FontWeight.w600)),
          ])),
        const SizedBox(height: 6),
      ]),
      itemCount: active.length,
      onReorder: (o, n) {
        HapticFeedback.lightImpact();
        final ids = active.map((i) => i.id).toList();
        int go = provider.items.indexWhere((i) => i.id == ids[o]);
        int gn = provider.items.indexWhere((i) => i.id == ids[n < active.length ? n : active.length - 1]);
        if (n > o) gn += 1;
        provider.reorderItems(go, gn);
      },
      itemBuilder: (_, i) {
        final item = active[i];
        final alloc = timelineMap[item.id];
        return Padding(key: ValueKey(item.id), padding: const EdgeInsets.symmetric(horizontal: 20), child: ItemCard(
          item: item, isTopPriority: i == 0, monthlyAllocation: alloc?.currentMonthlyAmount, completionMonths: alloc?.completionMonths,
          onAddFunds: () => _showAddFunds(item), onDelete: () => provider.deleteItem(item.id), onTap: () => _showGoalDetail(item),
        ));
      },
    );
  }

  Widget _buildCompletedTab(BuyProvider provider, NumberFormat fmt) {
    final completed = provider.completedItems;
    return ListView(padding: const EdgeInsets.only(bottom: 100), children: [
      Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.emoji_events, size: 28, color: Color(0xFFFF6D3B)),
          const SizedBox(width: 10),
          Text('${completed.length} Goal${completed.length != 1 ? 's' : ''} Achieved!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
      ),
      const SizedBox(height: 20),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [_tab('Your Goals', provider.activeItems.length, 0), const SizedBox(width: 24), _tab('Completed', completed.length, 1)])),
      const SizedBox(height: 12),
      if (completed.isEmpty) const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text('No completed goals yet.', style: TextStyle(color: Color(0xFF8A8A9E)))))
      else ...completed.map((item) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: ItemCard(item: item, onAddFunds: () {}, onDelete: () => provider.deleteItem(item.id), onTap: () => _showGoalDetail(item)))),
    ]);
  }

  Widget _stat(String l, String v, Color c) => Column(children: [Text(l, style: const TextStyle(color: Color(0xFF8A8A9E), fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(v, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w800))]);

  Widget _tab(String label, int count, int index) {
    final s = _selectedTab == index;
    return GestureDetector(onTap: () => setState(() => _selectedTab = index), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: s ? Colors.black : Colors.grey.shade400)),
        if (count > 0) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: s ? const Color(0xFFFF6D3B) : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)), child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: s ? Colors.white : Colors.grey.shade600)))],
      ]),
      const SizedBox(height: 3),
      Container(width: s ? 20 : 0, height: 2.5, decoration: BoxDecoration(color: const Color(0xFFFF6D3B), borderRadius: BorderRadius.circular(2))),
    ]));
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  _GaugePainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF0F0F5)..strokeWidth = 18..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final fg = Paint()..color = const Color(0xFFFF6D3B)..strokeWidth = 18..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final r = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(r, pi, pi, false, bg);
    canvas.drawArc(r, pi, pi * progress, false, fg);
  }
  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.progress != progress;
}
