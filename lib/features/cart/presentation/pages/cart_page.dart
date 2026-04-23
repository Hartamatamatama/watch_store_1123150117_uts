import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/cart_provider.dart';
import '../../dashboard/presentation/providers/product_provider.dart';
import '../../../../core/utils/snackbar_helper.dart';
import 'success_checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String _formatRupiah(double value) {
    String strValue = value.toInt().toString();
    return 'Rp ${strValue.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        title: Text(
          'YOUR BAG',
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your bag is empty.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.black12, height: 32),
              itemBuilder: (context, i) {
                final item = cart.items.values.toList()[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Produk
                    Container(
                      width: 80,
                      height: 100,
                      color: const Color(0xFFF8F9FA),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.watch, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Detail Produk
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatRupiah(item.price),
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'QTY: ${item.quantity}',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFC6A87C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol Hapus (Trash)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        context.read<CartProvider>().removeItem(item.productId);
                      },
                    ),
                  ],
                );
              },
            ),

      // Bagian Total dan Checkout
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          _formatRupiah(cart.totalAmount),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cart.isLoading
                            ? null
                            : () async {
                                final success = await context
                                    .read<CartProvider>()
                                    .processCheckout();

                                if (!context.mounted) return;

                                if (success) {
                                  // 1. Refresh stok di dashboard
                                  context
                                      .read<ProductProvider>()
                                      .fetchProducts();

                                  // 2. Pindah ke Halaman Sukses (Ganti Navigator.pop)
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SuccessCheckoutPage(),
                                    ),
                                  );
                                } else {
                                  SnackBarHelper.showError(
                                    'Failed to place order. Please try again.',
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: Text(
                          cart.isLoading
                              ? 'PROCESSING...'
                              : 'PROCEED TO CHECKOUT',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: Colors.white,
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
