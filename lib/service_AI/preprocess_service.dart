import 'package:ml_linalg/matrix.dart';

import '../models/cart_item_model.dart';
import '../models/click_event_model.dart';
import '../models/rating_model.dart';


class PreprocessingService {
  // Tính tổng số lượng mua cho mỗi sản phẩm theo từng user
  Map<String, Map<String, double>> extractCartFeatures(
      Map<String, List<CartItem>> userCartData) {
    final cartFeatures = <String, Map<String, double>>{};
    userCartData.forEach((userId, items) {
      for (var item in items) {
        final productId = item.product.id;
        cartFeatures.putIfAbsent(userId, () => {});
        cartFeatures[userId]![productId] =
            (cartFeatures[userId]![productId] ?? 0) + item.quantity.toDouble();
      }
    });
    return cartFeatures;
  }

  // Tính điểm rating cho mỗi sản phẩm theo từng user
  Map<String, Map<String, double>> extractRatingFeatures(List<RatingModel> ratings) {
    final ratingFeatures = <String, Map<String, double>>{};
    for (var rating in ratings) {
      ratingFeatures.putIfAbsent(rating.userId, () => {});
      ratingFeatures[rating.userId]![rating.productId] = rating.star.toDouble();
    }
    return ratingFeatures;
  }

  // Đếm số lần click mỗi sản phẩm theo từng user
  Map<String, Map<String, double>> extractClickFeatures(List<ClickEvent> clicks) {
    final clickFeatures = <String, Map<String, double>>{};
    for (var click in clicks) {
      if (click.productId.isEmpty) continue;
      clickFeatures.putIfAbsent(click.userId, () => {});
      clickFeatures[click.userId]!.update(click.productId, (v) => v + 1.0, ifAbsent: () => 1.0);
    }
    return clickFeatures;
  }

  // Hợp nhất các feature lại theo trọng số, output dạng Map<UserId, Map<ProductId, Score>>
  Map<String, Map<String, double>> mergeFeatures(
      List<Map<String, Map<String, double>>> sources, List<double> weights) {
    final merged = <String, Map<String, double>>{};
    for (int i = 0; i < sources.length; i++) {
      final feature = sources[i];
      final weight = weights[i];
      feature.forEach((userId, productMap) {
        merged.putIfAbsent(userId, () => {});
        productMap.forEach((productId, value) {
          merged[userId]!.update(productId, (v) => v + value * weight, ifAbsent: () => value * weight);
        });
      });
    }
    return merged;
  }

  // Chuyển dữ liệu người dùng thành ma trận (không cần dùng nếu không clustering)
  Matrix convertToMatrix(Map<String, Map<String, double>> userFeatures,
      List<String> productIds) {
    final data = userFeatures.values.map((productMap) {
      return productIds.map((productId) => productMap[productId] ?? 0.0).toList();
    }).toList();
    return Matrix.fromList(data);
  }
}
