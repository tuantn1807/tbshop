import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../viewmodels/category_viewmodel.dart';



class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm Danh Mục")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Tên danh mục"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String categoryName = _nameController.text.trim();
                if (categoryName.isNotEmpty) {
                  try {
                    await context.read<CategoryViewModel>().addCategory(categoryName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đã thêm danh mục thành công!")),
                    );
                    _nameController.clear(); // Xóa nội dung nhập sau khi thêm
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi khi thêm danh mục: $e")),
                    );
                  }
                }
              },
              child: Text("Thêm danh mục"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
