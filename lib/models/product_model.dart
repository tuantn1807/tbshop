// models/product_model.dart
class ProductModel {
  String id;
  String image;
  String name;
  String categoryId;
  double price;
  int quantity;
  double discount;
  String description;

  ProductModel({
    required this.id,
    required this.image,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.quantity,
    required this.discount,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'category_id': categoryId,
      'price': price,
      'quantity': quantity,
      'discount': discount,
      'description': description,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> json, String id) {
    return ProductModel(
      id: id,
      image: json['image'],
      name: json['name'],
      categoryId: json['category_id'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      discount: (json['discount'] as num).toDouble(),
      description: json['description'],
    );
  }
  static ProductModel fromCart(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      quantity: map['quantity'] is int
          ? map['quantity']
          : int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
      discount: (map['discount'] is num)
          ? (map['discount'] as num).toDouble()
          : double.tryParse(map['discount']?.toString() ?? '0') ?? 0.0,
      description: map['description']?.toString() ?? '',
    );
  }


  static ProductModel empty() {
    return ProductModel(id: '', name: '', price: 0.0, image: '', categoryId: '', quantity: 0, discount: 0, description: '');
  }
  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price)';
  }
}
