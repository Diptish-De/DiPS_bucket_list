import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/buy_item.dart';

class BuyProvider with ChangeNotifier {
  List<BuyItem> _items = [];
  double _expectedMonthlySavings = 0.0;
  bool _isInit = false;
  bool _isDarkMode = false;

  List<BuyItem> get items => _items;
  List<BuyItem> get activeItems => _items.where((i) => !i.isCompleted).toList();
  List<BuyItem> get completedItems => _items.where((i) => i.isCompleted).toList();
  double get expectedMonthlySavings => _expectedMonthlySavings;
  bool get isInit => _isInit;
  bool get isDarkMode => _isDarkMode;

  double get totalSaved {
    return _items.fold(0.0, (sum, item) => sum + item.savedAmount);
  }

  double get totalTarget {
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }

  /// Returns months to complete all active goals, or -1 if no monthly savings set
  double get monthsToComplete {
    if (_expectedMonthlySavings <= 0) return -1;
    double remaining = activeItems.fold(0.0, (sum, item) => sum + (item.price - item.savedAmount));
    if (remaining <= 0) return 0;
    return remaining / _expectedMonthlySavings;
  }

  /// Returns months to complete a specific goal
  double monthsForGoal(BuyItem item) {
    if (_expectedMonthlySavings <= 0 || item.isCompleted) return -1;
    double remaining = item.price - item.savedAmount;
    if (remaining <= 0) return 0;
    return remaining / _expectedMonthlySavings;
  }

  BuyProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _expectedMonthlySavings = prefs.getDouble('expectedMonthlySavings') ?? 0.0;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    final itemsJsonString = prefs.getStringList('buy_items');
    if (itemsJsonString != null) {
      _items = itemsJsonString.map((json) => BuyItem.fromJson(json)).toList();
    }

    _isInit = true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJsonString = _items.map((item) => item.toJson()).toList();
    await prefs.setStringList('buy_items', itemsJsonString);
    await prefs.setDouble('expectedMonthlySavings', _expectedMonthlySavings);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void addItem(String name, double price, {String category = 'Other', DateTime? targetDate}) {
    final newItem = BuyItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      category: category,
      targetDate: targetDate,
    );
    _items.add(newItem);
    _saveData();
    notifyListeners();
  }

  /// Returns true if the goal was JUST completed by this addition (for celebration)
  bool addFunds(String id, double amount) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      bool wasBelowTarget = !_items[index].isCompleted;
      _items[index].savedAmount += amount;
      _items[index].fundHistory.add(FundEntry(amount: amount, date: DateTime.now()));
      _saveData();
      notifyListeners();
      return wasBelowTarget && _items[index].isCompleted;
    }
    return false;
  }

  void editItem(String id, {String? name, double? price, String? category, DateTime? targetDate, bool clearTargetDate = false}) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (name != null) _items[index].name = name;
      if (price != null) _items[index].price = price;
      if (category != null) _items[index].category = category;
      if (clearTargetDate) {
        _items[index].targetDate = null;
      } else if (targetDate != null) {
        _items[index].targetDate = targetDate;
      }
      _saveData();
      notifyListeners();
    }
  }

  void setExpectedMonthlySavings(double amount) {
    _expectedMonthlySavings = amount;
    _saveData();
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveData();
    notifyListeners();
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveData();
    notifyListeners();
  }

  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    _saveData();
    notifyListeners();
  }
}
