import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/snackbar_helper.dart'; // Senjata Universal Kita
import '../providers/auth_provider.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  bool _resendCooldown = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Polling: cek setiap 5 detik apakah email sudah diverifikasi
  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final success = await auth.checkEmailVerified();
      if (success && mounted) {
        _timer?.cancel();

        // Munculkan notifikasi sukses tanpa antre!
        SnackBarHelper.showSuccess('Email verified successfully! Welcome.');
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;
    await context.read<AuthProvider>().resendVerificationEmail();

    // Cooldown 60 detik sebelum bisa kirim lagi
    setState(() {
      _resendCooldown = true;
      _countdown = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        t.cancel();
        setState(() => _resendCooldown = false);
      }
    });

    if (mounted) {
      // Gunakan senjata Helper agar instan!
      SnackBarHelper.showSuccess(
        'Verification link has been resent to your email.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().firebaseUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Ikon Mewah (Emas)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC6A87C),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 40,
                  color: Color(0xFFC6A87C),
                ),
              ),
              const SizedBox(height: 32),

              // 2. Judul Kemenangan (Tipografi Butik)
              Text(
                'VERIFY YOUR EMAIL',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  color: const Color(0xFFC6A87C),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Exclusive Access Awaits.',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Pesan Deskriptif
              Text(
                'We have sent a secure verification link to the email address below.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // 4. Kotak Email Minimalis
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  user?.email ?? 'Unknown Email',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 5. Indikator Polling Elegan
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFC6A87C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Awaiting confirmation...',
                    style: GoogleFonts.lato(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 6. Tombol Kirim Ulang (Solid Black)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resendCooldown ? null : _resendEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    _resendCooldown
                        ? 'RESEND IN ${_countdown}S'
                        : 'RESEND EMAIL',
                    style: GoogleFonts.lato(
                      color: _resendCooldown
                          ? Colors.grey.shade600
                          : Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 7. Tombol Ganti Akun / Logout (Teks Transparan)
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
                child: Text(
                  'CHANGE ACCOUNT',
                  style: GoogleFonts.lato(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 10,
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
