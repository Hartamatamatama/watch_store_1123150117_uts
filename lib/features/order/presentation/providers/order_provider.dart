import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository_impl.dart';

enum OrderStatus { initial, loading, success, error }

class OrderProvider extends ChangeNotifier {
  final OrderRepositoryImpl _repository = OrderRepositoryImpl();

  OrderStatus _checkoutStatus = OrderStatus.initial;
  OrderStatus get checkoutStatus => _checkoutStatus;

  // Menyimpan pesanan terakhir agar bisa ditampilkan di OrderSuccessPage
  OrderModel? _lastOrder;
  OrderModel? get lastOrder => _lastOrder;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  String? _error;
  String? get error => _error;

  Future<bool> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    _checkoutStatus = OrderStatus.loading;
    notifyListeners();

    try {
      _lastOrder = await _repository.checkout(
        shippingAddress: shippingAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );
      _checkoutStatus = OrderStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal melakukan checkout: ${e.toString()}';
      _checkoutStatus = OrderStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyOrders() async {
    _checkoutStatus = OrderStatus.loading;
    notifyListeners();

    try {
      _orders = await _repository.getMyOrders();
      _checkoutStatus = OrderStatus
          .success; // Bisa disesuaikan logicnya jika butuh status terpisah
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat pesanan: ${e.toString()}';
      _checkoutStatus = OrderStatus.error;
      notifyListeners();
    }
  }
}
