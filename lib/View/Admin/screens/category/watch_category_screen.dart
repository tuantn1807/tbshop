import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/category_model.dart';
import '../../../../viewmodels/category_viewmodel.dart';


class CategoryListScreen extends StatefulWidget {
  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<CategoryViewModel>(context, listen: false).fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final categoryViewModel = Provider.of<CategoryViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Danh sách danh mục")),
      body: categoryViewModel.categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categoryViewModel.categories.length,
        itemBuilder: (context, index) {
          CategoryModel category = categoryViewModel.categories[index];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(category.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editCategory(context, category),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, category),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _editCategory(BuildContext context, CategoryModel category) {
    TextEditingController _controller = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Chỉnh sửa danh mục"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Tên danh mục"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                String newName = _controller.text.trim();
                if (newName.isNotEmpty) {
                  Provider.of<CategoryViewModel>(context, listen: false)
                      .updateCategory(category.id, newName);
                  Navigator.pop(context);
                }
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Xóa danh mục"),
          content: Text("Bạn có chắc muốn xóa danh mục '${category.name}' không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<CategoryViewModel>(context, listen: false)
                    .deleteCategory(category.id);
                Navigator.pop(context);
              },
              child: Text("Xóa"),
            ),
          ],
        );
      },
    );
  }
}
