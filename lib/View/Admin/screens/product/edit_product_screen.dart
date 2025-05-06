import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../models/product_model.dart';
import '../../../../viewmodels/product_viewmodel.dart';
import '../../../../models/category_model.dart';
import '../../../../viewmodels/category_viewmodel.dart';

class ProductDetailEditScreen extends StatefulWidget {
  final ProductModel product;

  ProductDetailEditScreen({required this.product});

  @override
  _ProductDetailEditScreenState createState() => _ProductDetailEditScreenState();
}

class _ProductDetailEditScreenState extends State<ProductDetailEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _discountController;
  late TextEditingController _descriptionController;

  File? _newImageFile;
  bool _isUploading = false;
  String? _selectedCategoryId;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
    _discountController = TextEditingController(text: widget.product.discount.toString());
    _descriptionController = TextEditingController(text: widget.product.description);
    _selectedCategoryId = widget.product.categoryId;

    // Fetch categories
    Provider.of<CategoryViewModel>(context, listen: false).fetchCategories();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);

    final updatedProduct = ProductModel(
      id: widget.product.id,
      image: widget.product.image,
      name: _nameController.text,
      categoryId: _selectedCategoryId!,
      price: double.parse(_priceController.text),
      quantity: int.parse(_quantityController.text),
      discount: double.parse(_discountController.text),
      description: _descriptionController.text,
    );

    await productViewModel.updateProduct(updatedProduct, _newImageFile);

    setState(() {
      _isUploading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoryViewModel = Provider.of<CategoryViewModel>(context);
    final categories = categoryViewModel.categories;

    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết sản phẩm")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _newImageFile != null
                        ? Image.file(_newImageFile!, width: 150, height: 150, fit: BoxFit.cover)
                        : Image.network(widget.product.image, width: 150, height: 150, fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _pickImage, child: Text("Chọn ảnh mới")),
              SizedBox(height: 10),

              _buildTextField(_nameController, "Tên sản phẩm"),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Consumer<CategoryViewModel>(
                  builder: (context, categoryViewModel, child) {
                    final categories = categoryViewModel.categories;

                    if (categories.isEmpty) {
                      return Text("Không có danh mục nào.", style: TextStyle(color: Colors.red));
                    }

                    // Đảm bảo _selectedCategoryId có giá trị hợp lệ
                    if (_selectedCategoryId == null || !categories.any((cat) => cat.id == _selectedCategoryId)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _selectedCategoryId = categories.first.id;
                        });
                      });
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: "Danh mục",
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((CategoryModel category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) => value == null ? "Vui lòng chọn danh mục" : null,
                    );
                  },
                ),
              ),

              _buildTextField(_priceController, "Giá", isNumber: true),
              _buildTextField(_quantityController, "Số lượng", isNumber: true),
              _buildTextField(_discountController, "Giảm giá (%)", isNumber: true),
              _buildTextField(_descriptionController, "Mô tả", maxLines: 3),

              SizedBox(height: 20),
              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _updateProduct,
                child: Text("Lưu thay đổi"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return "Vui lòng nhập $label";
          if (isNumber && double.tryParse(value) == null) return "$label phải là số hợp lệ";
          return null;
        },
        maxLines: maxLines,
      ),
    );
  }
}