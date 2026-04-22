import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Meminta Izin Firebase
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Konfigurasi Notifikasi Lokal (Sistem Android)
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );
    await _localNotifications.initialize(settings: initSettings);

    // 3. Buat Jalur Khusus Berprioritas Maksimal (Ini yang memicu pop-up turun!)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      // description: 'Description untuk channel notifikasi',
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM: Izin notifikasi diberikan oleh user.');

      try {
        String? token = await _messaging.getToken();
        debugPrint('🔔 TOKEN FCM HP INI: $token');
      } catch (e) {
        debugPrint('FCM Error: Gagal mendapatkan token - $e');
      }

      // 4. Menangkap notifikasi saat aplikasi TERBUKA (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 Notifikasi Masuk (Foreground)!');

        if (message.notification != null) {
          // --- A. PAKSA BANNER SISTEM MELUNCUR DARI ATAS ---
          _localNotifications.show(
            id: message.notification.hashCode,
            title: message.notification?.title,
            body: message.notification?.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );

          // --- B. TETAP TAMPILKAN SNACKBAR MEWAH DI BAWAH ---
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1A1A1A),
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
                      const Icon(Icons.watch, color: Color(0xFFC6A87C)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message.notification?.title ?? 'Notifikasi Baru',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC6A87C),
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
