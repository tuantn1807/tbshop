import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double radius;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
    this.color = Colors.lightGreen,
    this.textColor = Colors.white,
    this.borderColor = Colors.lightGreen,
    this.radius = 20,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(//InWell có chức năng thao tác, phù hợp cho việc tạo nút
      onTap: onTap,
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 100),
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 1.5), // đoạn width giúp nó thành ô hình chữ nhật
            borderRadius: BorderRadius.circular(radius), //bo tròn viền hình chữ nhật
        ),
        child: Text(text, style: TextStyle(color: textColor),),
      ),
    ),
        );
  }
}