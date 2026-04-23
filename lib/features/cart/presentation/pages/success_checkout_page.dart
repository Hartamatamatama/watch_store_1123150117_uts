import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessCheckoutPage extends StatelessWidget {
  const SuccessCheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Pesan Deskriptif
              Text(
                'Laporan diterima, Komandan! Pesanan jam tangan mewahmu telah kami amankan dan sedang diproses oleh tim ahli kami.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 60),

              // 4. Tombol Kembali ke Beranda (Solid Black)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke Dashboard dan hapus semua tumpukan navigasi
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'BACK TO SHOP',
                    style: GoogleFonts.lato(
                      color: Colors.white,
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
