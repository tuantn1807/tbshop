

import 'package:tbshop/models/rating_model.dart';

class RatingService {
  Map<String, double> calculateAverageRating(List<RatingModel> ratings) {
    Map<String, List<int>> productRatings = {};

    for (var rating in ratings) {
      if (!productRatings.containsKey(rating.productId)) {
        productRatings[rating.productId] = [];
      }
      productRatings[rating.productId]!.add(rating.star);
    }

    Map<String, double> avgRatings = {};
    productRatings.forEach((productId, stars) {
      avgRatings[productId] = stars.reduce((a, b) => a + b) / stars.length;
    });

    return avgRatings;
  }

}