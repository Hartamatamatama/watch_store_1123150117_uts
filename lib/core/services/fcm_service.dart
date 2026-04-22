import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 1. Meminta Izin (Sangat wajib untuk Android 13+ dan iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM: Izin notifikasi diberikan oleh user.');

      // 2. Mengambil Token Unik HP (Alamat Kotak Pos)
      try {
        String? token = await _messaging.getToken();
        debugPrint('🔔 TOKEN FCM HP INI: $token');
        // TODO: Nanti token ini akan kita kirim ke Golang
      } catch (e) {
        debugPrint('FCM Error: Gagal mendapatkan token - $e');
      }

      // 3. Menangkap notifikasi saat aplikasi sedang TERBUKA (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 Notifikasi Masuk (Foreground)!');

        if (message.notification != null) {
          // Memunculkan Notifikasi In-App dengan tema Luxury Boutique
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1A1A1A), // Warna Hitam Premium
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 5),
              margin: const EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.watch,
                        color: Color(0xFFC6A87C),
                      ), // Ikon Emas
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message.notification?.title ?? 'Notifikasi Baru',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC6A87C), // Warna Emas Premium
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.notification?.body ?? '',
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        }
      });
    } else {
      debugPrint('FCM: User menolak izin notifikasi.');
    }
  }
}
