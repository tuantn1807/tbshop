
import 'package:tbshop/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  String status;
  DateTime? orderTime;

  CartItem({
    required this.product,
    required this.quantity,
    required this.status,
    required this.orderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': product.name,
      'price': product.price,
      'discount': product.discount,
      'image': product.image,
      'quantity': quantity,
      'status': status,
      'orderTime': orderTime?.toIso8601String(),
    };
  }

  // static CartItem fromMap(Map<String, dynamic> map) {
  //   return CartItem(
  //     product: ProductModel.fromCart(map),
  //     quantity: map['quantity'],
  //     status: map['status'] ?? "chưa giao hàng",
  //     orderTime: map['orderTime'] != null
  //         ? DateTime.tryParse(map['orderTime'])
  //         : null,
  //   );
  // }
  static CartItem fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: ProductModel.fromCart(map),
      quantity: map['quantity'] ?? 0, // Đảm bảo quantity không phải null
      status: map['status']?.toString() ?? "chưa giao hàng", // Sử dụng toString() để tránh lỗi null
      orderTime: map['orderTime'] != null
          ? DateTime.tryParse(map['orderTime']?.toString() ?? '')
          : null, // Đảm bảo orderTime luôn là kiểu DateTime
    );
  }
  @override
  String toString() {
    return 'CartItem(product: ${product.toString()}, quantity: $quantity)';
  }
}
