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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: !provider.isInit
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C58FF)))
          : SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar (Trezo style)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFE0E0FF),
                                child: Text('👤', style: TextStyle(fontSize: 24)),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back! 👋',
                                    style: TextStyle(
                                      color: const Color(0xFF8A8A9E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Diptish',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A24),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C58FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text('PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Big Ring Card
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        double totalTarget = provider.items.fold(0.0, (sum, item) => sum + item.price);
                        double totalProgress = totalTarget > 0 ? (provider.totalSaved / totalTarget) : 0.0;
                        if (totalProgress > 1.0) totalProgress = 1.0;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: const Color(0xFFF0F0F5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5C58FF).withOpacity(0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              )
                            ]
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Total Vault Portfolio',
                                style: TextStyle(
                                  color: Color(0xFF1A1A24),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 40),
                              // The Massive Trezo Rounded Ring
                              SizedBox(
                                width: 220,
                                height: 220,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: 1.0,
                                      strokeWidth: 22,
                                      color: const Color(0xFFF3F4F6),
                                    ),
                                    CircularProgressIndicator(
                                      value: totalProgress,
                                      strokeWidth: 22,
                                      backgroundColor: Colors.transparent,
                                      color: const Color(0xFF5C58FF),
                                      strokeCap: StrokeCap.round,
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${(totalProgress * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF5C58FF),
                                              letterSpacing: -1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Funded',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF8A8A9E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 48),
                              // Stats Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        currencyFormat.format(provider.totalSaved),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF5C58FF),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text('Total Saved', style: TextStyle(color: Color(0xFF8A8A9E), fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  Container(height: 40, width: 2, color: const Color(0xFFF0F0F5)),
                                  Column(
                                    children: [
                                      Text(
                                        currencyFormat.format(totalTarget),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1A1A24),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text('Total Target', style: TextStyle(color: Color(0xFF8A8A9E), fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Goals',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A24),
                            ),
                          ),
                          Icon(Icons.sort, color: const Color(0xFF8A8A9E)),
                        ],
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 120),
                    sliver: provider.items.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.track_changes, size: 80, color: const Color(0xFFF0F0F5)),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Ready to start saving?',
                                      style: TextStyle(
                                        color: Color(0xFF1A1A24),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You haven\'t set any goals yet.',
                                      style: TextStyle(
                                        color: const Color(0xFF8A8A9E),
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF5C58FF),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      ),
                                      onPressed: () => _showAddItemSheet(context),
                                      child: const Text('Create Your First Goal'),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.9,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = provider.items[index];
                                  return ItemCard(
                                    key: ValueKey(item.id),
                                    item: item,
                                    expectedMonthlySavings: provider.expectedMonthlySavings,
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
                  ),
                ],
              ),
            ),
    );
  }

}
