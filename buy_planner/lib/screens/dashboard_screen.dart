import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/buy_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/add_funds_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddItemSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BuyProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    double totalTarget = provider.items.fold(0.0, (sum, item) => sum + item.price);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light off-white background
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemSheet(context),
        backgroundColor: const Color(0xFFFF6D3B), // Bright orange
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 36, color: Colors.white),
      ),
      body: !provider.isInit
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6D3B)))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Dark background with rounded bottom corners
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E1E1E), // Dark header color
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 24,
                                  backgroundImage: AssetImage('dips-img.png'),
                                  backgroundColor: Colors.white24,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome Back! 👋',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'DiPS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Overlapping White Card (Gauge)
                      Positioned(
                        top: 140,
                        left: 24,
                        right: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Gauge
                              SizedBox(
                                height: 110,
                                width: 220,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    CustomPaint(
                                      size: const Size(220, 110),
                                      painter: SemiCircleGaugePainter(
                                        progress: totalTarget > 0 ? (provider.totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0,
                                        color: const Color(0xFFFF6D3B),
                                        backgroundColor: const Color(0xFFF0F0F5),
                                      ),
                                    ),
                                    // Inside the gauge
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.stars_rounded, size: 40, color: Color(0xFFFF6D3B)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(totalTarget > 0 ? (provider.totalSaved / totalTarget).clamp(0.0, 1.0) * 100 : 0).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                            height: 1,
                                            letterSpacing: -1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Below the gauge: Savings and Target
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Savings',
                                        style: TextStyle(color: Color(0xFF8A8A9E), fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        currencyFormat.format(provider.totalSaved),
                                        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  Container(height: 32, width: 2, color: const Color(0xFFF0F0F5)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Target',
                                        style: TextStyle(color: Color(0xFF8A8A9E), fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        currencyFormat.format(totalTarget),
                                        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SliverToBoxAdapter(
                  child: SizedBox(height: 190), // Space for the overlapping card (approx 340 height - 130 top = 210 overhang)
                ),
                
                // Tabs (History / Statistics mock)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Goals',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 24,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6D3B),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(width: 24),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
                
                // List of items
                provider.items.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text(
                              'No goals yet. Tap + to add one!',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.only(top: 0, bottom: 100, left: 24, right: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = provider.items[index];
                              return ItemCard(
                                key: ValueKey(item.id),
                                item: item,
                                onAddFunds: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => AddFundsSheet(item: item),
                                  );
                                },
                                onDelete: () => provider.deleteItem(item.id),
                              );
                            },
                            childCount: provider.items.length,
                          ),
                        ),
                      ),
              ],
            ),
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
    final paintBackground = Paint()
      ..color = backgroundColor
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintForeground = Paint()
      ..color = color
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    const startAngle = pi; // 180 degrees (left)
    const sweepAngle = pi; // 180 degrees (right)

    // Draw background
    canvas.drawArc(rect, startAngle, sweepAngle, false, paintBackground);

    // Draw foreground
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, paintForeground);
  }

  @override
  bool shouldRepaint(covariant SemiCircleGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.backgroundColor != backgroundColor;
  }
}
