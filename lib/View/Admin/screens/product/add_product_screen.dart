import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:uuid/uuid.dart';

import '../../../../models/product_model.dart';
import '../../../../viewmodels/category_viewmodel.dart';
import '../../../../viewmodels/product_viewmodel.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    Provider.of<CategoryViewModel>(context, listen: false).fetchCategories();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isNotEmpty &&
        _selectedCategoryId != null &&
        _priceController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _discountController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _imageFile != null) {
      setState(() {
        _isUploading = true;
      });

      final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
      final newProduct = ProductModel(
        id: Uuid().v4(),
        name: _nameController.text,
        categoryId: _selectedCategoryId!,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        discount: double.parse(_discountController.text),
        description: _descriptionController.text,
        image: "",
      );

      await productViewModel.addProduct(newProduct, _imageFile!);

      setState(() {
        _isUploading = false;
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryViewModel = Provider.of<CategoryViewModel>(context);
    final categories = categoryViewModel.categories;

    return Scaffold(
      appBar: AppBar(title: Text("Thêm sản phẩm")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: "Tên sản phẩm")),

              // Dropdown danh mục
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                onChanged: (newValue) => setState(() => _selectedCategoryId = newValue),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: "Danh mục"),
              ),

              TextField(controller: _priceController, decoration: InputDecoration(labelText: "Giá"), keyboardType: TextInputType.number),
              TextField(controller: _quantityController, decoration: InputDecoration(labelText: "Số lượng"), keyboardType: TextInputType.number),
              TextField(controller: _discountController, decoration: InputDecoration(labelText: "Giảm giá"), keyboardType: TextInputType.number),
              TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Mô tả")),

              SizedBox(height: 10),
              _imageFile != null
                  ? Image.file(_imageFile!, width: 100, height: 100)
                  : IconButton(icon: Icon(Icons.image), onPressed: _pickImage),

              SizedBox(height: 20),
              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addProduct,
                child: Text("Thêm sản phẩm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
