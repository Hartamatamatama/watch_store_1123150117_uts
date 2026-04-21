import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final product = context.watch<ProductProvider>();
    final userName =
        auth.firebaseUser?.displayName?.split(' ')[0].toUpperCase() ?? 'GUEST';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
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
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1A1A1A)),
            tooltip: 'Sign Out',
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
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
              backgroundColor: const Color(0xFF1A1A1A),
            ),
            onPressed: () => product.fetchProducts(),
            child: Text(
              'RETRY',
              style: GoogleFonts.lato(color: Colors.white, letterSpacing: 1.5),
            ),
          ),
        ),
        ProductStatus.loaded => RefreshIndicator(
          onRefresh: () => product.fetchProducts(),
          color: const Color(0xFF1A1A1A),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio:
                  0.60, // Disesuaikan untuk tampilan memanjang yang elegan
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
