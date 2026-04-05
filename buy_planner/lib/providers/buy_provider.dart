import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/buy_item.dart';

class BuyProvider with ChangeNotifier {
  List<BuyItem> _items = [];
  double _expectedMonthlySavings = 0.0;
  bool _isInit = false;

  List<BuyItem> get items => _items;
  double get expectedMonthlySavings => _expectedMonthlySavings;
  bool get isInit => _isInit;

  double get totalSaved {
    return _items.fold(0.0, (sum, item) => sum + item.savedAmount);
  }

  BuyProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _expectedMonthlySavings = prefs.getDouble('expectedMonthlySavings') ?? 0.0;
    
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
  }

  void addItem(String name, double price) {
    final newItem = BuyItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
    );
    _items.add(newItem);
    _saveData();
    notifyListeners();
  }

  void addFunds(String id, double amount) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].savedAmount += amount;
      _saveData();
      notifyListeners();
    }
  }

  void setExpectedMonthlySavings(double amount) {
    _expectedMonthlySavings = amount;
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
