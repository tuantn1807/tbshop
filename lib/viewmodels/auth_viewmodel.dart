import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("users");

  UserModel? _currentUser;
  bool get isAdmin => _currentUser?.role == 'Admin';
  UserModel? get currentUser => _currentUser;

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<bool> register(UserModel user) async {
    try {
      // Tạo UID
      String userId = _dbRef.push().key ?? '';

      if (userId.isEmpty) return false;

      // Mã hóa mật khẩu trước khi lưu
      String hashedPassword = hashPassword(user.password);

      await _dbRef.child(userId).set({
        "id": userId,
        "name": user.name,
        "phone": user.phone,
        "password": hashedPassword, // Lưu mật khẩu đã mã hóa
        "gender": user.gender,
        "role": user.role,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    try {
      final snapshot = await _dbRef.get();

      if (snapshot.exists) {
        for (var child in snapshot.children) {
          final userData = child.value as Map<dynamic, dynamic>;

          String hashedPassword = hashPassword(password);

          if (userData["phone"] == phone && userData["password"] == hashedPassword) {
            _currentUser = UserModel.fromJson(userData, userData["id"]); // Sửa 'uid' thành 'id'

            // Lưu 'id' vào SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString("id", userData["id"]); // Sửa 'uid' thành 'id'

            notifyListeners();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  Future<bool> loadUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("id"); // Lấy 'id' thay vì 'uid'

    if (userId != null) {
      // Load thêm user nếu cần
      final snapshot = await _dbRef.child(userId).get(); // Sử dụng 'id'
      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        _currentUser = UserModel.fromJson(userData, userId); // Sửa 'uid' thành 'id'
        return true;
      }
    }
    return false;
  }

  //   void logout() {
//     _currentUser = null;
//     notifyListeners();
//   }
}

