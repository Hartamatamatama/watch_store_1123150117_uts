import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart'; // Import Reusable Widget yang baru kita buat
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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${auth.firebaseUser?.displayName?.split(' ')[0] ?? 'User'} 👋',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
            const Text(
              'Jelajahi Produk',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
              tooltip: 'Keluar',
              onPressed: () async {
                await auth.logout();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, AppRouter.login);
              },
            ),
          ),
        ],
      ),
      body: switch (product.status) {
        ProductStatus.loading || ProductStatus.initial => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1565C0)),
              SizedBox(height: 16),
              Text(
                'Menyiapkan etalase...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        ProductStatus.error => Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            onPressed: () => product.fetchProducts(),
          ),
        ),
        ProductStatus.loaded => RefreshIndicator(
          onRefresh: () => product.fetchProducts(),
          color: const Color(0xFF1565C0),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            // RAHASIA DESKTOP MODE: Gunakan MaxCrossAxisExtent, BUKAN FixedCrossAxisCount
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200, // Lebar maksimal 1 card adalah 200px
              childAspectRatio: 0.68,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: product.products.length,
            itemBuilder: (context, i) {
              final p = product.products[i];
              // Panggil Reusable Widget kita di sini! Lebih rapi dan bersih.
              return ProductCard(
                product: p,
                onTap: () {
                  // Navigasi ke halaman detail
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
