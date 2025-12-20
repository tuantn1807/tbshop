import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';

class ProductViewModel extends ChangeNotifier {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref("products");

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

  // ================= PICK IMAGE (WEB + MOBILE) =================
  Future<Uint8List?> pickImage() async {
    if (kIsWeb) {
      return await ImagePickerWeb.getImageAsBytes();
    } else {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        return await file.readAsBytes();
      }
    }
    return null;
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

      // 2. GỌI WEBHOOK n8n (đăng Facebook bằng AI)
      await http.post(
        Uri.parse(
          "https://n8n.tuantran.io.vn/webhook-test/8904cc6d-ed98-4759-bd81-6341a005461a",
        ),
        headers: {
          "Content-Type": "application/json",
        },
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
        final imageUrl =
        await _uploadImage(newImageBytes, product.id);
        product.image = imageUrl;
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
      final ref = FirebaseStorage.instance
          .ref("product_images/$id.jpg");

      await ref.delete();
      await _dbRef.child(id).remove();
      fetchProducts();
    } catch (e) {
      debugPrint("Lỗi khi xóa sản phẩm: $e");
    }
  }

  // ================= GET PRODUCT =================
  Future<ProductModel?> getProductById(String productId) async {
    final snapshot = await _dbRef.child(productId).get();
    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return ProductModel.fromMap(data, productId);
  }

  Future<String?> fetchProductImage(String productId) async {
    final product = await getProductById(productId);
    return product?.image;
  }

  Future<String?> fetchProductName(String productId) async {
    final product = await getProductById(productId);
    return product?.name;
  }

  // ================= PROMOTIONS =================
  Future<List<ProductModel>> fetchPromotions() async {
    try {
      final snapshot = await _dbRef.get();
      if (!snapshot.exists) return [];

      _products = snapshot.children
          .map((child) {
        final data =
        Map<String, dynamic>.from(child.value as Map);
        final product =
        ProductModel.fromMap(data, child.key!);
        return product.discount > 10 ? product : null;
      })
          .whereType<ProductModel>()
          .toList();

      notifyListeners();
      return _products;
    } catch (e) {
      debugPrint("Lỗi khi tải khuyến mãi: $e");
      return [];
    }
  }
}
