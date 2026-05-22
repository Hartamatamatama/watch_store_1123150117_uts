import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/cart_provider.dart';
import '../../../../core/routes/app_router.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // Tarik data terbaru saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  String _formatRupiah(double value) {
    String strValue = value.toInt().toString();
    return 'Rp ${strValue.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  @override
  Widget build(BuildContext context) {
    final cartProv = context.watch<CartProvider>();
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'KERANJANG BELANJA',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: onSurfaceColor,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(cartProv, theme),
      bottomNavigationBar: _buildBottomBar(cartProv, theme),
    );
  }

  Widget _buildBody(CartProvider cartProv, ThemeData theme) {
    // KONDISI 1: LOADING
    if (cartProv.status == CartStatus.initial ||
        cartProv.status == CartStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // KONDISI 2: ERROR
    if (cartProv.status == CartStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              cartProv.error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => cartProv.fetchCart(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // KONDISI 3: LOADED
    final cart = cartProv.cart;
    if (cart == null || cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Keranjang masih kosong',
              style: GoogleFonts.playfairDisplay(fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text('Yuk tambahkan produk ke keranjang!'),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        final isDark = theme.brightness == Brightness.dark;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item.product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Detail & Logika Kuantitas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(item.product.price),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Tombol Minus & Logika Remove [cite: 264, 267, 268]
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          final qty = item.quantity - 1;
                          if (qty <= 0) {
                            cartProv.removeItem(item.id);
                          } else {
                            cartProv.updateItem(item.id, qty); // [cite: 270]
                          }
                        },
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Tombol Plus [cite: 264, 273]
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () =>
                            cartProv.updateItem(item.id, item.quantity + 1),
                      ),
                      const Spacer(),
                      // Subtotal Baris
                      Text(
                        _formatRupiah(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildBottomBar(CartProvider cartProv, ThemeData theme) {
    if (cartProv.status != CartStatus.loaded ||
        cartProv.cart == null ||
        cartProv.cart!.items.isEmpty) {
      return null;
    }

    final isDark = theme.brightness == Brightness.dark;
    final buttonColor = isDark
        ? const Color(0xFFC6A87C)
        : const Color(0xFF1A1A1A);
    final textColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  _formatRupiah(cartProv.totalAmount),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  // Lompat ke Halaman Checkout
                  Navigator.pushNamed(context, AppRouter.checkout);
                },
                child: Text(
                  'CHECKOUT',
                  style: GoogleFonts.lato(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
