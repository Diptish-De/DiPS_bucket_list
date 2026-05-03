import 'dart:convert';

class FundEntry {
  final double amount;
  final DateTime date;

  FundEntry({required this.amount, required this.date});

  Map<String, dynamic> toMap() => {'amount': amount, 'date': date.toIso8601String()};

  factory FundEntry.fromMap(Map<String, dynamic> map) => FundEntry(
    amount: (map['amount'] as num).toDouble(),
    date: DateTime.parse(map['date']),
  );
}

class BuyItem {
  final String id;
  String name;
  double price;
  double savedAmount;
  String category;
  DateTime? targetDate;
  DateTime createdAt;
  List<FundEntry> fundHistory;

  BuyItem({
    required this.id, required this.name, required this.price,
    this.savedAmount = 0.0, this.category = 'Other', this.targetDate,
    DateTime? createdAt, List<FundEntry>? fundHistory,
  }) : createdAt = createdAt ?? DateTime.now(), fundHistory = fundHistory ?? [];

  bool get isCompleted => savedAmount >= price;
  double get progress => price > 0 ? (savedAmount / price).clamp(0.0, 1.0) : 0.0;
  double get remaining => (price - savedAmount).clamp(0.0, double.infinity);

  int? get daysLeft {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  // Milestones
  int get nextMilestonePercent {
    if (progress >= 1.0) return 100;
    if (progress >= 0.75) return 100;
    if (progress >= 0.50) return 75;
    if (progress >= 0.25) return 50;
    return 25;
  }

  int get lastMilestonePercent {
    if (progress >= 1.0) return 100;
    if (progress >= 0.75) return 75;
    if (progress >= 0.50) return 50;
    if (progress >= 0.25) return 25;
    return 0;
  }

  double get amountToNextMilestone {
    double target = (nextMilestonePercent / 100.0) * price;
    return (target - savedAmount).clamp(0.0, double.infinity);
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'price': price, 'savedAmount': savedAmount,
    'category': category,
    'targetDate': targetDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'fundHistory': fundHistory.map((e) => e.toMap()).toList(),
  };

  factory BuyItem.fromMap(Map<String, dynamic> map) => BuyItem(
    id: map['id'], name: map['name'],
    price: (map['price'] as num).toDouble(),
    savedAmount: (map['savedAmount'] as num?)?.toDouble() ?? 0.0,
    category: map['category'] ?? 'Other',
    targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
    createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    fundHistory: map['fundHistory'] != null
        ? (map['fundHistory'] as List).map((e) => FundEntry.fromMap(e)).toList() : [],
  );

  String toJson() => json.encode(toMap());
  factory BuyItem.fromJson(String source) => BuyItem.fromMap(json.decode(source));
}
