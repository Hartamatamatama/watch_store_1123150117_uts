import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';
import '../routes/app_router.dart';

// 1. Fungsi TOP-LEVEL: Wajib berada di LUAR class agar bisa berjalan saat aplikasi mati!
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🚨 FCM Background Message Terdeteksi: ${message.messageId}");
  // Biarkan OS Android yang memunculkan bannernya secara otomatis.
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 2. Daftarkan Radar Latar Belakang
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Meminta Izin Firebase
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Konfigurasi Notifikasi Lokal (Sistem Android)
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );
    await _localNotifications.initialize(
      settings: initSettings,
      // 4. TAP HANDLER LOKAL: Jika user menekan banner dari flutter_local_notifications
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Banner Lokal Ditekan!');
        _handleNotificationTap();
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
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

      // --- NYAWA 1: FOREGROUND ---
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 Notifikasi Masuk (Foreground)!');

        if (message.notification != null) {
          // A. PAKSA BANNER SISTEM MELUNCUR DARI ATAS
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

          // B. TETAP TAMPILKAN SNACKBAR MEWAH DI BAWAH
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

      // --- NYAWA 2: BACKGROUND TAP ---
      // Menangkap klik banner saat aplikasi sedang minimize (di background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 Banner FCM (Background) Ditekan!');
        _handleNotificationTap();
      });

      // --- NYAWA 3: TERMINATED TAP ---
      // Menangkap klik banner yang membuat aplikasi menyala dari kondisi mati total
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          '🔔 Banner FCM (Terminated) Ditekan! Menyalakan Aplikasi...',
        );
        // Kita beri sedikit delay agar framework Flutter selesai menggambar UI (misal Splash Screen)
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationTap();
        });
      }
    } else {
      debugPrint('FCM: User menolak izin notifikasi.');
    }
  }

  // 5. FUNGSI TELEPORTASI
  // Karena kita belum membuat halaman "My Orders", untuk saat ini kita arahkan user kembali ke Dashboard.
  static void _handleNotificationTap() {
    if (scaffoldMessengerKey.currentContext != null) {
      Navigator.of(
        scaffoldMessengerKey.currentContext!,
      ).pushNamedAndRemoveUntil(
        AppRouter.dashboard,
        (route) => false, // Hapus seluruh tumpukan halaman sebelumnya
      );
    }
  }
}
