import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // Pasukan Keamanan Firebase
import '../models/cart_item_model.dart';

class CartRepository {
  final String baseUrl = "http://localhost:8080/v1";

  Future<bool> checkout(List<CartItemModel> items, double totalAmount) async {
    try {
      // 1. Ambil ID Card (Token) dari user yang sedang login
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Error: User belum login!");
        return false;
      }
      final token = await user.getIdToken();

      // 2. Siapkan data paket
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

      // 3. Tembak API dengan URL yang benar dan sertakan Token JWT
      final response = await http.post(
        Uri.parse("$baseUrl/orders/checkout"), // Penambahan /checkout
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $token", // Menunjukkan ID Card ke Middleware Golang
        },
        body: body,
      );

      // (Opsional) Cetak respons dari server untuk pemantauan terminal
      print("Status Code Golang: ${response.statusCode}");
      print("Balasan Golang: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error Checkout: $e");
      return false;
    }
  }
}
