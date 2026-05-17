import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../dashboard/presentation/providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/snackbar_helper.dart';
import 'success_checkout_page.dart';
import 'package:flutter_library/flutter_library.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String _formatRupiah(double value) {
    String strValue = value.toInt().toString();
    return 'Rp ${strValue.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    // --- PENGAMBILAN WARNA DINAMIS DARI TEMA ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;

    final imageBgColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF8F9FA);
    final dividerColor = isDark ? const Color(0xFF3A3A3A) : Colors.black12;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final trashIconColor = isDark ? Colors.grey.shade500 : Colors.black54;

    // Tombol menyesuaikan: Emas di Dark Mode, Hitam di Light Mode
    final buttonBgColor = isDark
        ? const Color(0xFFC6A87C)
        : const Color(0xFF1A1A1A);
    final buttonTextColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBgColor, // <-- Dinamis
      appBar: AppBar(
        backgroundColor: surfaceColor, // <-- Dinamis
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: onSurfaceColor), // <-- Dinamis
        title: Text(
          'YOUR BAG',
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: onSurfaceColor, // <-- Dinamis
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
                    color: isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300, // <-- Dinamis
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your bag is empty.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      color: subtitleColor, // <-- Dinamis
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) =>
                  Divider(color: dividerColor, height: 32), // <-- Dinamis
              itemBuilder: (context, i) {
                final item = cart.items.values.toList()[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Produk
                    Container(
                      width: 80,
                      height: 100,
                      color: imageBgColor, // <-- Dinamis
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.watch,
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
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
                              color: onSurfaceColor, // <-- Dinamis
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatRupiah(item.price),
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: subtitleColor, // <-- Dinamis
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'QTY: ${item.quantity}',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(
                                0xFFC6A87C,
                              ), // Warna emas tetap
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol Hapus (Trash)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: trashIconColor, // <-- Dinamis
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
                color: surfaceColor, // <-- Dinamis
                border: Border(
                  top: BorderSide(color: dividerColor),
                ), // <-- Dinamis
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
                            color: onSurfaceColor, // <-- Dinamis
                          ),
                        ),
                        Text(
                          _formatRupiah(cart.totalAmount),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor, // <-- Dinamis
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
                                  context
                                      .read<ProductProvider>()
                                      .fetchProducts();
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
                          backgroundColor: buttonBgColor, // <-- Dinamis
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
                            color: buttonTextColor, // <-- Dinamis
                          ),
                        ),
                      ),
                    ),
                    // --- SAKLAR TESTING CUSTOM BUTTON (TUGAS MATERI 1) ---
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: 'TEST LIBRARY BUTTON',
                        color: isDark
                            ? const Color(0xFF3A3A3A)
                            : Colors.grey.shade300,
                        borderRadiusTanger:
                            BorderRadius.zero, // Menjaga garis tegas luxury
                        onPressed: () {
                          SnackBarHelper.showSuccess(
                            'Library internal berhasil dieksekusi di proyek utama!',
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
}
