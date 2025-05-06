import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';

class CategoryViewModel extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
      "categories");
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  Future<void> addCategory(String name) async {
    String id = _dbRef
        .push()
        .key ?? '';
    if (id.isNotEmpty) {
      CategoryModel category = CategoryModel(id: id, name: name);
      await _dbRef.child(id).set(category.toJson());
      notifyListeners(); // Cập nhật UI nếu cần
    }
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists) {
        List<CategoryModel> loadedCategories = [];
        for (var child in snapshot.children) {
          final categoryData = child.value as Map<dynamic, dynamic>;
          loadedCategories.add(
            CategoryModel.fromJson(categoryData, child.key!),
          );
        }
        loadedCategories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _categories = loadedCategories;
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách danh mục: $e");
    }
  }


  Future<void> updateCategory(String id, String newName) async {
    try {
      await _dbRef.child(id).update({"name": newName});
      int index = _categories.indexWhere((category) => category.id == id);
      if (index != -1) {
        _categories[index] = CategoryModel(id: id, name: newName);
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi khi cập nhật danh mục: $e");
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _dbRef.child(id).remove();
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi xóa danh mục: $e");
    }
  }


  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    final DatabaseReference _productRef = FirebaseDatabase.instance.ref().child('products');
    try {
      DatabaseEvent event = await _productRef
          .orderByChild('category_id')
          .equalTo(categoryId)
          .once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value == null) return [];
      Map<dynamic, dynamic> productsData = snapshot.value as Map<dynamic, dynamic>;

      List<ProductModel> products = productsData.entries
          .map((entry) =>
          ProductModel.fromMap(Map<String, dynamic>.from(entry.value), entry.key))
          .toList();

      // Sort products alphabetically by name
      products.sort((a, b) => a.name.compareTo(b.name));

      return products;
    } catch (e) {
      print('Lỗi khi lấy sản phẩm từ Firebase: $e');
      return [];
    }
  }
}
