import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final DatabaseReference _orderRef = FirebaseDatabase.instance.ref().child('carts');
  Map<String, Map<String, dynamic>> _allOrders = {};
  Map<String, bool> _orderExpansionState = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllOrders();
  }

  Future<void> _loadAllOrders() async {
    final snapshot = await _orderRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      Map<String, Map<String, dynamic>> loadedOrders = {};

      data.forEach((userId, userOrders) {
        final ordersMap = Map<String, dynamic>.from(userOrders);
        ordersMap.forEach((orderId, orderData) {
          final productList = Map<String, dynamic>.from(orderData);
          loadedOrders['$userId|$orderId'] = productList;
        });
      });

      setState(() {
        _allOrders = loadedOrders;
        _orderExpansionState = {
          for (var key in loadedOrders.keys) key: false,
        };
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _toggleStatus(String userId, String orderId, String productId, String currentStatus) async {
    String newStatus = (currentStatus == 'chưa giao')
        ? 'đang giao'
        : (currentStatus == 'đang giao')
        ? 'đã giao'
        : 'chưa giao';

    await _orderRef.child(userId).child(orderId).child(productId).child('status').set(newStatus);

    setState(() {
      _allOrders['$userId|$orderId']![productId]['status'] = newStatus;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'chưa giao':
        return Colors.red;
      case 'đang giao':
        return Colors.amber;
      case 'đã giao':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate).toLocal();
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('Danh sách đơn hàng'),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _allOrders.isEmpty
          ? Center(child: Text('Không có đơn hàng nào.', style: TextStyle(color: Colors.white)))
          : ListView(
        padding: EdgeInsets.all(8),
        children: _allOrders.entries.map((entry) {
          final userAndOrderId = entry.key.split('|');
          final userId = userAndOrderId[0];
          final orderId = userAndOrderId[1];
          final products = Map<String, dynamic>.from(entry.value);

          final firstProductEntry = products.entries.firstWhere(
                (e) => e.value is Map && (e.value as Map).containsKey('name'),
            orElse: () => MapEntry('', {}),
          );
          final firstProduct = Map<String, dynamic>.from(firstProductEntry.value);

          final buyerName = firstProduct['receiverName'] ?? 'Không rõ';
          final address = firstProduct['address'] ?? 'Không rõ';
          final orderTime = firstProduct['orderTime'];


          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _orderExpansionState['$userId|$orderId'] =
                    !_orderExpansionState['$userId|$orderId']!;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Đơn hàng: $orderId", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("Người mua: $buyerName", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      if (orderTime != null)
                        Text(
                          'Ngày đặt: ${DateTime.tryParse(orderTime) != null ? formatDate(orderTime) : orderTime}',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      Text("Địa chỉ: $address", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              if (_orderExpansionState['$userId|$orderId']!)
                ...products.entries.map((productEntry) {
                 final productId = productEntry.key;
                  final product = Map<String, dynamic>.from(productEntry.value);
                  final name = product['name'] ?? '';
                  final image = product['image'] ?? '';
                  final quantity = product['quantity'] ?? 0;
                  final price = product['price'] ?? 0;
                  final discount = product['discount'] ?? 0;
                  final discountedPrice = (price * (1 - discount / 100)).toStringAsFixed(2);
                  final status = product['status'] ?? 'chưa giao';

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: image.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(image, width: 55, height: 55, fit: BoxFit.cover),
                      )
                          : Icon(Icons.shopping_bag, size: 50, color: Colors.white),
                      title: Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         SizedBox(height: 4),
                          Text('Giá: $price', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 2),
                          Text('Giảm giá: $discount%', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 2),
                          Text('Giá sau giảm: $discountedPrice', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 2),
                          Text('Số lượng: $quantity', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () => _toggleStatus(userId, orderId, productId, status),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: getStatusColor(status),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(status, style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  );
                }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }
}
