import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RatingAdminScreen extends StatefulWidget {
  @override
  _RatingAdminScreenState createState() => _RatingAdminScreenState();
}

class _RatingAdminScreenState extends State<RatingAdminScreen> {
  final database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> ratingsData = [];
  double averageRating = 0;

  @override
  void initState() {
    super.initState();
    fetchRatings();
  }

  Future<void> fetchRatings() async {
    final ratingsSnap = await database.child("ratings").get();
    final ratingsMap = Map<String, dynamic>.from(ratingsSnap.value as Map);

    List<Map<String, dynamic>> temp = [];
    double totalStars = 0;

    for (var entry in ratingsMap.entries) {
      final rating = Map<String, dynamic>.from(entry.value);

      final productSnap = await database.child("products/${rating['productId']}").get();
      final productName = productSnap.child("name").value ?? "Không rõ";

      final userSnap = await database.child("users/${rating['userId']}").get();
      final userName = userSnap.child("name").value ?? "Ẩn danh";

      final star = double.tryParse(rating["star"].toString()) ?? 0;
      totalStars += star;

      temp.add({
        "comment": rating["comment"],
        "star": star,
        "productName": productName,
        "userName": userName,
      });
    }

    setState(() {
      ratingsData = temp;
      averageRating = ratingsData.isNotEmpty ? totalStars / ratingsData.length : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tất cả đánh giá")),
      body: ratingsData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ratingsData.length,
              itemBuilder: (context, index) {
                final data = ratingsData[index];
                return ListTile(
                  title: Text("${data['productName']} - ${data['userName']}"),
                  subtitle: Text("Comment: ${data['comment']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(data['star'].toString()),
                      SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Đánh giá trung bình: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  averageRating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 4),
                Icon(Icons.star, color: Colors.amber, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
