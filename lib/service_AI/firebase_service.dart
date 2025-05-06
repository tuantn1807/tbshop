import 'package:firebase_database/firebase_database.dart';

import '../models/cart_item_model.dart';
import '../models/click_event_model.dart';
import '../models/product_model.dart';
import '../models/rating_model.dart';

class FirebaseService {
  final _database = FirebaseDatabase.instance.ref();


  Future<List<CartItem>> fetchCartItems(String userId) async {
    final snapshot = await _database.child('carts').child(userId).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries.map((entry) {
        final item = Map<String, dynamic>.from(entry.value);
        return CartItem.fromMap(item);
      }).toList();
    }
    return [];
  }

 Future<List<RatingModel>> fetchRatings() async {
   final snapshot = await _database.child('ratings').get();
   if (snapshot.exists) {
     final data = Map<String, dynamic>.from(snapshot.value as Map);
     return data.entries.map((entry) {
       final item = Map<String, dynamic>.from(entry.value);
       return RatingModel.fromMap(item);
     }).toList();
   }
   return [];
 }
  Future<List<ClickEvent>> fetchClickEvents() async {
    final snapshot = await _database.child('click_events').get();

    if (snapshot.exists) {
      final rawData = snapshot.value;
      if (rawData is! Map) {
        print("Dữ liệu 'click_events' không đúng định dạng Map.");
        return [];
      }

      final data = Map<String, dynamic>.from(rawData);
      final allClickEvents = <ClickEvent>[];

   data.forEach((userId, userClicks) {
     if (userClicks is Map) {
       final clicksMap = Map<String, dynamic>.from(userClicks);

       for (var click in clicksMap.values) {
         if (click is Map) {
           final map = Map<String, dynamic>.from(click);
           if (map.containsKey('productId') && map.containsKey('timestamp')) {
             allClickEvents.add(ClickEvent.fromMap(map, userId)); // Pass userId here
           }
         }
       }
     }
   });

      return allClickEvents;
    }

    print("Không có dữ liệu 'click_events' trong Firebase.");
    return [];
  }

  @override
  Future<List<String>> fetchAllProductIds() async {
    final snapshot = await _database.child('products').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      return data.keys.map((id) => id.toString()).toList();
    }
    return [];
  }
  Future<List<ProductModel>> fetchProductsByIds(List<String> productIds) async {
    final snapshot = await _database.child('products').get();

    if (!snapshot.exists) {
      print("Không có dữ liệu 'products' trong Firebase.");
      return [];
    }

    final rawData = snapshot.value;
    if (rawData is! Map) {
      print("Dữ liệu 'products' không đúng định dạng Map.");
      return [];
    }

    final Map data = rawData;
    final List<ProductModel> result = [];

    for (var id in productIds) {
      if (data.containsKey(id)) {
        try {
          final productData = Map<String, dynamic>.from(data[id]);
          final product = ProductModel.fromMap(productData, id);
          result.add(product);
        } catch (e) {
          print("Lỗi khi xử lý sản phẩm [$id]: $e");
        }
      } else {
        print("ID không tồn tại trong Firebase: $id");
      }
    }
    return result;
  }



  Future<Map<String, List<CartItem>>> fetchAllCartItems() async {
    final snapshot = await _database.child('carts').get();

    if (snapshot.exists) {
      final raw = snapshot.value as Map;
      final result = <String, List<CartItem>>{};

      raw.forEach((userId, cartData) {
        final userCart = <CartItem>[];

        (cartData as Map).forEach((orderId, orderData) {
          (orderData as Map).forEach((productId, rawMap) {
            try {
              final safeCartItemMap = {
                'id': productId,
                'name': rawMap['name']?.toString() ?? '',
                'image': rawMap['image']?.toString() ?? '',
                'category_id': rawMap['category_id']?.toString() ?? '',
                'price': (rawMap['price'] is num) ? rawMap['price'] : 0,
                'quantity': (rawMap['quantity'] is int) ? rawMap['quantity'] : 0,
                'discount': (rawMap['discount'] is num)
                    ? (rawMap['discount'] as num).toDouble()
                    : 0.0,
                'description': rawMap['description']?.toString() ?? '',
                'receiverName': rawMap['receiverName']?.toString() ?? '',
                'phoneNumber': rawMap['phoneNumber']?.toString() ?? '',
                'address': rawMap['address']?.toString() ?? '',
                'orderTime': rawMap['orderTime']?.toString() ?? '',
                'status': rawMap['status']?.toString() ?? '',
              };

              final cartItem = CartItem.fromMap(safeCartItemMap); // ✅ sử dụng map đã xử lý an toàn
              print("cartItem: $cartItem");
              userCart.add(cartItem);
            } catch (e) {
              print("Lỗi khi parse CartItem: $e");
              print("USER: $userId | ORDER: $orderId | PRODUCT: $productId");
              print("DATA: $rawMap");
            }
          });
        });

        result[userId] = userCart;
      });

      return result;
    }

    return {};
  }


// Hàm kiểm tra an toàn để chuyển đổi giá trị sang double
  double _safeParseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

// Hàm kiểm tra an toàn để chuyển đổi giá trị sang int
  int _safeParseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return 0;
  }
  Future<void> logClick(String userId, String productId) async {
    final timestamp = DateTime.now().toIso8601String();
    await _database.child('click_events').child(userId).push().set({
      'productId': productId,
      'timestamp': timestamp,
    });
  }
  Future<List<ProductModel>> fetchAllProducts() async {
    final snapshot = await _database.child('products').get();
    if (!snapshot.exists) {
      print("Không có dữ liệu 'products' trong Firebase.");
      return [];
    }
    final rawData = snapshot.value;
    if (rawData is! Map) {
      print("Dữ liệu 'products' không đúng định dạng Map.");
      return [];
    }
    final Map data = rawData;
    final List<ProductModel> result = [];
    data.forEach((id, productData) {
      try {
        final productMap = Map<String, dynamic>.from(productData);
        final product = ProductModel.fromMap(productMap, id);
        result.add(product);
      } catch (e) {
        print("Lỗi khi xử lý sản phẩm [$id]: $e");
      }
    });
    return result;
  }
}
