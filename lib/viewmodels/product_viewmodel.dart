import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';

class ProductViewModel extends ChangeNotifier {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref("products");

  final ImagePicker _picker = ImagePicker();

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  // ================= FETCH PRODUCTS =================
  void fetchProducts() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      _products = data.entries.map((entry) {
        return ProductModel.fromMap(
          Map<String, dynamic>.from(entry.value),
          entry.key,
        );
      }).toList();

      _products.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      notifyListeners();
    });
  }

  // ================= PICK IMAGE (MOBILE ONLY) =================
  Future<Uint8List?> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) return null;
    return await file.readAsBytes();
  }

  // ================= UPLOAD IMAGE =================
  Future<String> _uploadImage(
      Uint8List imageBytes,
      String productId,
      ) async {
    final ref = FirebaseStorage.instance
        .ref("product_images/$productId.jpg");

    await ref.putData(
      imageBytes,
      SettableMetadata(contentType: "image/jpeg"),
    );

    return await ref.getDownloadURL();
  }

  // ================= ADD PRODUCT =================
  Future<void> addProduct(
      ProductModel product,
      Uint8List? imageBytes,
      ) async {
    try {
      final newId = const Uuid().v4();
      String imageUrl = "";

      if (imageBytes != null) {
        imageUrl = await _uploadImage(imageBytes, newId);
      }

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

      // 1. Lưu Firebase
      await _dbRef.child(newId).set(newProduct.toMap());
      fetchProducts();

      // 2. Gọi webhook n8n
      await http.post(
        Uri.parse(
          "https://n8n.tuantran.io.vn/webhook/8904cc6d-ed98-4759-bd81-6341a005461a",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": newProduct.id,
          "name": newProduct.name,
          "price": newProduct.price,
          "discount": newProduct.discount,
          "description": newProduct.description,
          "image": newProduct.image,
        }),
      );
    } catch (e) {
      debugPrint("Lỗi khi thêm sản phẩm: $e");
    }
  }

  // ================= UPDATE PRODUCT =================
  Future<void> updateProduct(
      ProductModel product,
      Uint8List? newImageBytes,
      ) async {
    try {
      if (newImageBytes != null) {
        product.image =
        await _uploadImage(newImageBytes, product.id);
      }

      await _dbRef.child(product.id).update(product.toMap());
      fetchProducts();
    } catch (e) {
      debugPrint("Lỗi khi cập nhật sản phẩm: $e");
    }
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(String id) async {
    try {
      await FirebaseStorage.instance
          .ref("product_images/$id.jpg")
          .delete();

      await _dbRef.child(id).remove();
      fetchProducts();
    } catch (e) {
      debugPrint("Lỗi khi xóa sản phẩm: $e");
    }
  }
  // ================= PROMOTIONS =================
  Future<List<ProductModel>> fetchPromotions() async {
    try {
      final snapshot = await _dbRef.get();
      if (!snapshot.exists) return [];

      final List<ProductModel> promotions = snapshot.children
          .map((child) {
        final data =
        Map<String, dynamic>.from(child.value as Map);
        final product =
        ProductModel.fromMap(data, child.key!);
        return product.discount > 10 ? product : null;
      })
          .whereType<ProductModel>()
          .toList();

      return promotions;
    } catch (e) {
      debugPrint("Lỗi khi tải khuyến mãi: $e");
      return [];
    }
  }

}
