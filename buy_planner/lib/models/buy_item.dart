import 'dart:convert';

class BuyItem {
  final String id;
  String name;
  double price;
  double savedAmount;

  BuyItem({
    required this.id,
    required this.name,
    required this.price,
    this.savedAmount = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'savedAmount': savedAmount,
    };
  }

  factory BuyItem.fromMap(Map<String, dynamic> map) {
    return BuyItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      savedAmount: map['savedAmount'] ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BuyItem.fromJson(String source) =>
      BuyItem.fromMap(json.decode(source));
}
