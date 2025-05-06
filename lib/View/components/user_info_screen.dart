import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:crypto/crypto.dart'; // Thêm import này vào đầu file
import 'dart:convert';


import '../../viewmodels/auth_viewmodel.dart';
import '../Login/login.dart';
import '../User/UserOrderScreen.dart';


class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _database = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();
  String? selectedGender;
  final currentPasswordController = TextEditingController(); // Mật khẩu hiện tại
  final newPasswordController = TextEditingController(); // Mật khẩu mới
  final List<String> genderOptions = [
    "Nam",
    "Nữ",
    "Giới tính thứ 3",
    "Không muốn cho biết",
  ];


  String? id;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString("id");
    print("ID trong UserInfoScreen: $id");

    if (id != null) {
      final snapshot = await _database.child("users/$id").once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map;
        setState(() {
          nameController.text = userData["name"] ?? "";
          phoneController.text = userData["phone"] ?? "";
          genderController.text = userData["gender"] ?? "";
          selectedGender = genderController.text; // <- thêm dòng này
          print(nameController);
          print(phoneController);
          print(genderController);

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Thêm xử lý nếu dữ liệu không tồn tại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không tìm thấy thông tin người dùng.")),
        );
      }
    } else {
      // Người dùng khách, không có uid
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn đang dùng tài khoản khách")),
      );
    }
  }



  void _updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final gender = selectedGender ?? "";
      final currentPassword = currentPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();

      try {
        // 1. Lấy thông tin người dùng từ Firebase
        final snapshot = await _database.child("users/$id").once();
        final userData = snapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (userData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Không tìm thấy thông tin người dùng trong CSDL.")),
          );
          return;
        }

        // 2. Kiểm tra đổi mật khẩu nếu người dùng nhập mật khẩu mới
        if (newPassword.isNotEmpty) {
          if (currentPassword.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Vui lòng nhập mật khẩu hiện tại để đổi mật khẩu.")),
            );
            return;
          }

          // 3. So sánh mật khẩu hiện tại đã nhập với mật khẩu trong Firebase
          final hashedCurrentInput = sha256.convert(utf8.encode(currentPassword)).toString();
          final hashedStoredPassword = userData["password"];

          if (hashedCurrentInput != hashedStoredPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Mật khẩu hiện tại không đúng.")),
            );
            return;
          }

          // 4. Mã hóa mật khẩu mới và cập nhật
          final hashedNewPassword = sha256.convert(utf8.encode(newPassword)).toString();

          await _database.child("users/$id").update({
            "password": hashedNewPassword,
          });
        }

        // 5. Cập nhật thông tin khác
        await _database.child("users/$id").update({
          "name": name,
          "phone": phone,
          "gender": gender,
        });

        // 6. Cập nhật local provider
        Future.delayed(Duration.zero, () {
          Provider.of<AuthViewModel>(context, listen: false).loadUserFromLocal();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cập nhật thông tin thành công!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi cập nhật thông tin: $e")),
        );
      }
    }
  }




  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("id");

    await FirebaseAuth.instance.signOut();

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
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Đăng xuất"),
        content: Text("Bạn có chắc muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              _logout(); // Gọi hàm logout
            },
            child: Text("Đăng xuất", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thông tin người dùng"),backgroundColor: Colors.green),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Họ và tên"),
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Số điện thoại"),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),


          DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: const InputDecoration(labelText: "Giới tính"),
          items: genderOptions.map((gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Vui lòng chọn giới tính";
            }
            return null;
          },
        ),

        TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Mật khẩu hiện tại"),
              ),
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: "Mật khẩu mới",
                  hintText: "Để trống nếu không muốn đổi mật khẩu",
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                    ),
                    onPressed: _updateUserInfo,
                    child: Text("Lưu thông tin", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchaseHistoryScreen(userId: id ?? ""),
                        ),
                      );
                    },
                    child: Text("Lịch sử đơn hàng", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _confirmLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                    ),
                    child: Text("Đăng xuất", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )

            ],
              ),

          ),
        ),

    );
  }
}
