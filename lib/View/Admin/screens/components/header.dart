
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



import '../../../Login/login.dart';
import '../../../components/user_info_screen.dart';
import '../../constants.dart';
import '../../menu_app.dart';
import 'responsive.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context
                .read<MenuAppController>()
                .controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Dashboard",
            style: Theme
                .of(context)
                .textTheme
                .titleLarge,
          ),
        Spacer(), // Pushes the ProfileCard to the far right
        ProfileCard(),
      ],
    );
  }
}
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text("Admin"),
            ),
         // Icon(Icons.keyboard_arrow_down),

          // Tài khoản có menu xổ xuống
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfoScreen()),
                );
              } else if (value == 'logout') {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove("id");
                //await prefs.remove("role");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaterialApp(
                      debugShowCheckedModeBanner: false,
                      themeMode: ThemeMode.light, // Buộc về chế độ sáng
                      home: const LogIn(),
                    ),
                  ),
                      (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('Sửa thông tin'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Đăng xuất'),
              ),
            ],
          ),
        ],
      ),

    );
  }
}

