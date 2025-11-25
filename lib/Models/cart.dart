import 'package:flutter/material.dart';
import 'producto.dart';

class CartItem {
  final Producto product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get unitPrice => product.precio ?? 0.0;

  double get total => unitPrice * quantity;
}

class CartModel extends ChangeNotifier {
  // CartModel._private();
  // static final CartModel instance = CartModel._private();

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalItems => _items.values.fold(0, (s, i) => s + i.quantity);

  double get totalPrice => _items.values.fold(0.0, (s, i) => s + i.total);

  int getQuantity(Producto p) => _items[p.nombreProducto]?.quantity ?? 0;

  void addProduct(Producto p) {
    final key = p.nombreProducto;
    if (_items.containsKey(key)) {
      _items[key]!.quantity++;
    } else {
      _items[key] = CartItem(product: p);
    }
    notifyListeners();
  }

  void removeOne(Producto p) {
    final key = p.nombreProducto;
    if (!_items.containsKey(key)) return;
    if (_items[key]!.quantity > 1) {
      _items[key]!.quantity--;
    } else {
      _items.remove(key);
    }
    notifyListeners();
  }

  void removeAll(Producto p) {
    _items.remove(p.nombreProducto);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
