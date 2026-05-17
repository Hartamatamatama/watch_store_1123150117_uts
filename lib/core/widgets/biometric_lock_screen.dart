import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/biometric_lock_provider.dart';

class BiometricLockScreen extends StatefulWidget {
  final Widget? child; // <-- Ubah menjadi nullable (tambahkan tanda tanya)
  const BiometricLockScreen({super.key, this.child}); // <-- Hapus required

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  static const _lockTimeout = Duration(seconds: 30); // Batas waktu 30 detik

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Trigger unlock otomatis saat pertama kali aplikasi dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BiometricLockProvider>().unlock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<BiometricLockProvider>();

    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final backgrounded = _backgroundedAt;
      if (backgrounded != null) {
        // --- TAMBALAN KRITIS: Reset waktu agar tidak terjadi infinite loop ---
        _backgroundedAt = null;

        final elapsed = DateTime.now().difference(backgrounded);
        if (elapsed >= _lockTimeout) {
          provider.lock();
          provider.unlock(); // Tampilkan dialog sensor
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BiometricLockProvider>();

    // Penyesuaian tema Luxury Watch Store
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final accentColor = isDark
        ? const Color(0xFFC6A87C)
        : const Color(0xFF1A1A1A);

    if (provider.isLocked) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: accentColor),
              const SizedBox(height: 16),
              Text(
                'APP LOCKED',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 8),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: provider.unlock,
                icon: Icon(
                  Icons.fingerprint,
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                ),
                label: Text(
                  'UNLOCK',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ), // Bentuk kotak tegas
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child ??
        const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
