import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/models/product_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  String _formatRupiah(double value) {
    String strValue = value.toInt().toString();
    return 'Rp ${strValue.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  @override
  Widget build(BuildContext context) {
    // --- PENGAMBILAN WARNA DINAMIS DARI TEMA ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;

    // Warna khusus agar selaras dengan desain luxury
    final imageBgColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF8F9FA);
    final dividerColor = isDark ? const Color(0xFF3A3A3A) : Colors.black12;
    final buttonBgColor = isDark
        ? const Color(0xFFC6A87C)
        : const Color(0xFF1A1A1A); // Emas di Dark, Hitam di Light
    final buttonTextColor = isDark
        ? const Color(0xFF1A1A1A)
        : Colors.white; // Hitam di atas Emas, Putih di atas Hitam

    return Scaffold(
      backgroundColor: scaffoldBgColor, // <-- Dinamis
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Icon kembali berlawanan dengan warna background gambar
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image
            Container(
              width: double.infinity,
              height: 450,
              color: imageBgColor, // <-- Dinamis
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.watch,
                        size: 80,
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Info Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      product.category.toUpperCase(),
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: const Color(
                          0xFFC6A87C,
                        ), // Warna Emas/Bronze tetap
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      product.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: onSurfaceColor, // <-- Dinamis
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      _formatRupiah(product.price),
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade800, // Dinamis
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Divider(
                      color: dividerColor,
                      thickness: 1,
                    ), // <-- Dinamis
                  ),

                  Text(
                    'THE DETAILS',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: onSurfaceColor, // <-- Dinamis
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description ??
                        'A masterpiece of horology. No additional details provided.',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700, // Dinamis
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),

      // 3. Tombol "Add to Cart" Super Elegan
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: surfaceColor), // <-- Dinamis
        child: SafeArea(
          child: ElevatedButton(
onPressed: () {
               final bool success = context.read<CartProvider>().addToCart(widget.product.id, 1);
               if (success) {
                 SnackBarHelper.showSuccess('${product.name} added to bag!');
               } else {
                 SnackBarHelper.showError('Sayang Sekali, Stok Habis!');
               }
             },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBgColor, // <-- Dinamis khusus (Emas/Hitam)
              foregroundColor: buttonTextColor, // <-- Dinamis
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              elevation: 0,
            ),
            child: Text(
              'ADD TO BAG',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
