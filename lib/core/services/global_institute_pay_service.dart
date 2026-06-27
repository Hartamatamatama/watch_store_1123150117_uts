import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Data yang diterima dari callback pembayaran Dompet Kampus Global.
class PaymentCallbackData {
  final String status; // 'success', 'failed', 'cancelled'
  final String? reference;
  final String? transactionId;

  const PaymentCallbackData({
    required this.status,
    this.reference,
    this.transactionId,
  });

  bool get isSuccess => status == 'success';
}

/// Service untuk integrasi pembayaran dengan Dompet Kampus Global via deeplink.
///
/// Pola Singleton + Broadcast Stream.
/// Menangani:
/// - Cold start: app dibuka oleh callback deeplink
/// - In-app: callback masuk saat app sudah berjalan
class GlobalInstitutePayService {
  // Singleton
  static final GlobalInstitutePayService _instance =
      GlobalInstitutePayService._();
  factory GlobalInstitutePayService() => _instance;
  GlobalInstitutePayService._();

  // Broadcast stream agar bisa punya banyak listener sekaligus
  final _callbackController =
      StreamController<PaymentCallbackData>.broadcast();
  Stream<PaymentCallbackData> get onCallback => _callbackController.stream;

  // Simpan callback cold start
  PaymentCallbackData? _pendingCallback;
  PaymentCallbackData? consumePendingCallback() {
    final data = _pendingCallback;
    _pendingCallback = null;
    return data;
  }

  Future<void> init() async {
    final appLinks = AppLinks();

    // Cold start: app dibuka oleh deeplink
    try {
      final uri = await appLinks.getInitialLink();
      if (uri != null) _handleUri(uri, isColdStart: true);
    } catch (_) {}

    // In-app: deeplink masuk saat app sudah berjalan
    appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri, {bool isColdStart = false}) {
    // Filter: hanya proses URI callback dari Dompet Kampus
    if (uri.scheme == 'watchstore' && uri.host == 'payment-callback') {
      final data = PaymentCallbackData(
        status: uri.queryParameters['status'] ?? 'unknown',
        reference: uri.queryParameters['reference'],
        transactionId: uri.queryParameters['transaction_id'],
      );

      debugPrint('[GlobalInstitutePayService] Callback diterima: ${uri}');

      // Simpan untuk cold start
      if (isColdStart) _pendingCallback = data;

      // Broadcast ke semua listener aktif
      _callbackController.add(data);
    }
  }

  /// Bangun URL deeplink untuk membuka Dompet Kampus Global.
  static String buildDeeplinkUrl({
    required int orderId,
    required double amount,
    String? description,
  }) {
    final uri = Uri(
      scheme: 'dompetkampus',
      host: 'pay',
      queryParameters: {
        'merchant_id': 'MCH_WATCHSTORE',
        'merchant_name': 'Watch Store',
        'amount': amount.toInt().toString(),
        'description': (description != null && description.isNotEmpty)
            ? description
            : 'Order #$orderId',
        'reference': 'INV-$orderId',
        'callback': 'watchstore://payment-callback',
      },
    );
    return uri.toString();
  }

  void dispose() {
    _callbackController.close();
  }
}
