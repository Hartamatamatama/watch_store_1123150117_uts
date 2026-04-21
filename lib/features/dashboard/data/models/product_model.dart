class ProductModel {
  final int id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final int? stock;
  final String? description; // <-- Ini organ baru yang diminta UI

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.stock,
    this.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['ID'] ?? 0,
      name: json['name'] ?? '',
      // Konversi aman ke double karena dari API kadang terbaca int
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      stock: json['stock'],
      description:
          json['description'], // <-- Ambil deskripsi dari backend Golang
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'stock': stock,
      'description': description,
    };
  }
}
