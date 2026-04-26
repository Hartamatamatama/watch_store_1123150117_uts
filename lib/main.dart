import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart'; // <-- Amunisi baru diimpor
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/product_provider.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'core/services/fcm_service.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // <-- PERTAMA
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Baca ThemeProvider — widget ini rebuild saat toggle() [cite: 152, 153]
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Watch Store',
      debugShowCheckedModeBanner: false,

      // 2. Daftarkan KEDUA tema [cite: 156]
      theme: AppTheme.light, // ← dipakai saat ThemeMode.light
      darkTheme: AppTheme.dark, // ← dipakai saat ThemeMode.dark
      // 3. Tentukan mode aktif dari provider [cite: 159]
      themeMode: themeProvider
          .themeMode, // ← berubah saat toggle() dipanggil → seluruh app ikut [cite: 160, 161]

      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
    );
  }
}
