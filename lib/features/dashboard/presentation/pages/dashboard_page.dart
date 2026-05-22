import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/providers/theme_provider.dart'; // <-- Amunisi baru
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import 'package:flutter_library/flutter_library.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<CartProvider>().fetchCart();
    });
  }

  // --- FUNGSI UNTUK MENAMPILKAN MENU SETTINGS ---
  void _showSettingsBottomSheet(
    BuildContext context,
    String userName,
    AuthProvider auth,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors
          .transparent, // <-- Buat transparan agar kita bisa kontrol dari dalam
      elevation: 0,
      builder: (context) {
        // Pantau terus perubahan tema di dalam builder ini
        final themeProvider = context.watch<ThemeProvider>();
        final isDark = themeProvider.isDark;

        // Ambil warna dinamis
        final surfaceColor = Theme.of(context).colorScheme.surface;
        final onSurface = Theme.of(context).colorScheme.onSurface;

        return Container(
          decoration: BoxDecoration(
            color: surfaceColor, // <-- Latar dinamis bereaksi seketika di sini!
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ACCOUNT SETTINGS',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFC6A87C),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              Text(
                auth.firebaseUser?.email ?? '',
                style: GoogleFonts.lato(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),

              // SAKLAR DARK MODE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: isDark ? Colors.amber : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Dark Mode',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (_) => context.read<ThemeProvider>().toggle(),
                  ),
                ],
              ),

              const Divider(height: 32),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.receipt_long, color: onSurface),
                title: Text(
                  'My Orders',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade500,
                ),
                onTap: () {
                  Navigator.pop(context); // Tutup bottom sheet dulu
                  Navigator.pushNamed(
                    context,
                    AppRouter.myOrders,
                  ); // Buka halaman riwayat
                },
              ),

              const Divider(height: 32),

              // TOMBOL LOGOUT
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: Text(
                  'Sign Out',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context); // Tutup bottom sheet
                  context.read<CartProvider>().clearCart();
                  await auth.logout();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final product = context.watch<ProductProvider>();
    final userName =
        auth.firebaseUser?.displayName?.split(' ')[0].toUpperCase() ?? 'GUEST';

    // --- PENGAMBILAN WARNA DINAMIS (Sesuai Tahap 6) ---
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Dinamis
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: surfaceColor, // Dinamis
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WELCOME, $userName',
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade500,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Exclusive Collection',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: onSurfaceColor, // Dinamis
              ),
            ),
          ],
        ),
        actions: [
          // Ikon Keranjang Belanja
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: onSurfaceColor, // Dinamis
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
              ),
              if (context.watch<CartProvider>().itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC6A87C),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${context.watch<CartProvider>().itemCount}',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Ikon Pengaturan (Menggantikan Logout langsung)
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: onSurfaceColor,
            ), // Dinamis
            tooltip: 'Account Settings',
            onPressed: () => _showSettingsBottomSheet(context, userName, auth),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: switch (product.status) {
        ProductStatus.loading || ProductStatus.initial => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC6A87C)),
        ),
        ProductStatus.error => Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: onSurfaceColor, // Dinamis
            ),
            onPressed: () => product.fetchProducts(),
            child: Text(
              'RETRY',
              style: GoogleFonts.lato(
                color: surfaceColor,
                letterSpacing: 1.5,
              ), // Dinamis
            ),
          ),
        ),
        ProductStatus.loaded => RefreshIndicator(
          onRefresh: () => product.fetchProducts(),
          color: surfaceColor, // Dinamis
          backgroundColor: onSurfaceColor, // Dinamis
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 0.60,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: product.products.length,
            itemBuilder: (context, i) {
              final p = product.products[i];
              return ProductCard(
                product: p,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: p),
                    ),
                  );
                },
              );
            },
          ),
        ),
      },
    );
  }
}
