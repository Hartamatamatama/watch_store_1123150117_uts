import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/product_provider.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'core/services/fcm_service.dart';
import 'core/services/biometric_lock_provider.dart';
import 'core/widgets/biometric_lock_screen.dart';
import 'features/order/presentation/providers/order_provider.dart';

// Kunci Global untuk memanggil SnackBar dari luar UI (Service)
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi inti Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- AKTIFKAN RADAR NOTIFIKASI ---
  await FCMService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(
          create: (_) => BiometricLockProvider()..initialize(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Memantau perubahan tema dari provider
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Watch Store',
      debugShowCheckedModeBanner: false,

      // --- PERBAIKAN 1: Sambungkan Kunci SnackBar ---
      scaffoldMessengerKey: scaffoldMessengerKey,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A1A),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC6A87C),
          brightness: Brightness.dark,
        ),
      ),

      // --- PERBAIKAN 2: Hubungkan ThemeMode ke Provider ---
      themeMode: themeProvider.themeMode,

      // --- PERBAIKAN 3: Aktifkan Kembali Routing Utama ---
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,

      // --- PERBAIKAN 4 (Instruksiku Sebelumnya): Hilangkan tanda (!) pada child ---
      builder: (context, child) => BiometricLockScreen(child: child),
    );
  }
}
