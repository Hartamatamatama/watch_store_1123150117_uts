import 'package:flutter/material.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final CartRepository _repository = CartRepository();

  // Ubah tipe data kembalian dari void menjadi bool agar UI tahu statusnya
  bool addItem(ProductModel product) {
    final currentStock = product.stock ?? 0; // Ambil info stok dari database

    if (_items.containsKey(product.id)) {
      // PERTAHANAN 1: Cegah jika jumlah di keranjang sudah mencapai batas stok
      if (_items[product.id]!.quantity >= currentStock) {
        return false; // TOLAK!
      }

      // Jika masih aman, tambah jumlahnya
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
      // PERTAHANAN 2: Cegah barang masuk jika stok di database memang 0 (Habis)
      if (currentStock < 1) {
        return false; // TOLAK!
      }

      // Jika belum ada dan stok tersedia, masukkan sebagai barang baru
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
    return true; // BERHASIL!
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> processCheckout() async {
    _isLoading = true;
    notifyListeners();

    final success = await _repository.checkout(
      _items.values.toList(),
      totalAmount,
    );

    if (success) {
      clearCart(); // Kosongkan keranjang jika sukses
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
