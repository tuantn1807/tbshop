import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/product_model.dart';
import '../../../../viewmodels/category_viewmodel.dart';
import '../../../../viewmodels/product_viewmodel.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Uint8List? _imageBytes;
  bool _isUploading = false;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<CategoryViewModel>().fetchCategories();
  }

  Future<void> _pickImage() async {
    final bytes =
    await context.read<ProductViewModel>().pickImage();
    if (bytes != null) {
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _addProduct() async {
    if (_imageBytes == null || _selectedCategoryId == null) return;

    setState(() => _isUploading = true);

    final product = ProductModel(
      id: "",
      name: _nameController.text,
      categoryId: _selectedCategoryId!,
      price: double.parse(_priceController.text),
      quantity: int.parse(_quantityController.text),
      discount: double.parse(_discountController.text),
      description: _descriptionController.text,
      image: "",
    );

    await context
        .read<ProductViewModel>()
        .addProduct(product, _imageBytes);

    setState(() => _isUploading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        context.watch<CategoryViewModel>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text("Thêm sản phẩm")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration:
                const InputDecoration(labelText: "Tên sản phẩm"),
              ),

              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration:
                const InputDecoration(labelText: "Danh mục"),
                items: categories
                    .map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategoryId = v),
              ),

              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Giá"),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: "Số lượng"),
              ),
              TextField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: "Giảm giá"),
              ),
              TextField(
                controller: _descriptionController,
                decoration:
                const InputDecoration(labelText: "Mô tả"),
              ),

              const SizedBox(height: 12),

              _imageBytes != null
                  ? Image.memory(
                _imageBytes!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              )
                  : IconButton(
                icon: const Icon(Icons.image),
                onPressed: _pickImage,
              ),

              const SizedBox(height: 20),

              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addProduct,
                child: const Text("Thêm sản phẩm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
