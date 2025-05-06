import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbshop/View/User/product_details.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../viewmodels/category_viewmodel.dart';
import 'product_item.dart';

class CategoryList extends StatelessWidget {
  final Function(String) onProductClick; // Hàm callback để xử lý sự kiện click

  const CategoryList({Key? key, required this.onProductClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewModel>(
      builder: (context, categoryViewModel, child) {
        List<CategoryModel> categories = categoryViewModel.categories;

        if (categories.isEmpty) {
          return Center(child: Text('Không có danh mục nào'));
        }

        return ListView(
          children: categories.map((category) {
            return FutureBuilder<List<ProductModel>>(
              future: categoryViewModel.fetchProductsByCategory(category.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Lỗi khi tải sản phẩm của ${category.name}: ${snapshot.error}');
                  return Center(child: Text('Lỗi tải sản phẩm'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Không có sản phẩm nào trong danh mục ${category.name}'),
                  );
                }

                List<ProductModel> products = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        category.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: products.map((product) {
                          return ProductItem(
                            product: product,
                            onTap: () {
                              // Khi người dùng nhấn vào sản phẩm, gọi hàm onProductClick
                              onProductClick(product.id);
                              //builder: (_) => ProductDetails(product: product),
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
