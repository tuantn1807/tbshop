import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductViewModel extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("products");

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  // Lấy danh sách sản phẩm từ Firebase
  Future<void> fetchProducts() async {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _products = data.entries.map((entry) {
          return ProductModel.fromMap(
            Map<String, dynamic>.from(entry.value),
            entry.key,
          );
        }).toList();
        _products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        notifyListeners();
      }
    });
  }


  // Thêm sản phẩm mới vào Firebase
  Future<void> addProduct(ProductModel product, File imageFile) async {
    try {
      final newId = Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref().child('product_images/$newId.jpg');
      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      final newProduct = ProductModel(
        id: newId,
        name: product.name,
        categoryId: product.categoryId,
        price: product.price,
        quantity: product.quantity,
        discount: product.discount,
        description: product.description,
        image: imageUrl,
      );

      await _dbRef.child(newId).set(newProduct.toMap());
      fetchProducts();
    } catch (e) {
      print("Lỗi khi thêm sản phẩm: $e");
    }
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(ProductModel product, File? newImage) async {
    try {
      if (newImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('product_images/${product.id}.jpg');
        await storageRef.putFile(newImage);
        final imageUrl = await storageRef.getDownloadURL();
        product.image = imageUrl;
      }

      await _dbRef.child(product.id).update(product.toMap());
      fetchProducts();
    } catch (e) {
      print("Lỗi khi cập nhật sản phẩm: $e");
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    try {
      // Xóa ảnh trên Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
          'product_images/$id.jpg');
      await storageRef.delete();

      // Xóa sản phẩm trong Firebase Database
      await _dbRef.child(id).remove();
      fetchProducts();
    } catch (e) {
      print("Lỗi khi xóa sản phẩm: $e");
    }
  }
  Future<ProductModel?> getProductById(String productId) async {
    final snapshot = await _dbRef.child(productId).get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      return ProductModel.fromMap(Map<String, dynamic>.from(data), productId);
    }
    return null;
  }


  Future<String?> fetchProductImage(String productId) async {
    try {
      final product = await getProductById(productId);
      return product?.image;
    } catch (_) {
      return null;
    }
  }


  Future<String?> fetchProductName(String productId) async {
    try {
      final product = await getProductById(productId);
      return product?.name;
    } catch (_) {
      return null;
    }
  }
  Future<List<ProductModel>> fetchPromotions() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists) {
        _products = snapshot.children
            .map((child) {
          final productData = Map<String, dynamic>.from(child.value as Map);
          final product = ProductModel.fromMap(productData, child.key!);
          return product.discount > 10 ? product : null;
        })
            .whereType<ProductModel>()
            .toList();
        notifyListeners();
        return _products;
      } else {
        _products = [];
        notifyListeners();
        return [];
      }
    } catch (e) {
      print('Lỗi khi tải sản phẩm khuyến mãi: $e');
      return [];
    }
  }

}




