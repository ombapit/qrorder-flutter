class Product {
  final String id;
  final String name;
  final int price;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // print("Parsing Product: $json"); // debug
    return Product(
      id: json['id'].toString(),
      name: json['product_name'] ?? '',
      price: (json['product_price'] ?? 0).toInt(),
      imageUrl: json['product_image'] ?? '',
    );
  }
}
