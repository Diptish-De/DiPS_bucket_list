import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/buy_item.dart';

class ItemCard extends StatelessWidget {
  final BuyItem item;
  final double expectedMonthlySavings;
  final VoidCallback onAddFunds;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.expectedMonthlySavings,
    required this.onAddFunds,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final rupeeFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    double progress = item.price > 0 ? (item.savedAmount / item.price) : 0.0;
    if (progress > 1.0) progress = 1.0;

    // Pick a beautiful striking pastel color pair inspired by the screenshot (Protein/Carbs/Fat)
    final colors = [
      [const Color(0xFFFFF0F5), const Color(0xFFFF85A1)], // Pink
      [const Color(0xFFF0FFF4), const Color(0xFF2ED573)], // Green
      [const Color(0xFFFFF7E6), const Color(0xFFFFA502)], // Orange
      [const Color(0xFFF0F8FF), const Color(0xFF1E90FF)], // Blue
      [const Color(0xFFF8F0FF), const Color(0xFF9C88FF)], // Purple
    ];
    final colorIndex = item.name.length % colors.length;
    final bgColor = colors[colorIndex][0];
    final strokeColor = colors[colorIndex][1];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onLongPress: onDelete,
          onTap: onAddFunds,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular Ring from screenshot
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 8,
                          color: strokeColor.withOpacity(0.15),
                        ),
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.transparent,
                          color: strokeColor,
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: strokeColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rupeeFormat.format(item.savedAmount),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: strokeColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E28),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
