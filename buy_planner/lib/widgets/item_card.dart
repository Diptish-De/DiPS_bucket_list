import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/buy_item.dart';

class ItemCard extends StatelessWidget {
  final BuyItem item;
  final VoidCallback onAddFunds;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onAddFunds,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final rupeeFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    double progress = item.price > 0 ? (item.savedAmount / item.price) : 0.0;
    if (progress > 1.0) progress = 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onAddFunds,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAE3), // Light orange background
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.track_changes_outlined,
                color: Color(0xFFFF6D3B), // Bright orange icon
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            // Middle Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% Saved',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Right Side (Price info)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rupeeFormat.format(item.price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Target',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

