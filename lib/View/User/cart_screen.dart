import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbshop/View/components/custom_text_field.dart';

import '../../viewmodels/cart_viewmodel.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartViewModel>(context);

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(title: Text("Giỏ hàng"),
      backgroundColor: Colors.green[700]), // Set app bar color to green
      body: cart.items.isEmpty
          ? Center(child: Text("Giỏ hàng trống"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return ListTile(
                  leading: Image.network(item.product.image, width: 60),
                  title: Text(item.product.name),
                  subtitle: Text(
                    "Giá: ${item.product.price}đ\nSố lượng: ${item.quantity}\nGiảm giá: ${item.product.discount}%\nGiá sau giảm: ${(item.product.price * (1 - item.product.discount / 100)).toStringAsFixed(2)}đ",
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => cart.removeFromCart(item.product),
                  ),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                CustomTextField(controller: nameController, hintText: "Tên người nhận", iconData: Icons.person),
                CustomTextField(controller: phoneController, hintText: "Số điện thoại", iconData: Icons.phone),
                CustomTextField(controller: addressController, hintText: "Địa chỉ", iconData: Icons.home),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Tổng tiền: ${cart.totalPrice.round()}đ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  addressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
                );
                return;
              }
              await cart.uploadOrder(
                receiverName: nameController.text,
                phoneNumber: phoneController.text,
                address: addressController.text,
              );

              final uid = await cart.getCartId();
              final database = FirebaseDatabase.instance.ref();
              final newOrderRef = database.child("carts/$uid").push();

              final Map<String, dynamic> productMap = {};
              for (var item in cart.items) {
                productMap[item.product.id] = {
                  "name": item.product.name,
                  "price": item.product.price,
                  "image": item.product.image,
                  "quantity": item.quantity,
                  "status": item.status,
                  "orderTime": DateTime.now().toIso8601String(),
                  "receiverName": nameController.text,
                  "phoneNumber": phoneController.text,
                  "address": addressController.text,
                };
              }
              await newOrderRef.set(productMap);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Đặt hàng thành công!")),
              );
              cart.clearCart();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.green, width: 2),
              ),
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
            ),
            child: Text("Đặt hàng", style: TextStyle(fontSize: 18))
          ),
        ],
      ),
    );
  }
}