import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbshop/View/Login/register.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../Admin/HomePageAdmin.dart';
import '../User/HomePage.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LoginState();
}

class _LoginState extends State<LogIn> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.green,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Shop tạp hóa", style: TextStyle(color: Colors.white, fontSize: 40)),
                  SizedBox(height: 10),
                  Text("Đăng nhập để tiếp tục", style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 60),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: <Widget>[
                              // Ô SĐT
                              CustomTextField(
                                controller: phoneController,
                                hintText: "SĐT",
                                iconData: Icons.phone_in_talk,
                              ),
                              const SizedBox(height: 10),

                              // Ô Mật khẩu
                              CustomTextField(
                                controller: passwordController,
                                hintText: "Mật khẩu",
                                iconData: Icons.password,
                                isPassword: true,
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 30),
                       // const Text("Quên mật khẩu?", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                        CustomButton(
                          onTap: () async {
                            bool success = await authViewModel.login(
                              phoneController.text.trim(),
                              passwordController.text.trim(),
                            );

                            if (success) {
                              final role = authViewModel.currentUser?.role ?? "User";
                              if (role == "Admin") {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePageAdmin()),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage()),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Sai số điện thoại hoặc mật khẩu")),
                              );
                            }
                          },
                          text: "Đăng nhập",
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Chưa có tài khoản? Nhấn"),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Register()),
                                );
                              },
                              child: const Text(" Đăng ký", style: TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
