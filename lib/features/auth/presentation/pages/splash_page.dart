import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import ke halaman login (satu folder)
import 'login_page.dart';
// Import ke halaman dashboard (lompat 3 folder ke atas, lalu masuk ke dashboard)
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../../core/services/global_institute_pay_service.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../order/data/models/order_model.dart';

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

    if (!mounted) return;

    // Cek pending callback pembayaran (cold start dari Dompet Kampus)
    final pending = GlobalInstitutePayService().consumePendingCallback();
    if (pending != null && pending.isSuccess) {
      // Parse orderId dari reference (format: INV-123)
      final ref = pending.reference ?? '';
      final orderId = int.tryParse(ref.replaceAll('INV-', ''));
      OrderModel? order;
      if (orderId != null) {
        // Update status order ke processing + kurangi stok
        try {
          await DioClient.instance.put(
            '${ApiConstants.orders}/$orderId/confirm-payment',
          );
          // Ambil data order real
          final resp = await DioClient.instance.get(
            '${ApiConstants.orders}/$orderId',
          );
          if (resp.data['success'] == true) {
            order = OrderModel.fromJson(resp.data['data'] as Map<String, dynamic>);
          }
        } catch (_) {}
      }

      Navigator.pushReplacementNamed(context, AppRouter.orderSuccess,
        arguments: order ?? OrderModel(
          id: orderId ?? 0,
          totalAmount: 0,
          status: 'processing',
          shippingAddress: '',
          notes: '',
          paymentMethod: 'global_institute_pay',
          items: [],
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      return;
    }

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
