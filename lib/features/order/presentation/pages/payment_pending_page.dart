import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/global_institute_pay_service.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

/// Halaman yang muncul setelah user memilih bayar dengan Global Institute Pay.
///
/// Menampilkan status menunggu, membuka Dompet Kampus via deeplink,
/// dan mendengarkan callback untuk navigasi ke halaman sukses.
class PaymentPendingPage extends StatefulWidget {
  final int orderId;
  final double amount;
  final String description;

  const PaymentPendingPage({
    super.key,
    required this.orderId,
    required this.amount,
    this.description = '',
  });

  @override
  State<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends State<PaymentPendingPage> {
  StreamSubscription<PaymentCallbackData>? _subscription;
  bool _timeout = false;

  @override
  void initState() {
    super.initState();

    // Dengarkan callback dari GlobalInstitutePayService
    final service = GlobalInstitutePayService();
    _subscription = service.onCallback.listen(_onCallback);

    // Cek pending callback (cold start)
    final pending = service.consumePendingCallback();
    if (pending != null) {
      _onCallback(pending);
      return;
    }

    // Buka Dompet Kampus via deeplink
    _launchDeeplink();

    // Timeout handler
    Future.delayed(const Duration(seconds: 120), () {
      if (mounted) setState(() => _timeout = true);
    });
  }

  void _onCallback(PaymentCallbackData data) async {
    if (!mounted) return;
    _subscription?.cancel();

    final cartProv = context.read<CartProvider>();

    if (data.isSuccess) {
      cartProv.clearCart();
      // Update status order di backend dari pending → processing
      try {
        await DioClient.instance.put(
          '${ApiConstants.orders}/${widget.orderId}/confirm-payment',
        );
      } catch (_) {
        // Gagal update status bukan bencana — order tetap ada
      }
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.orderSuccess,
        (route) => route.settings.name == AppRouter.dashboard,
        arguments: {
          'orderId': widget.orderId,
          'amount': widget.amount,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data.status == 'cancelled'
                ? 'Pembayaran dibatalkan'
                : 'Pembayaran gagal',
          ),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _launchDeeplink() async {
    final url = GlobalInstitutePayService.buildDeeplinkUrl(
      orderId: widget.orderId,
      amount: widget.amount,
      description: widget.description,
    );

    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aplikasi Dompet Kampus tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buttonColor = isDark ? const Color(0xFFC6A87C) : const Color(0xFF1A1A1A);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PEMBAYARAN',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _timeout ? Icons.timer_off : Icons.watch,
                size: 80,
                color: _timeout ? Colors.red : buttonColor,
              ),
              const SizedBox(height: 32),
              Text(
                _timeout
                    ? 'Waktu habis'
                    : 'Menunggu pembayaran...',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _timeout
                    ? 'Pembayaran tidak selesai dalam batas waktu'
                    : 'Silakan selesaikan pembayaran di aplikasi Dompet Kampus Global',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (!_timeout) ...[
                const SizedBox(height: 32),
                const CircularProgressIndicator(),
              ],
              if (_timeout) ...[
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
