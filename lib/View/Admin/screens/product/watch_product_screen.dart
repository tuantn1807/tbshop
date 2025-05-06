import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/product_model.dart';
import '../../../../viewmodels/product_viewmodel.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProductViewModel>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách sản phẩm"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreen()),
              );
            },
          )
        ],
      ),
      body: productViewModel.products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: productViewModel.products.length,
        itemBuilder: (context, index) {
          ProductModel product = productViewModel.products[index];
          return Card(
            child: ListTile(
              leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
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
                  Provider.of<ProductViewModel>(context, listen: false).deleteProduct(product.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}