import 'package:flutter/material.dart';
import '../../data/models/cart_item_model.dart';
import '../../../dashboard/data/models/product_model.dart';

class CartProvider with ChangeNotifier {
  // Kita gunakan Map agar pencarian barang lebih cepat (Big O(1))
  final Map<int, CartItemModel> _items = {};

  Map<int, CartItemModel> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(ProductModel product) {
    if (_items.containsKey(product.id)) {
      // Jika jam tangan sudah ada di keranjang, tambah jumlahnya
      _items.update(
        product.id,
        (existingItem) => CartItemModel(
          productId: existingItem.productId,
          name: existingItem.name,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      // Jika belum ada, masukkan sebagai barang baru
      _items.putIfAbsent(
        product.id,
        () => CartItemModel(
          productId: product.id,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          quantity: 1,
        ),
      );
    }
    notifyListeners(); // Beri tahu UI untuk update!
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
