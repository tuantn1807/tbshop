import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/product_model.dart';
import '../../../../viewmodels/category_viewmodel.dart';
import '../../../../viewmodels/product_viewmodel.dart';
import 'edit_product_screen.dart';

class ProductCategoryScreen extends StatelessWidget {
  final String categoryId;

  const ProductCategoryScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sản phẩm theo danh mục"),
      ),
      body: FutureBuilder<List<ProductModel>>(
            future: Provider.of<CategoryViewModel>(context, listen: false)
                .fetchProductsByCategory(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Không có sản phẩm nào."));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                ProductModel product = products[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      product.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.name),
                    subtitle: Text("Giá: ${product.price} - Số lượng: ${product.quantity}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailEditScreen(product: product),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Provider.of<ProductViewModel>(context, listen: false)
                            .deleteProduct(product.id);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}