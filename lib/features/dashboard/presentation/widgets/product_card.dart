import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  String _formatRupiah(double value) {
    String strValue = value.toInt().toString();
    return 'Rp ${strValue.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isSoldOut = (product.stock ?? 0) <= 0;

    // --- PENGAMBILAN WARNA DINAMIS DARI TEMA ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Warna kartu: Jika gelap pakai abu-abu gelap khusus kartu, jika terang pakai putih
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final onSurfaceColor =
        theme.colorScheme.onSurface; // Teks: putih di dark, hitam di light
    final borderColor = isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200;
    final imageBgColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF8F9FA);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor, // <-- Dinamis
        borderRadius: BorderRadius.circular(0), // Sudut tajam ala luxury brand
        border: Border.all(color: borderColor, width: 1), // <-- Dinamis
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- BAGIAN GAMBAR --
              Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: imageBgColor, // <-- Dinamis
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.watch,
                        size: 50,
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  // EFEK PUDAR JIKA SOLD OUT
                  if (isSoldOut)
                    Container(
                      height: 160,
                      width: double.infinity,
                      color: surfaceColor.withOpacity(
                        0.6,
                      ), // <-- Menggunakan warna kartu yang dinamis
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // Merah gelap jika habis. Jika ada: Putih (Dark Mode) atau Hitam (Light Mode)
                        color: isSoldOut
                            ? const Color(0xFF8B0000)
                            : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                      ),
                      child: Text(
                        isSoldOut ? 'SOLD OUT' : 'STOK: ${product.stock}',
                        style: GoogleFonts.lato(
                          fontSize: 9,
                          // Teks STOK berlawanan dengan warna kotaknya
                          color: isSoldOut
                              ? Colors.white
                              : (isDark ? Colors.black : Colors.white),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // -- BAGIAN INFO --
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            product.category.toUpperCase(),
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(
                                0xFFC6A87C,
                              ), // Warna Emas/Bronze tetap
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: onSurfaceColor, // <-- Dinamis
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Text(
                        _formatRupiah(product.price),
                        style: GoogleFonts.lato(
                          color: onSurfaceColor, // <-- Dinamis
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
