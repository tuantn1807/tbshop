// lib/Tuan/models/rating_model.dart
class RatingModel {
  final String productId;
  final int star;
  final String comment;
  final String userId;

  RatingModel({
    required this.productId,
    required this.star,
    required this.comment,
    required this.userId,
  });

  // Convert RatingModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'star': star,
      'comment': comment,
      'userId': userId,
    };
  }

  // Create RatingModel from JSON
  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      productId: json['productId'],
      star: json['star'],
      comment: json['comment'],
      userId: json['userId'],
    );
  }
  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      productId: map['productId'],
      star: map['star'],
      comment: map['comment'] ?? '',
      userId: map['userId'],
    );
  }
}