class ClickEvent {
  final String userId;  // Thêm userId để liên kết
  final String productId;
  final DateTime timestamp;

  ClickEvent({
    required this.userId,
    required this.productId,
    required this.timestamp,
  });

  factory ClickEvent.fromMap(Map<String, dynamic> map, String userId) {
    return ClickEvent(
      userId: userId,  // userId được truyền vào
      productId: map['productId'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
