import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbshop/viewmodels/product_viewmodel.dart';

import '../../models/product_model.dart';
import '../../viewmodels/cart_viewmodel.dart';
class PromotionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final promotionViewModel = Provider.of<ProductViewModel>(context, listen: false);
    late CartViewModel cart = Provider.of<CartViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Sản phẩm được giảm trên 10%'),
        backgroundColor: Colors.green[600],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: promotionViewModel.fetchPromotions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải dữ liệu: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(child: Text('Không có sản phẩm nào.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  leading: product.image.isNotEmpty
                      ? Image.network(
                    product.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  )
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(product.name),
                  subtitle: Text(
                    'Giá: ${product.price.toStringAsFixed(0)} VNĐ\n'
                        'Số lượng: ${product.quantity}\n'
                        'Giá sau giảm: ${(product.price * (1 - product.discount/100))
                        .toStringAsFixed(0)} VNĐ',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      cart.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${product
                            .name} đã được thêm vào giỏ hàng')),
                      );
                    },
                    child: const Text('Thêm vào giỏ'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
