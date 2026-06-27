class ApiConstants {
  // static const String baseUrl = 'http://localhost:8080/v1';

  // Kabel USB
  // static const String baseUrl = 'http://127.0.0.1:8080/v1';

  // Wifi Kampus Tidak Works
  // static const String baseUrl = 'http://10.72.121.59:8080/v1';

  // Wifi Rumah
  static const String baseUrl = 'http://10.0.2.2:8081/v1';

  // Auth endpoints
  static const String verifyToken = '/auth/verify-token';

  // Product endpoints
  static const String products = '/products';

  // Timeout
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Cart endpoints
  static const String cart = '/cart';

  // Order endpoints
  static const String orders = '/orders';
  static const String checkout = '/orders/checkout';
}
