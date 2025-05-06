import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../models/product_model.dart';
import '../../../../../viewmodels/product_viewmodel.dart';
import '../product/add_product_screen.dart';
import '../product/edit_product_screen.dart';


class ProductHomePageScreen extends StatefulWidget {
  @override
  _ProductHomePageScreenState createState() => _ProductHomePageScreenState();
}

class _ProductHomePageScreenState extends State<ProductHomePageScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProductViewModel>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    final products = productViewModel.products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Danh sách sản phẩm",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductScreen()),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Thêm"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // hoặc 3 tùy theo màn hình
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailEditScreen(product: product),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Giá: ${product.price} đ"),
                      Text("SL: ${product.quantity}"),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
