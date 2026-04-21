import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item_model.dart';

class CartRepository {
  // Alamat backend Golang kamu
  final String baseUrl = "http://localhost:8080/api";

  Future<bool> checkout(List<CartItemModel> items, double totalAmount) async {
    try {
      // 1. Siapkan data untuk dikirim (Mapping ke JSON)
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
      });

      // 2. Tembak API Golang
      final response = await http.post(
        Uri.parse("$baseUrl/orders"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      // 3. Cek hasil
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error Checkout: $e");
      return false;
    }
  }
}
