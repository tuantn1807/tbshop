import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../viewmodels/cart_viewmodel.dart';

class SearchResultWidget extends StatelessWidget {
  final bool isLoading;
  final List<ProductModel> filteredProducts;
  final Function(String) onProductTap;

  const SearchResultWidget({
    Key? key,
    required this.isLoading,
    required this.filteredProducts,
    required this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartViewModel>(context, listen: false);
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(color: Colors.green),
      );
    } else if (filteredProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Không tìm thấy sản phẩm',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            final price = product.price ?? 0;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: product.image == null || product.image!.isEmpty
                      ? const Icon(Icons.image, color: Colors.grey)
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, color: Colors.grey);
                      },
                    ),
                  ),
                ),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        product.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${price.toStringAsFixed(0)} VND',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart, color: Colors.green[600]),
                  onPressed: () {
                    cart.addToCart(product);
                  }, // Bạn có thể truyền thêm callback nếu cần
                ),
                onTap: () => onProductTap(product.id),
              ),
            );
          },
        ),
      );
    }
  }
}
