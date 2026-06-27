import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/global_institute_pay_service.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/order_provider.dart';

// --- DATA METODE PEMBAYARAN ---
class _PaymentOption {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _PaymentOption({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedPaymentMethod;

  static const List<_PaymentOption> _paymentOptions = [
    _PaymentOption(
      value: 'global_institute_pay',
      label: 'Global Institute Pay',
      subtitle: 'Bayar via Dompet Kampus Global',
      icon: Icons.account_balance_wallet,
      iconColor: Color(0xFF00ADB5),
    ),
  ];

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatRupiah(double value) {
    String strValue = value.toInt().toString();
    return 'Rp ${strValue.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  // --- LOGIKA UTAMA CHECKOUT ---
  Future<void> _placeOrder(BuildContext context) async {
    final orderProv = context.read<OrderProvider>();
    final cartProv = context.read<CartProvider>();

    // 1. Validasi form (alamat pengiriman)
    if (!_formKey.currentState!.validate()) return;

    // 2. Validasi metode pembayaran dipilih
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. Kalo pilih Global Institute Pay, arahkan ke PaymentPendingPage
    if (_selectedPaymentMethod == 'global_institute_pay') {
      Navigator.pushNamed(
        context,
        AppRouter.paymentPending,
        arguments: {
          'orderId': DateTime.now().millisecondsSinceEpoch % 100000,
          'amount': cartProv.totalAmount,
          'description': 'Pembayaran Watch Store',
        },
      );
      return;
    }

    // 4. Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 4. Panggil API checkout
    final success = await orderProv.checkout(
      shippingAddress: _addressCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      paymentMethod: _selectedPaymentMethod!,
    );

    // Tutup loading dialog
    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      // 5. Bersihkan cart
      await cartProv.clearCart();

      // 6. Navigate ke halaman sukses, hapus stack checkout & cart
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.orderSuccess,
        (route) => route.settings.name == AppRouter.dashboard,
        arguments: orderProv.lastOrder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProv = context.watch<CartProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final onSurfaceColor = theme.colorScheme.onSurface;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final dividerColor = isDark
        ? const Color(0xFF3A3A3A)
        : Colors.grey.shade200;
    final buttonColor = isDark
        ? const Color(0xFFC6A87C)
        : const Color(0xFF1A1A1A);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CHECKOUT',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: onSurfaceColor,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: cartProv.cart == null || cartProv.cart!.items.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // --- SECTION 1: RINGKASAN PESANAN ---
                  Text(
                    'RINGKASAN PESANAN',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Column(
                      children: [
                        ...cartProv.cart!.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.quantity} x ${_formatRupiah(item.product.price)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatRupiah(item.subtotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: dividerColor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatRupiah(cartProv.totalAmount),
                              style: GoogleFonts.playfairDisplay(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: buttonColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- SECTION 2: ALAMAT PENGIRIMAN ---
                  Text(
                    'ALAMAT PENGIRIMAN',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Masukkan alamat lengkap pengiriman...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cardColor,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Alamat tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // --- SECTION 3: CATATAN ---
                  Text(
                    'CATATAN (OPSIONAL)',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan untuk penjual...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cardColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- SECTION 4: METODE PEMBAYARAN ---
                  Text(
                    'METODE PEMBAYARAN',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._paymentOptions.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => setState(
                          () => _selectedPaymentMethod = option.value,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPaymentMethod == option.value
                                  ? buttonColor
                                  : dividerColor,
                              width: _selectedPaymentMethod == option.value
                                  ? 2
                                  : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                option.icon,
                                color: option.iconColor,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      option.subtitle,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: option.value,
                                groupValue: _selectedPaymentMethod,
                                activeColor: buttonColor,
                                onChanged: (val) => setState(
                                  () => _selectedPaymentMethod = val,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

      // --- SECTION 5: TOMBOL PLACE ORDER ---
      bottomNavigationBar: cartProv.cart == null || cartProv.cart!.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: dividerColor)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _placeOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      'PLACE ORDER',
                      style: GoogleFonts.lato(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
