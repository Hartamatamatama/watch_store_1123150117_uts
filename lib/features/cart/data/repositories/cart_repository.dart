import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/secure_storage.dart';
import '../../../../core/constants/api_constants.dart'; // <-- Amunisi Markas Pusat ditambahkan
import '../models/cart_item_model.dart';

class CartRepository {
  Future<bool> checkout(List<CartItemModel> items, double totalAmount) async {
    try {
      final token = await SecureStorageService.getToken();

      if (token == null) {
        print("Error: Token Backend tidak ditemukan!");
        return false;
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      // --- OPERASI SINKRONISASI KILAT ---
      // Memasukkan barang dari lokal ke database Golang satu per satu
      print("Memulai sinkronisasi keranjang ke Golang...");
      for (var item in items) {
        final cartBody = jsonEncode({
          "product_id": item.productId,
          "quantity": item.quantity,
        });

        // Menggunakan ApiConstants.baseUrl
        await http.post(
          Uri.parse("${ApiConstants.baseUrl}/cart"),
          headers: headers,
          body: cartBody,
        );
      }
      print("Sinkronisasi selesai! Database Golang sudah terisi.");
      // ----------------------------------

      // --- EKSEKUSI CHECKOUT ---
      // Ambil Token FCM HP ini secara diam-diam
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final checkoutBody = jsonEncode({
        "shipping_address": "Jl. Merdeka No. 1, Tangerang",
        "fcm_token": fcmToken ?? "", // Selipkan token ke paket Golang!
      });

      // Menggunakan ApiConstants.baseUrl
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/orders/checkout"),
        headers: headers,
        body: checkoutBody,
      );

      print("Status Code Checkout: ${response.statusCode}");
      print("Balasan Checkout: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error Checkout: $e");
      return false;
    }
  }
}
