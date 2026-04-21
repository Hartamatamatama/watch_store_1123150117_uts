class CartItemModel {
  final int productId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}
