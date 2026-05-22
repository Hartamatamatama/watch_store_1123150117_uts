import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository_impl.dart';

class OrderProvider extends ChangeNotifier {
  // Memanggil pasukan eksekutor yang baru saja kita perbaiki jalurnya
  final OrderRepositoryImpl _repository = OrderRepositoryImpl();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<OrderModel> _myOrders = [];
  List<OrderModel> get myOrders => _myOrders;

  // Operasi 1: Eksekusi Checkout
  Future<bool> processCheckout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.checkout(
        shippingAddress: shippingAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal melakukan checkout: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Operasi 2: Mengambil Riwayat Pesanan
  Future<void> fetchMyOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myOrders = await _repository.getMyOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat pesanan: ${e.toString()}';
      notifyListeners();
    }
  }
}