import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../models/product_model.dart';
import '../../models/rating_model.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/rating_viewmodel.dart';


class ProductDetails extends StatefulWidget {
  final ProductModel product;

  const ProductDetails({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  double starCount = 0;
  TextEditingController commentController = TextEditingController();
  List<RatingModel> ratings = [];
  String? currentUserId;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadUserIdAndRatings();
  }

  Future<void> loadUserIdAndRatings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString("id");
    await loadRatings();
    if (currentUserId != null) {
      await loadUserRating();
    }
  }

  Future<void> loadRatings() async {
    final ratingVM = Provider.of<RatingViewModel>(context, listen: false);
    final loadedRatings = await ratingVM.fetchRatings(widget.product.id);
    setState(() {
      ratings = loadedRatings;
    });
  }

  Future<void> loadUserRating() async {
    final ratingVM = Provider.of<RatingViewModel>(context, listen: false);
    final rating = await ratingVM.fetchUserRating(widget.product.id, currentUserId!);
    if (rating != null) {
      setState(() {
        starCount = rating.star.toDouble();
        commentController.text = rating.comment;
        isEditing = false; // mặc định đã đánh giá thì không cho sửa ngay
      });
    }
  }

  Future<void> submitRating() async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn cần đăng nhập để đánh giá.")),
      );
      return;
    }

    final ratingVM = Provider.of<RatingViewModel>(context, listen: false);
    final newRating = RatingModel(
      productId: widget.product.id,
      userId: currentUserId!,
      star: starCount.toInt(),
      comment: commentController.text,
    );
    await ratingVM.addOrUpdateRating(newRating);
    await loadRatings();
    setState(() {
      isEditing = false; // Khóa lại sau khi chỉnh sửa
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đánh giá đã được lưu")));
  }

  Future<void> deleteRating() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa đánh giá này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Không")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Có")),
        ],
      ),
    );

    if (confirm == true && currentUserId != null) {
      final ratingVM = Provider.of<RatingViewModel>(context, listen: false);
      await ratingVM.deleteRating(widget.product.id, currentUserId!);
      setState(() {
        starCount = 0;
        commentController.clear();
        isEditing = true;
      });
      await loadRatings();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã xóa đánh giá")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(widget.product.image, height: 200, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 16),
            Text(widget.product.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Giá: ${widget.product.price}đ", style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 8),
            Text("Số lượng còn: ${widget.product.quantity}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text("Mô tả sản phẩm:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(widget.product.description, style: TextStyle(fontSize: 16)),

            Divider(height: 32, thickness: 1),

            Text("Đánh giá sản phẩm:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            if (currentUserId != null && (starCount == 0 || isEditing)) ...[
              RatingBar.builder(
                initialRating: starCount,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() {
                    starCount = rating;
                  });
                },
              ),
              SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: "Nhập bình luận của bạn...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: submitRating,
                child: Text("Gửi đánh giá"),
              ),
            ] else if (starCount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Đánh giá của bạn: $starCount ★", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: deleteRating,
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Text(commentController.text),
              ),
            ],

            Divider(height: 32, thickness: 1),

            Text("Tất cả đánh giá:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...ratings.map((r) => Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text("${r.star} ★"),
                subtitle: Text(r.comment),
              ),
            )),

            SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => cartViewModel.addToCart(widget.product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Thêm giỏ hàng", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
