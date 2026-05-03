import 'dart:math';
import 'dart:convert';
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
  String _userName = 'DiPS';
  String _userEmail = '';
  static const double decayBase = 0.5;

  List<BuyItem> get items => _items;
  List<BuyItem> get activeItems => _items.where((i) => !i.isCompleted).toList();
  List<BuyItem> get completedItems => _items.where((i) => i.isCompleted).toList();
  double get expectedMonthlySavings => _expectedMonthlySavings;
  bool get isInit => _isInit;
  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  String get userEmail => _userEmail;
  double get totalSaved => _items.fold(0.0, (s, i) => s + i.savedAmount);
  double get totalTarget => _items.fold(0.0, (s, i) => s + i.price);

  BuyProvider() { _loadData(); }

  // =========== WEIGHTED PRIORITY ALLOCATION ===========

  List<GoalAllocation> calculateTimeline() {
    final active = activeItems;
    if (active.isEmpty || _expectedMonthlySavings <= 0) {
      return active.map((i) => GoalAllocation(item: i, currentMonthlyAmount: 0, currentPercent: 0, completionMonths: -1)).toList();
    }

    Map<String, double> remaining = {};
    for (var item in active) { remaining[item.id] = item.remaining; }

    List<String> order = active.map((i) => i.id).toList();
    Map<String, double> completionMonths = {};
    double elapsed = 0;

    // Current weights for display
    double tw0 = 0;
    List<double> w0 = [];
    for (int i = 0; i < active.length; i++) { double w = pow(decayBase, i).toDouble(); w0.add(w); tw0 += w; }

    while (order.isNotEmpty) {
      double tw = 0;
      List<double> wts = [];
      for (int i = 0; i < order.length; i++) { double w = pow(decayBase, i).toDouble(); wts.add(w); tw += w; }

      double minM = double.infinity;
      int compIdx = 0;
      List<double> allocs = [];
      for (int i = 0; i < order.length; i++) {
        double a = _expectedMonthlySavings * wts[i] / tw;
        allocs.add(a);
        double r = remaining[order[i]]!;
        if (r <= 0) { minM = 0; compIdx = i; break; }
        double m = r / a;
        if (m < minM) { minM = m; compIdx = i; }
      }

      for (int i = 0; i < order.length; i++) { remaining[order[i]] = remaining[order[i]]! - allocs[i] * minM; }
      elapsed += minM;
      completionMonths[order[compIdx]] = elapsed;
      order.removeAt(compIdx);
    }

    List<GoalAllocation> result = [];
    for (int i = 0; i < active.length; i++) {
      double pct = w0[i] / tw0;
      result.add(GoalAllocation(item: active[i], currentMonthlyAmount: _expectedMonthlySavings * pct, currentPercent: pct, completionMonths: completionMonths[active[i].id] ?? -1));
    }
    return result;
  }

  double get totalCompletionMonths {
    final t = calculateTimeline();
    if (t.isEmpty) return 0;
    return t.map((a) => a.completionMonths).reduce(max);
  }

  // =========== DATA OPERATIONS ===========

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _expectedMonthlySavings = prefs.getDouble('expectedMonthlySavings') ?? 0.0;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _userName = prefs.getString('userName') ?? 'DiPS';
    _userEmail = prefs.getString('userEmail') ?? '';
    final itemsJson = prefs.getStringList('buy_items');
    if (itemsJson != null) { _items = itemsJson.map((j) => BuyItem.fromJson(j)).toList(); }
    _isInit = true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('buy_items', _items.map((i) => i.toJson()).toList());
    await prefs.setDouble('expectedMonthlySavings', _expectedMonthlySavings);
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
  }

  void addItem(String name, double price, {String category = 'Other', DateTime? targetDate}) {
    _items.add(BuyItem(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, price: price, category: category, targetDate: targetDate));
    _saveData(); notifyListeners();
  }

  bool addFunds(String id, double amount) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      bool was = !_items[idx].isCompleted;
      _items[idx].savedAmount += amount;
      _items[idx].fundHistory.add(FundEntry(amount: amount, date: DateTime.now()));
      _saveData(); notifyListeners();
      return was && _items[idx].isCompleted;
    }
    return false;
  }

  int? checkMilestoneCrossed(String id, double oldSaved) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx < 0) return null;
    double oldPct = _items[idx].price > 0 ? oldSaved / _items[idx].price : 0;
    double newPct = _items[idx].progress;
    for (int m in [75, 50, 25]) { if (oldPct < m / 100.0 && newPct >= m / 100.0) return m; }
    return null;
  }

  void editItem(String id, {String? name, double? price, String? category, DateTime? targetDate, bool clearTargetDate = false}) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      if (name != null) _items[idx].name = name;
      if (price != null) _items[idx].price = price;
      if (category != null) _items[idx].category = category;
      if (clearTargetDate) _items[idx].targetDate = null;
      else if (targetDate != null) _items[idx].targetDate = targetDate;
      _saveData(); notifyListeners();
    }
  }

  void setExpectedMonthlySavings(double a) { _expectedMonthlySavings = a; _saveData(); notifyListeners(); }
  void toggleDarkMode() { _isDarkMode = !_isDarkMode; _saveData(); notifyListeners(); }
  void setUserName(String n) { _userName = n; _saveData(); notifyListeners(); }
  void setUserEmail(String e) { _userEmail = e; _saveData(); notifyListeners(); }
  void deleteItem(String id) { _items.removeWhere((i) => i.id == id); _saveData(); notifyListeners(); }

  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    _saveData(); notifyListeners();
  }

  /// Export all data as JSON string
  String exportData() {
    return const JsonEncoder.withIndent('  ').convert({
      'userName': _userName, 'userEmail': _userEmail,
      'expectedMonthlySavings': _expectedMonthlySavings,
      'items': _items.map((i) => i.toMap()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    });
  }
}
