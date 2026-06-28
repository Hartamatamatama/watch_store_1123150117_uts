import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/order/presentation/pages/checkout_page.dart';
import '../../features/order/presentation/pages/order_success_page.dart';
import '../../features/order/presentation/pages/my_orders_page.dart';
import '../../features/order/presentation/pages/payment_pending_page.dart';
import '../../features/order/data/models/order_model.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String myOrders = '/my-orders';
  static const String paymentPending = '/payment-pending';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashPage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    dashboard: (_) => const AuthGuard(child: DashboardPage()),
    cart: (_) => const CartPage(),
    checkout: (_) => const CheckoutPage(),
    myOrders: (_) => const MyOrdersPage(),
    orderSuccess: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is OrderModel) {
        return OrderSuccessPage(order: args);
      }
      // Fallback: dari payment callback (cold start) — minimal order object
      final map = args as Map<String, dynamic>? ?? {};
      return OrderSuccessPage(
        order: OrderModel(
          id: map['orderId'] as int? ?? 0,
          totalAmount: (map['amount'] as num?)?.toDouble() ?? 0.0,
          status: 'pending',
          shippingAddress: '',
          notes: '',
          paymentMethod: 'global_institute_pay',
          items: [],
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    },
    paymentPending: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PaymentPendingPage(
        orderId: args['orderId'] as int,
        amount: (args['amount'] as num).toDouble(),
        description: args['description'] as String? ?? '',
      );
    },
  };
}

// Bungkus halaman yang butuh autentikasi dengan AuthGuard
class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    return switch (status) {
      AuthStatus.authenticated => child, // Lanjut ke halaman
      AuthStatus.emailNotVerified =>
        const VerifyEmailPage(), // Redirect verifikasi
      _ => const LoginPage(), // Redirect login
    };
  }
}
