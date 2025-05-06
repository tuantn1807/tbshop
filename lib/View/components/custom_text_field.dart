import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? iconData;
  final double radius;
  final bool isPassword;
  final TextInputType? keyboardType;
  final List<dynamic>? inputFormatters;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.iconData,
    this.radius = 12,
    this.isPassword = false,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.lightGreen, width: 1.5), // đoạn width giúp nó thành ô hình chữ nhật
        borderRadius: BorderRadius.circular(radius), //bo tròn viền hình chữ nhật
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          border: InputBorder.none, //xóa dấu gạch ngang dưới ô chữ nhật
          hintText: hintText,
          prefixIcon: iconData == null
            ? null // nếu đúng là null
            : Icon(iconData, color: Colors.lightGreen,), // nếu ko phải là null
          prefixIconConstraints: BoxConstraints(minWidth: 50), //tạo khoảng cách giữa icon và dòng chữ
        ),
      ),
    );
  }
}