import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';


class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addLocal(ProductModel product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: 1,
        status: "chưa giao",
        orderTime: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  Future<String> getCartId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id'); // Lấy 'id' từ SharedPreferences

    if (userId != null && userId.isNotEmpty) {
      // Nếu có 'id' (đã đăng nhập), trả về 'id' này
      return userId;
    } else {
      // Nếu chưa đăng nhập, tạo 'cart_id' tạm thời
      String? cartId = prefs.getString('cart_id');
      if (cartId == null) {
        cartId = DateTime.now().millisecondsSinceEpoch.toString();
        await prefs.setString('cart_id', cartId); // Lưu lại 'cart_id'
      }
      return cartId;
    }
  }


  Future<void> uploadOrder({
    required String receiverName,
    required String phoneNumber,
    required String address,
  }) async {
    final uid = await getCartId();
    final database = FirebaseDatabase.instance.ref();
    final newOrderRef = database.child("carts/$uid").push();

    final Map<String, dynamic> productMap = {};
    for (var item in _items) {
      productMap[item.product.id] = {
        "name": item.product.name,
        "price": item.product.price,
        "image": item.product.image,
        "discount": item.product.discount,
        "quantity": item.quantity,
        "status": item.status,
        "orderTime": DateTime.now().toIso8601String(),
        "receiverName": receiverName,
        "phoneNumber": phoneNumber,
        "address": address,
      };
    }

    await newOrderRef.set(productMap);
    clearCart();
  }

  Future<void> addToCart(ProductModel product) async {
    addLocal(product);
  }

  void removeFromCart(ProductModel product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0, (sum, item) {
      final discountedPrice = item.product.price * (1 - (item.product.discount ?? 0) / 100);
      return sum + discountedPrice * item.quantity;
    });
  }
  void clearCart() {
    _items.clear();
    notifyListeners();
  }


}
