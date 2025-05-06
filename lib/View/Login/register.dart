import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();

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
                  Text("Tạo tài khoản mới", style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Column(
                      children: [

                        Column(
                          children: [
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: nameController,
                              hintText: "Họ và tên",
                              iconData: Icons.account_circle_rounded,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: phoneController,
                              hintText: "SĐT",
                              iconData: Icons.phone_android,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: passwordController,
                              hintText: "Mật khẩu",
                              iconData: Icons.lock,
                              isPassword: true,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: ageController,
                              hintText: "Tuổi",
                              iconData: Icons.cake,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(height: 10),
                            // Dropdown có viền xanh
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green, width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(border: InputBorder.none),
                                hint: const Text("Giới tính"),
                                value: null,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: [
                                  "Nam",
                                  "Nữ",
                                  "Giới tính thứ 3",
                                  "Không muốn cho biết",
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  genderController.text = value ?? "";
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                        CustomButton(
                          onTap: () async {
                            UserModel newUser = UserModel(
                              id: phoneController.text,
                              name: nameController.text,
                              phone: phoneController.text,
                              password: passwordController.text,
                              gender: genderController.text,
                              role: "User",
                            );

                            bool success = await authViewModel.register(newUser);
                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LogIn()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Số điện thoại đã tồn tại")),
                              );
                            }
                          },
                          text: "Đăng ký",
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Đã có tài khoản?"),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LogIn()),
                                );
                              },
                              child: const Text(" Đăng nhập", style: TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),
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
