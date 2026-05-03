import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/buy_item.dart';

class GoalAllocation {
  final BuyItem item;
  final double currentMonthlyAmount;
  final double currentPercent;
  final double completionMonths;

  GoalAllocation({required this.item, required this.currentMonthlyAmount, required this.currentPercent, required this.completionMonths});

  DateTime get completionDate => DateTime.now().add(Duration(days: (completionMonths * 30.44).round()));
}

class BuyProvider with ChangeNotifier {
  List<BuyItem> _items = [];
  double _expectedMonthlySavings = 0.0;
  bool _isInit = false;
  bool _isDarkMode = false;
  static const double decayBase = 0.5;

  List<BuyItem> get items => _items;
  List<BuyItem> get activeItems => _items.where((i) => !i.isCompleted).toList();
  List<BuyItem> get completedItems => _items.where((i) => i.isCompleted).toList();
  double get expectedMonthlySavings => _expectedMonthlySavings;
  bool get isInit => _isInit;
  bool get isDarkMode => _isDarkMode;

  double get totalSaved => _items.fold(0.0, (s, i) => s + i.savedAmount);
  double get totalTarget => _items.fold(0.0, (s, i) => s + i.price);

  BuyProvider() { _loadData(); }

  // =========== WEIGHTED PRIORITY ALLOCATION ===========

  /// Calculate current allocations for all active goals
  List<GoalAllocation> calculateAllocations() {
    final active = activeItems;
    if (active.isEmpty || _expectedMonthlySavings <= 0) return [];

    // Calculate weights
    double totalWeight = 0;
    List<double> weights = [];
    for (int i = 0; i < active.length; i++) {
      double w = pow(decayBase, i).toDouble();
      weights.add(w);
      totalWeight += w;
    }

    // Calculate current monthly amounts
    List<GoalAllocation> result = [];
    for (int i = 0; i < active.length; i++) {
      double pct = weights[i] / totalWeight;
      double monthly = _expectedMonthlySavings * pct;
      result.add(GoalAllocation(
        item: active[i],
        currentMonthlyAmount: monthly,
        currentPercent: pct,
        completionMonths: 0, // filled by timeline
      ));
    }
    return result;
  }

  /// Calculate full timeline with cascading completion
  List<GoalAllocation> calculateTimeline() {
    final active = activeItems;
    if (active.isEmpty || _expectedMonthlySavings <= 0) {
      return active.map((i) => GoalAllocation(item: i, currentMonthlyAmount: 0, currentPercent: 0, completionMonths: -1)).toList();
    }

    // Simulation: track remaining amounts
    Map<String, double> remaining = {};
    for (var item in active) {
      remaining[item.id] = item.remaining;
    }

    List<String> order = active.map((i) => i.id).toList();
    Map<String, double> completionMonths = {};
    double elapsed = 0;

    // Current allocations for display
    double totalWeight0 = 0;
    List<double> weights0 = [];
    for (int i = 0; i < active.length; i++) {
      double w = pow(decayBase, i).toDouble();
      weights0.add(w);
      totalWeight0 += w;
    }

    while (order.isNotEmpty) {
      // Calculate weights for remaining goals
      double totalWeight = 0;
      List<double> weights = [];
      for (int i = 0; i < order.length; i++) {
        double w = pow(decayBase, i).toDouble();
        weights.add(w);
        totalWeight += w;
      }

      // Find which goal finishes first in this phase
      double minMonths = double.infinity;
      int completingIdx = 0;
      List<double> allocations = [];

      for (int i = 0; i < order.length; i++) {
        double alloc = _expectedMonthlySavings * weights[i] / totalWeight;
        allocations.add(alloc);
        double rem = remaining[order[i]]!;
        if (rem <= 0) {
          minMonths = 0;
          completingIdx = i;
          break;
        }
        double months = rem / alloc;
        if (months < minMonths) {
          minMonths = months;
          completingIdx = i;
        }
      }

      // Advance time, fund all goals for this period
      for (int i = 0; i < order.length; i++) {
        remaining[order[i]] = remaining[order[i]]! - allocations[i] * minMonths;
      }

      // Record completion
      elapsed += minMonths;
      completionMonths[order[completingIdx]] = elapsed;
      order.removeAt(completingIdx);
    }

    // Build result with current allocations
    List<GoalAllocation> result = [];
    for (int i = 0; i < active.length; i++) {
      double pct = weights0[i] / totalWeight0;
      double monthly = _expectedMonthlySavings * pct;
      result.add(GoalAllocation(
        item: active[i],
        currentMonthlyAmount: monthly,
        currentPercent: pct,
        completionMonths: completionMonths[active[i].id] ?? -1,
      ));
    }
    return result;
  }

  double get totalCompletionMonths {
    final timeline = calculateTimeline();
    if (timeline.isEmpty) return 0;
    return timeline.map((a) => a.completionMonths).reduce(max);
  }

  // =========== DATA OPERATIONS ===========

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _expectedMonthlySavings = prefs.getDouble('expectedMonthlySavings') ?? 0.0;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final itemsJson = prefs.getStringList('buy_items');
    if (itemsJson != null) {
      _items = itemsJson.map((j) => BuyItem.fromJson(j)).toList();
    }
    _isInit = true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('buy_items', _items.map((i) => i.toJson()).toList());
    await prefs.setDouble('expectedMonthlySavings', _expectedMonthlySavings);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void addItem(String name, double price, {String category = 'Other', DateTime? targetDate}) {
    _items.add(BuyItem(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, price: price, category: category, targetDate: targetDate));
    _saveData();
    notifyListeners();
  }

  /// Returns true if goal was JUST completed
  bool addFunds(String id, double amount) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      bool wasBelowTarget = !_items[idx].isCompleted;
      _items[idx].savedAmount += amount;
      _items[idx].fundHistory.add(FundEntry(amount: amount, date: DateTime.now()));
      _saveData();
      notifyListeners();
      return wasBelowTarget && _items[idx].isCompleted;
    }
    return false;
  }

  /// Returns the milestone that was JUST crossed (25, 50, 75) or null
  int? checkMilestoneCrossed(String id, double oldSaved) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx < 0) return null;
    final item = _items[idx];
    double oldPct = item.price > 0 ? oldSaved / item.price : 0;
    double newPct = item.progress;
    for (int m in [75, 50, 25]) {
      if (oldPct < m / 100.0 && newPct >= m / 100.0) return m;
    }
    return null;
  }

  void editItem(String id, {String? name, double? price, String? category, DateTime? targetDate, bool clearTargetDate = false}) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      if (name != null) _items[idx].name = name;
      if (price != null) _items[idx].price = price;
      if (category != null) _items[idx].category = category;
      if (clearTargetDate) { _items[idx].targetDate = null; }
      else if (targetDate != null) { _items[idx].targetDate = targetDate; }
      _saveData();
      notifyListeners();
    }
  }

  void setExpectedMonthlySavings(double amount) {
    _expectedMonthlySavings = amount;
    _saveData();
    notifyListeners();
  }

  void toggleDarkMode() { _isDarkMode = !_isDarkMode; _saveData(); notifyListeners(); }

  void deleteItem(String id) { _items.removeWhere((i) => i.id == id); _saveData(); notifyListeners(); }

  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    _saveData();
    notifyListeners();
  }
}
