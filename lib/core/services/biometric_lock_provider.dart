import 'package:flutter/foundation.dart';
import 'package:flutter_biometric_kit/flutter_biometric_kit.dart'; // <-- Memanggil amunisi dari library eksternal kita

class BiometricLockProvider extends ChangeNotifier {
  final BiometricService _service = BiometricService();
  bool _isLocked = false;
  bool _isBiometricAvailable = false;
  String? _errorMessage;

  bool get isLocked => _isLocked;
  bool get isBiometricAvailable => _isBiometricAvailable;
  String? get errorMessage => _errorMessage;

  // Panggil saat app init — cek apakah hardware biometrik tersedia
  Future<void> initialize() async {
    _isBiometricAvailable = await _service.isBiometricAvailable();
    notifyListeners();
  }

  // Panggil saat app masuk background (timer 30 detik)
  void lock() {
    if (_isBiometricAvailable) {
      _isLocked = true;
      notifyListeners();
    }
  }

  // Panggil untuk mulai proses unlock
  Future<void> unlock() async {
    if (!_isBiometricAvailable) {
      _isLocked = false;
      notifyListeners();
      return;
    }

    try {
      await _service.authenticate(
        reason: 'Autentikasi diperlukan untuk mengakses Watch Store',
      );
      _isLocked = false;
      _errorMessage = null;
    } on BiometricException catch (e) {
      _errorMessage = e.userMessage;
    } finally {
      notifyListeners();
    }
  }
}
