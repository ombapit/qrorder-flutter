import 'package:flutter/material.dart';
import 'package:flutter_pos/models/cart_item.dart';
import 'package:flutter_pos/models/product.dart';

enum DeliveryType { dineIn, takeAway }

class OrderProvider extends ChangeNotifier {
  String _outlet = '';
  int _tableNumber = 0;
  Map<String, CartItem> _cart = {};
  String _buyerName = '';
  String _buyerPhone = '';

  String? get outlet => _outlet;
  int get tableNumber => _tableNumber;
  Map<String, CartItem> get cart => _cart;
  String get buyerName => _buyerName;
  String get buyerPhone => _buyerPhone;

  void setOutlet(String outletName, int tableNumber) {
    // ✅ set outlet
    _outlet = outletName;
    _tableNumber = tableNumber;
    notifyListeners();
  }

  void addToCart(Product item) {
    if (_cart.containsKey(item.id)) {
      _cart[item.id]!.qty++;
    } else {
      _cart[item.id] = CartItem(product: item);
    }
    notifyListeners();
  }

  void decreaseFromCart(Product p) {
    if (!_cart.containsKey(p.id)) return;
    final item = _cart[p.id]!;
    if (item.qty > 1) {
      item.qty -= 1;
    } else {
      _cart.remove(p.id);
    }
    notifyListeners();
  }

  void clearCart() {
    _cart = {};
    notifyListeners();
  }

  void setBuyerInfo({String? name, String? phone, String? table}) {
    if (name != null) _buyerName = name;
    if (phone != null) _buyerPhone = phone;
    notifyListeners();
  }

  int get totalItems => _cart.values.fold(0, (sum, item) => sum + item.qty);
  // int get totalPrice =>
  //     _cart.values.fold(0, (sum, item) => sum + item.qty * item.product.price);
  int get total_price =>
      _cart.values.fold(0, (sum, item) => sum + item.subtotal);
}
