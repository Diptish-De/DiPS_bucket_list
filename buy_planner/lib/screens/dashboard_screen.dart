import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/buy_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/add_funds_sheet.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/goal_detail_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0; // 0 = active, 1 = completed

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
    final result = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddFundsSheet(item: item));
    if (result == true && mounted) {
      _showCelebration(item.name);
    }
  }

  void _showCelebration(String goalName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('Goal Achieved!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A1A24))),
          const SizedBox(height: 8),
          Text('You completed "$goalName"!', style: const TextStyle(fontSize: 15, color: Color(0xFF8A8A9E), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome! 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BuyProvider>(context);
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final totalTarget = provider.totalTarget;
    final overallProgress = totalTarget > 0 ? (provider.totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
    final displayItems = _selectedTab == 0 ? provider.activeItems : provider.completedItems;

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
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(
                      height: 200, width: double.infinity,
                      decoration: const BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
                      padding: const EdgeInsets.only(top: 56, left: 24, right: 24),
                      child: Row(children: [
                        const CircleAvatar(radius: 22, backgroundImage: AssetImage('dips-img.png'), backgroundColor: Colors.white24),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Welcome Back! 👋', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          const Text('DiPS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ])),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 24),
                          onPressed: _showSettings,
                        ),
                      ]),
                    ),
                    // Gauge Card
                    Positioned(top: 120, left: 20, right: 20, child: Container(
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
                          Column(children: [
                            const Text('Savings', style: TextStyle(color: Color(0xFF8A8A9E), fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(fmt.format(provider.totalSaved), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800)),
                          ]),
                          Container(height: 28, width: 1.5, color: const Color(0xFFF0F0F5)),
                          Column(children: [
                            const Text('Target', style: TextStyle(color: Color(0xFF8A8A9E), fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(fmt.format(totalTarget), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800)),
                          ]),
                          if (provider.monthsToComplete >= 0) ...[
                            Container(height: 28, width: 1.5, color: const Color(0xFFF0F0F5)),
                            Column(children: [
                              const Text('ETA', style: TextStyle(color: Color(0xFF8A8A9E), fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('${provider.monthsToComplete.ceil()}mo', style: const TextStyle(color: Color(0xFFFF6D3B), fontSize: 16, fontWeight: FontWeight.w800)),
                            ]),
                          ],
                        ]),
                      ]),
                    )),
                  ]),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 170)),

                // Tabs
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(children: [
                      _buildTab('Your Goals', provider.activeItems.length, 0),
                      const SizedBox(width: 24),
                      _buildTab('Completed', provider.completedItems.length, 1),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Items
                displayItems.isEmpty
                    ? SliverToBoxAdapter(child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(child: Text(
                          _selectedTab == 0 ? 'No active goals. Tap + to add one!' : 'No completed goals yet.',
                          style: const TextStyle(color: Color(0xFF8A8A9E), fontSize: 15),
                        )),
                      ))
                    : SliverPadding(
                        padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
                        sliver: SliverList(delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = displayItems[index];
                            final months = provider.monthsForGoal(item);
                            String? estimate;
                            if (months > 0) estimate = '~${months.ceil()}mo';
                            return ItemCard(
                              key: ValueKey(item.id), item: item,
                              timeEstimate: estimate,
                              onAddFunds: () => _showAddFunds(item),
                              onDelete: () => provider.deleteItem(item.id),
                              onTap: () => _showGoalDetail(item),
                            );
                          },
                          childCount: displayItems.length,
                        )),
                      ),
              ],
            ),
    );
  }

  Widget _buildTab(String label, int count, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: isSelected ? Colors.black : Colors.grey.shade400)),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: isSelected ? const Color(0xFFFF6D3B) : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : Colors.grey.shade600)),
            ),
          ],
        ]),
        const SizedBox(height: 4),
        Container(width: isSelected ? 24 : 0, height: 3, decoration: BoxDecoration(color: const Color(0xFFFF6D3B), borderRadius: BorderRadius.circular(2))),
      ]),
    );
  }
}

class SemiCircleGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

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
  bool shouldRepaint(covariant SemiCircleGaugePainter old) => old.progress != progress || old.color != color;
}
