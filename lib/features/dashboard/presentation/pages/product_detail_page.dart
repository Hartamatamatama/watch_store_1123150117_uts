import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // Gambar menembus ke area atas AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image
            Container(
              width: double.infinity,
              height: 450,
              color: const Color(0xFFF8F9FA),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit
                        .contain, // Agar seluruh jam tangan terlihat presisi
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.watch, size: 80, color: Colors.grey),
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
                        color: const Color(0xFFC6A87C),
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
                        color: const Color(0xFF1A1A1A),
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
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Divider(color: Colors.black12, thickness: 1),
                  ),

                  Text(
                    'THE DETAILS',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description ??
                        'A masterpiece of horology. No additional details provided.',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: Colors.grey.shade700,
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
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              // Panggil fungsi addItem dari CartProvider
              context.read<CartProvider>().addItem(product);

              // Tampilkan notifikasi elegan
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${product.name} added to bag!',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF1A1A1A),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ), // Desain kotak tegas
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
