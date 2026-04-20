import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../data/models/product_model.dart';
import 'package:flutter/foundation.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  String? _error;

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String? get error => _error;
  bool get isLoading => _status == ProductStatus.loading;

  // Fetch products — token otomatis disertakan oleh DioClient interceptor
  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      final response = await DioClient.instance.get(ApiConstants.products);

      // 1. TAMBAHKAN INI UNTUK MENGINTIP ISI PAKET DARI GOLANG
      debugPrint("📦 ISI JSON DARI GOLANG: ${response.data}");

      final List<dynamic> data = response.data['data'];
      _products = data.map((e) => ProductModel.fromJson(e)).toList();
      _status = ProductStatus.loaded;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Gagal memuat produk';
      _status = ProductStatus.error;
    } catch (e, stacktrace) {
      // 2. TAMBAHKAN INI UNTUK MELIHAT FLUTTER TERSEDIAK DI BAGIAN MANA
      debugPrint("🚨 ERROR FLUTTER: $e\n$stacktrace");

      // 3. TAMPILKAN ERROR ASLINYA KE LAYAR DASHBOARD
      _error = 'Gagal Parsing: $e';
      _status = ProductStatus.error;
    }

    notifyListeners();
  }
}
