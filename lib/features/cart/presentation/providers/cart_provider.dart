import 'package:flutter/foundation.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository_impl.dart';

// Definisi status sesuai instruksi dokumen
enum CartStatus { initial, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  final CartRepositoryImpl _repository = CartRepositoryImpl();

  CartStatus _status = CartStatus.initial;
  CartStatus get status => _status;

  CartModel? _cart;
  CartModel? get cart => _cart;

  String? _error;
  String? get error => _error;

  // Flag khusus agar tombol "Tambah ke Keranjang" bisa menampilkan spinner
  bool _isAdding = false;
  bool get isAdding => _isAdding;

  // Flag khusus refresh background tanpa set loading — hindari kedip
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  // Getter untuk badge notifikasi di bottom nav
  int get itemCount => _cart?.itemCount ?? 0;

  // Getter tambahan untuk total harga keranjang
  double get totalAmount => _cart?.total ?? 0.0;

  Future<void> fetchCart() async {
    _status = CartStatus.loading;
    notifyListeners();
    try {
      _cart = await _repository.getCart();
      _status = CartStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = CartStatus.error;
    }
    notifyListeners();
  }

  /// Refresh cart tanpa set loading — biar gak kedip
  Future<void> _refreshCart() async {
    _isRefreshing = true;
    try {
      _cart = await _repository.getCart();
      _status = CartStatus.loaded;
    } catch (e) {
      _error = e.toString();
    }
    _isRefreshing = false;
    notifyListeners();
  }

  Future<bool> addToCart(int productId, int quantity) async {
    _isAdding = true;
    notifyListeners();
    try {
      await _repository.addToCart(productId, quantity);
      await _refreshCart(); // Refresh tanpa loading biar gak kedip
      _isAdding = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAdding = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateItem(int cartItemId, int quantity) async {
    try {
      await _repository.updateCartItem(cartItemId, quantity);
      await _refreshCart(); // Refresh tanpa loading biar gak kedip
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await _repository.removeCartItem(cartItemId);
      await _refreshCart(); // Refresh tanpa loading biar gak kedip
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      // Langsung set state ke kosong tanpa request ulang API agar lebih instan
      _cart = const CartModel(items: [], total: 0, itemCount: 0);
      _status = CartStatus.loaded;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
