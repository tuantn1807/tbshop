import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/rating_model.dart';

class RatingViewModel extends ChangeNotifier {
  final _db = FirebaseDatabase.instance.ref();

  // Add or update a rating
  Future<void> addOrUpdateRating(RatingModel rating) async {
    final path = "ratings/${rating.productId}_${rating.userId}";
    await _db.child(path).set(rating.toJson());
    notifyListeners();
  }

  // Delete a rating
  Future<void> deleteRating(String productId, String userId) async {
    final path = "ratings/${productId}_${userId}";
    await _db.child(path).remove();
    notifyListeners();
  }

  // Fetch a specific user's rating for a product
  Future<RatingModel?> fetchUserRating(String productId, String userId) async {
    final snapshot = await _db.child("ratings/${productId}_${userId}").get();
    if (snapshot.exists) {
      return RatingModel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  // Fetch all ratings for a product
  Future<List<RatingModel>> fetchRatings(String productId) async {
    final snapshot = await _db.child("ratings").orderByKey().get();
    if (snapshot.exists) {
      final ratings = Map<String, dynamic>.from(snapshot.value as Map);
      return ratings.values
          .map((value) => RatingModel.fromJson(Map<String, dynamic>.from(value)))
          .where((rating) => rating.productId == productId)
          .toList();
    }
    return [];
  }
  Future<Map<String, dynamic>> fetchRatingsWithAverage() async {
    final snapshot = await _db.child("ratings").get();
    if (snapshot.exists) {
      final ratingsMap = Map<String, dynamic>.from(snapshot.value as Map);

      List<RatingModel> allRatings = [];

      // Lấy toàn bộ đánh giá
      ratingsMap.forEach((key, value) {
        final rating = RatingModel.fromJson(Map<String, dynamic>.from(value));
        allRatings.add(rating);
      });

      // Tính điểm trung bình tất cả đánh giá
      final totalStars = allRatings.fold(0, (sum, r) => sum + r.star);
      final average = allRatings.isNotEmpty ? totalStars / allRatings.length : 0.0;

      return {
        "averageRating": average,
        "ratings": allRatings.take(20).toList(), // lấy 20 đánh giá đầu tiên
      };
    }

    return {
      "averageRating": 0.0,
      "ratings": [],
    };
  }


}
