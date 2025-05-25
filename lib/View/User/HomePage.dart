import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbshop/View/User/product_details.dart';
import 'package:tbshop/View/components/promotion_card.dart';

import '../../chat_screen.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../Login/login.dart';
import '../components/appbar_homepage.dart';
import '../components/chat_button.dart';
import '../components/search_result_widget.dart';
import '../components/user_info_screen.dart';
import 'cart_screen.dart';
import 'category_list.dart';
import '../recomender/recomender_screen.dart';
import '../../service_AI/firebase_service.dart';
import '../../models/cart_item_model.dart';
import '../../models/click_event_model.dart';
import '../../models/rating_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firebaseService = FirebaseService();
  final categoryViewModel = CategoryViewModel();
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  List<ProductModel> _filteredProducts = [];
  List<ProductModel> _allProducts = [];
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productsRef = FirebaseDatabase.instance.ref().child('products');
      final snapshot = await productsRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        List<ProductModel> products = [];

        data.forEach((key, value) {
          if (value is Map) {
            final productData = Map<String, dynamic>.from(value as Map);
            final product = ProductModel.fromMap(productData, key);
            products.add(product);
          }
        });

        setState(() {
          _allProducts = products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải sản phẩm: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredProducts = _allProducts
          .where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
          (product.description != null &&
              product.description!.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  Future<void> _handleProductClick(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("id");

    if (userId != null) {
      await firebaseService.logClick(userId, productId);
    }

    final product = _allProducts.firstWhere((p) => p.id == productId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetails(product: product),
      ),
    );
  }

  Future<void> navigateToRecommendScreen(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("id");

    if (userId == null) {
      print("Không tìm thấy ID người dùng.");
      return;
    }

    final allCartData = await firebaseService.fetchAllCartItems();
    final allRatings = await firebaseService.fetchRatings();
    final allClicks = await firebaseService.fetchClickEvents();
    final allProductIds = await firebaseService.fetchAllProductIds();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendationScreen(
          userId: userId,
          allCartData: allCartData,
          allRatings: allRatings,
          allClicks: allClicks,
          allProductIds: allProductIds,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        navigateToRecommendScreen(context);
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CartScreen()),
        );
        break;
      case 4:
        _handleUserAccount();
        break;
    }
  }

  Future<void> _handleUserAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("id");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => id == null || id.isEmpty ? LogIn() : UserInfoScreen(),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredProducts = [];
      _isSearching = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'SHOP TẠP HÓA',
          style: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _searchProducts,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.green[400], size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[400]),
                    onPressed: _clearSearch,
                  )
                      : null,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: TextStyle(fontSize: 14),
              ),
            ),
            if (_isSearching)
              Expanded(
                child: SearchResultWidget(
                  isLoading: _isLoading,
                  filteredProducts: _filteredProducts,
                  onProductTap: _handleProductClick,
                )
              ),
            if (!_isSearching)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green[300]!,
                        Colors.green[500]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: PromotionCard(),
                ),
              ),
            if (!_isSearching)
              Expanded(
                child: CategoryList(
                  onProductClick: (productId) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? userId = prefs.getString("id");
                    if (userId == null) return;
                    await firebaseService.logClick(userId, productId);
                    final productRef = FirebaseDatabase.instance.ref().child('products').child(productId);
                    final snapshot = await productRef.get();
                    if (snapshot.exists) {
                      final productData = Map<String, dynamic>.from(snapshot.value as Map);
                      final product = ProductModel.fromMap(productData, productId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetails(product: product),
                        ),
                      );
                    } else {
                      print('Không tìm thấy sản phẩm với ID: $productId');
                    }
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      )
    );
  }
}