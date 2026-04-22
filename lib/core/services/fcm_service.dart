import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

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
          debugPrint('Judul: ${message.notification?.title}');
          debugPrint('Pesan: ${message.notification?.body}');
        }
      });
    } else {
      debugPrint('FCM: User menolak izin notifikasi.');
    }
  }
}
