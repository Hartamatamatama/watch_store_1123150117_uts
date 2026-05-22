import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_router.dart';
import '../../data/models/order_model.dart';

class OrderSuccessPage extends StatelessWidget {
  final OrderModel order;
  const OrderSuccessPage({super.key, required this.order});

  String _formatRupiah(double value) {
    String strValue = value.toInt().toString();
    return 'Rp ${strValue.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  String _statusLabel(String status) {
    return switch (status) {
      'pending' => 'Menunggu Pembayaran',
      'processing' => 'Sedang Diproses',
      'shipped' => 'Dikirim',
      'delivered' => 'Diterima',
      'cancelled' => 'Dibatalkan',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final onSurfaceColor = theme.colorScheme.onSurface;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final buttonColor = isDark
        ? const Color(0xFFC6A87C)
        : const Color(0xFF1A1A1A);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Status Pesanan',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: onSurfaceColor,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghilangkan tombol back bawaan
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon Sukses
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pesanan Berhasil!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order #${order.id}',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: buttonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Kartu Detail Singkat
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.payment,
                      'Metode Pembayaran',
                      order.paymentMethod.toUpperCase(),
                      theme,
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(
                      Icons.monetization_on_outlined,
                      'Total Pembayaran',
                      _formatRupiah(order.totalAmount),
                      theme,
                      isTotal: true,
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(
                      Icons.info_outline,
                      'Status',
                      _statusLabel(order.status),
                      theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Tombol Aksi
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Lihat Riwayat Pesanan'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: buttonColor),
                    foregroundColor: buttonColor,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRouter.myOrders);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.home,
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  ),
                  label: Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) =>
                          route.settings.name == AppRouter.dashboard ||
                          route.isFirst,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
    ThemeData theme, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: isTotal ? Colors.green : Colors.blue, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTotal ? 18 : 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
