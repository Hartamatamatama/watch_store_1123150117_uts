import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessCheckoutPage extends StatelessWidget {
  const SuccessCheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PENGAMBILAN WARNA DINAMIS DARI TEMA ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    // Tombol beradaptasi: Emas di Dark Mode, Hitam di Light Mode
    final buttonBgColor = isDark
        ? const Color(0xFFC6A87C)
        : const Color(0xFF1A1A1A);
    final buttonTextColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBgColor, // <-- Dinamis
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Icon Centang Mewah dengan Aksen Emas
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC6A87C), width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 60,
                  color: Color(0xFFC6A87C),
                ),
              ),
              const SizedBox(height: 40),

              // 2. Judul Kemenangan
              Text(
                'ORDER CONFIRMED',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  color: const Color(0xFFC6A87C),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A Timeless Choice.',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: onSurfaceColor, // <-- Dinamis
                ),
              ),
              const SizedBox(height: 24),

              // 3. Pesan Deskriptif
              Text(
                'Laporan diterima, Pesanan jam tangan mewahmu telah kami amankan dan sedang diproses oleh tim ahli kami.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  height: 1.6,
                  color: subtitleColor, // <-- Dinamis
                ),
              ),
              const SizedBox(height: 60),

              // 4. Tombol Kembali ke Beranda
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke Dashboard dan hapus semua tumpukan navigasi
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBgColor, // <-- Dinamis
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'BACK TO SHOP',
                    style: GoogleFonts.lato(
                      color: buttonTextColor, // <-- Dinamis
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
