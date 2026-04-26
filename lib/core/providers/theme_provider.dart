import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Secara default, aplikasi dimulai dengan mode terang (false)
  bool _isDark = false;

  // Getter untuk membaca status saat ini
  bool get isDark => _isDark;

  // Menghasilkan ThemeMode yang akan dibaca oleh MaterialApp
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  // Fungsi saklar: membalikkan keadaan dan memberitahu seluruh aplikasi
  void toggle() {
    _isDark = !_isDark;
    notifyListeners(); // Memicu rebuild pada semua widget yang mendengarkan
  }
}
