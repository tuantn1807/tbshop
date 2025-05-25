import 'package:ml_linalg/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbshop/service_AI/preprocess_service.dart';
import 'dart:math';
import '../models/cart_item_model.dart';
import '../models/click_event_model.dart';
import '../models/rating_model.dart';
import 'firebase_service.dart';

class HybridRecommender {
  final PreprocessingService preprocessingService;
  final firebaseService = FirebaseService();

  HybridRecommender(this.preprocessingService);
  Future<List<String>> recommendProducts(
      Map<String, List<CartItem>> userCartData,
      List<RatingModel> allRatings,
      List<ClickEvent> allClicks,
      List<String> allProductIds,
      Map<String, String> productCategoryMap,
      ) async {
    final cartFeatures = preprocessingService.extractCartFeatures(userCartData);
    final ratingFeatures = preprocessingService.extractRatingFeatures(allRatings);
    final clickFeatures = preprocessingService.extractClickFeatures(allClicks);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("id");
    if (userId == null) return [];

    int totalCart = cartFeatures.values.fold(0, (sum, map) => sum + map.length);
    int totalRating = ratingFeatures.values.fold(0, (sum, map) => sum + map.length);
    int totalClick = clickFeatures.values.fold(0, (sum, map) => sum + map.length);
    int total = totalCart + totalRating + totalClick;

    List<double> weights = total == 0
        ? [0.0, 0.0, 1.0] // fallback nếu không có dữ liệu
        : [
      totalCart / total,
      totalRating / total,
      totalClick / total,
    ];

    final mergedFeatures = preprocessingService.mergeFeatures(
      [cartFeatures, ratingFeatures, clickFeatures],
      weights,
    );

    final userFeature = mergedFeatures[userId];
    if (userFeature == null || userFeature.isEmpty) {
      print("Không có dữ liệu cho user → fallback gợi ý top click");
      return getTopClickedProducts(clickFeatures, allProductIds);
    }

    final userHistory = {
      ...?cartFeatures[userId]?.keys,
      ...?ratingFeatures[userId]?.keys,
      ...?clickFeatures[userId]?.keys,
    };


    final Map<String, int> categoryCount = {};
    for (var pid in userFeature.keys) {
      final category = productCategoryMap[pid];
      if (category != null) {
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
    }


    final topCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final Set<String> preferredCategories = topCategories.take(2).map((e) => e.key).toSet();


    final Map<String, double> totalProductScores = {};
    mergedFeatures.forEach((uid, productMap) {
      productMap.forEach((productId, score) {
        totalProductScores[productId] =
            (totalProductScores[productId] ?? 0.0) + score;
      });
    });


    final recommendations = totalProductScores.entries
        .where((entry) => !userHistory.contains(entry.key))
        .toList()
      ..sort((a, b) {
        final catA = productCategoryMap[a.key];
        final catB = productCategoryMap[b.key];
        final inCatA = preferredCategories.contains(catA ?? '');
        final inCatB = preferredCategories.contains(catB ?? '');

        if (inCatA && !inCatB) return -1;
        if (!inCatA && inCatB) return 1;
        return b.value.compareTo(a.value);
      });

    final topRecommendations = recommendations.map((e) => e.key).take(10).toList();
    if (topRecommendations.isEmpty) {
      return getTopClickedProducts(clickFeatures, allProductIds);
    }

    return topRecommendations;
  }
  List<String> getTopClickedProducts(
      Map<String, Map<String, double>> clickFeatures,
      List<String> allProductIds,
      ) {
    final Map<String, double> totalClicks = {};
    clickFeatures.values.forEach((productMap) {
      productMap.forEach((productId, count) {
        totalClicks[productId] = (totalClicks[productId] ?? 0.0) + count;
      });
    });

    final topProducts = totalClicks.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return topProducts.map((e) => e.key).take(10).toList();
  }


}