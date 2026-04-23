import 'package:flutter/material.dart';
// Sesuaikan import ini dengan lokasi main.dart milikmu
import '../../main.dart';

class SnackBarHelper {
  // Fungsi Universal untuk Sukses (Warna Hitam Elegan)
  static void showSuccess(String message) {
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar() // SECARA OTOMATIS HAPUS YANG LAMA
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1A1A1A), // Tema Butik
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // Fungsi Universal untuk Error (Warna Merah)
  static void showError(String message) {
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar() // SECARA OTOMATIS HAPUS YANG LAMA
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
