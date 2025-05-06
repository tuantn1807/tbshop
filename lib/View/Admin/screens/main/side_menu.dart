import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../OrderScreen.dart';
import '../category/add_category_screen.dart';
import '../category/watch_category_screen.dart';
import '../product/add_product_screen.dart';
import '../product/watch_product_screen.dart';
import '../rating_product.dart';
class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text("QUẢN LÝ"),
          ),
          DrawerListTile(
            title: "Quản lý danh mục",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {},
            subItems: [
              SubItem(title: "DS danh mục", icon: Icons.add, press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoryListScreen()));
              }),
              SubItem(title: "Thêm danh mục", icon: Icons.add, press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddCategoryScreen()));
              }),
            ],
          ),
          DrawerListTile(
            title: "Quản lý sản phẩm",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {},
            subItems: [
              SubItem(title: "DS sản phẩm", icon: Icons.add, press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductListScreen()));
              }),
              SubItem(title: "Thêm sản phẩm", icon: Icons.add, press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddProductScreen()));
              }),
            ],
          ),
          DrawerListTile(
            title: "Quản lý đơn hàng",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderScreen(), // KHÔNG truyền userId
                ),
              );
            },
          ),
          DrawerListTile(
            title: "Xem đánh giá sản phẩm",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RatingAdminScreen(), // KHÔNG truyền userId
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
    this.subItems = const [],
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final List<SubItem> subItems;

  @override
  Widget build(BuildContext context) {
    return subItems.isNotEmpty
        ? ExpansionTile(
      leading: SvgPicture.asset(
        svgSrc,
        height: 16,
      ),
      title: Text(
        title,
      ),
      children: subItems.map((subItem) {
        return ListTile(
          onTap: subItem.press,
          leading: Icon(subItem.icon,size: 18), // Icon nhỏ lại
          title: Text(
            subItem.title,
            style: const TextStyle(fontSize: 12), // Thu nhỏ chữ subItems
          ),
          dense: true, // Giúp ListTile gọn hơn
          contentPadding: const EdgeInsets.symmetric(horizontal: 20), // Điều chỉnh padding
        );
      }).toList(),
    )
        : ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14), // Thu nhỏ chữ
      ),
      dense: true, // Làm cho ListTile nhỏ gọn hơn
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}

class SubItem {
  final String title;
  final IconData icon;
  final VoidCallback press;

  SubItem({
    required this.title,
    required this.icon,
    required this.press,
  });
}
