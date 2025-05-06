import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item_model.dart';
import '../../models/click_event_model.dart';
import '../../models/product_model.dart';
import '../../models/rating_model.dart';
import '../../service_AI/firebase_service.dart';
import '../../service_AI/preprocess_service.dart';
import '../../service_AI/recommender_service.dart';
import '../../viewmodels/cart_viewmodel.dart';

class RecommendationScreen extends StatefulWidget {
  final String userId;
  final Map<String, List<CartItem>> allCartData;
  final List<RatingModel> allRatings;
  final List<ClickEvent> allClicks;
  final List<String> allProductIds;

  const RecommendationScreen({
    super.key,
    required this.userId,
    required this.allCartData,
    required this.allRatings,
    required this.allClicks,
    required this.allProductIds,
  });

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final firebaseService = FirebaseService();
  final recommendationService = HybridRecommender(PreprocessingService());
  late CartViewModel cart;
  List<ProductModel> recommendedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cart = Provider.of<CartViewModel>(context, listen: false);
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    try {
      print("Đang xử lý gợi ý cho user: ${widget.userId}");

      // Tải thông tin sản phẩm để xây dựng productCategoryMap
      final allProducts = await firebaseService.fetchAllProducts();
      final Map<String, String> productCategoryMap = {
        for (var product in allProducts) product.id: product.categoryId ?? '',
      };

      final recommendedProductIds = await recommendationService
          .recommendProducts(
        widget.allCartData,
        widget.allRatings,
        widget.allClicks,
        widget.allProductIds,
        productCategoryMap, // Bổ sung
      );

      print("Gợi ý sản phẩm ID: $recommendedProductIds");

      if (recommendedProductIds.isEmpty) {
        setState(() {
          recommendedItems = [];
          isLoading = false;
        });
        return;
      }

      final productItems = await firebaseService.fetchProductsByIds(
          recommendedProductIds);

      print("Sản phẩm thực tế tải về: ${productItems.length}");

      setState(() {
        recommendedItems = productItems;
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải gợi ý: $e');
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm gợi ý')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recommendedItems.isEmpty
          ? const Center(child: Text('Không có gợi ý nào.'))
          : ListView.builder(
        itemCount: recommendedItems.length,
        itemBuilder: (context, index) {
          final item = recommendedItems[index];

          return Card(
            child: ListTile(
              leading: item.image.isNotEmpty
                  ? Image.network(
                item.image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
              )
                  : const Icon(Icons.image_not_supported, size: 50),
              title: Text(item.name),
              subtitle: Text(
                'Giá: ${item.price.toStringAsFixed(0)} VNĐ\n'
                    'Số lượng: ${item.quantity}\n'
                    'Giá sau giảm: ${(item.price * (1 - item.discount/100))
                    .toStringAsFixed(0)} VNĐ',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  cart.addToCart(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item
                        .name} đã được thêm vào giỏ hàng')),
                  );
                },
                child: const Text('Thêm vào giỏ'),
              ),
            ),
          );
        },
      ),
    );
  }
}