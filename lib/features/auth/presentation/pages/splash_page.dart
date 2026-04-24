import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import ke halaman login (satu folder)
import 'login_page.dart';
// Import ke halaman dashboard (lompat 3 folder ke atas, lalu masuk ke dashboard)
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Berikan jeda 2 detik agar logo toko jam-mu terlihat
    await Future.delayed(const Duration(seconds: 2));

    // Cek apakah ada user yang sudah login di Firebase
    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // Jika sudah login, langsung lempar ke halaman Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      // Jika belum login, arahkan ke halaman Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon jam sementara
            Icon(Icons.watch, size: 100, color: Color(0xFFC6A87C)),
            SizedBox(height: 20),
            Text(
              'HARTAMA WATCH STORE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(), // Loading berputar
          ],
        ),
      ),
    );
  }
}
