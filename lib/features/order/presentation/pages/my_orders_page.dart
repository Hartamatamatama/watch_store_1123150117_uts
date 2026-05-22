import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/order_provider.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchMyOrders();
    });
  }

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

  Color _statusColor(String status) {
    return switch (status) {
      'pending' => Colors.orange,
      'processing' => Colors.blue,
      'shipped' => Colors.purple,
      'delivered' => Colors.green,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RIWAYAT PESANAN',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(orderProv, isDark),
    );
  }

  Widget _buildBody(OrderProvider orderProv, bool isDark) {
    if (orderProv.checkoutStatus == OrderStatus.loading &&
        orderProv.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProv.checkoutStatus == OrderStatus.error &&
        orderProv.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(orderProv.error ?? 'Gagal memuat pesanan'),
            TextButton(
              onPressed: () => orderProv.fetchMyOrders(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (orderProv.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text('Belum ada pesanan.', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orderProv.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orderProv.orders[index];
        final color = _statusColor(order.status);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Text(
                      _statusLabel(order.status),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${order.items.length} Barang',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  const Text('Total: ', style: TextStyle(color: Colors.grey)),
                  Text(
                    _formatRupiah(order.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
