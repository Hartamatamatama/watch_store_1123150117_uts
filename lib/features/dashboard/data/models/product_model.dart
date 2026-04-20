import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final int stock; // 1. WADAH STOK DITAMBAHKAN

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock, // 2. WAJIB DIISI SAAT DIBUAT
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? json['ID'] ?? 0,
      name: json['name'] ?? 'Tanpa Nama',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'Lainnya',
      stock: json['stock'] ?? 0, // 3. AMBIL DATA STOK DARI GOLANG
    );
  }

  @override
  // 4. DAFTARKAN STOK KE EQUATABLE
  List<Object?> get props => [id, name, price, imageUrl, category, stock];
}
