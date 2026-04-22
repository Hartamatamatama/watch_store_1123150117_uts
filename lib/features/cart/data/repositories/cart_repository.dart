import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/secure_storage.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final String baseUrl = "http://localhost:8080/v1";

  Future<bool> checkout(List<CartItemModel> items, double totalAmount) async {
    try {
      // 1. Ambil ID Card Golang dari Brankas
      final token = await SecureStorageService.getToken();

      if (token == null) {
        print("Error: Token Backend tidak ditemukan! User harus login ulang.");
        return false;
      }

      // 2. Siapkan data paket JSON beserta alamat pengiriman
      final body = jsonEncode({
        "items": items
            .map(
              (item) => {
                "product_id": item.productId,
                "quantity": item.quantity,
                "price": item.price,
              },
            )
            .toList(),
        "total_amount": totalAmount,
        "order_date": DateTime.now().toIso8601String(),
        "shipping_address":
            "Jl. Merdeka No. 1, Tangerang", // Alamat sementara agar lolos validasi
      });

      // 3. Tembak API
      final response = await http.post(
        Uri.parse("$baseUrl/orders/checkout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      print("Status Code Golang: ${response.statusCode}");
      print("Balasan Golang: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error Checkout: $e");
      return false;
    }
  }
}
