import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbshop/View/User/product_details.dart';

import '../../models/product_model.dart';
import '../../viewmodels/cart_viewmodel.dart';

class ProductItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap; // onTap để xử lý sự kiện nhấn vào sản phẩm

  const ProductItem({super.key, required this.product, required this.onTap}); // Nhận onTap

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartViewModel>(context, listen: false);

    return GestureDetector(
      onTap: onTap, // Khi nhấn vào sản phẩm, gọi onTap
      child: Container(
        width: 150,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                product.image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Giá: ${product.price}đ",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Số lượng: ${product.quantity}"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(

                onPressed: () {
                  cart.addToCart(product);
                },
                child: Text("Đặt hàng",
                  style: TextStyle(color: Colors.black),)
                ),
            ),
          ],
        ),
      ),
    );
  }
}
