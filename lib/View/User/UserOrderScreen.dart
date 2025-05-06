import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  final String userId;

  const PurchaseHistoryScreen({required this.userId});

  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<String, Map<String, dynamic>> _orders = {};
  bool _loading = true;
  String _selectedStatus = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    final snapshot = await _dbRef.child('carts').child(widget.userId).get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      Map<String, Map<String, dynamic>> loaded = {};
      data.forEach((orderId, orderData) {
        loaded[orderId] = Map<String, dynamic>.from(orderData);
      });
      setState(() {
        _orders = loaded;
        _loading = false;
      });
    } else {
      setState(() {
        _orders = {};
        _loading = false;
      });
    }
  }

  Future<void> _buyAgain(String orderId) async {
    final cartRef = _dbRef.child('tempCarts').child(widget.userId);
    await cartRef.remove(); // Xóa giỏ hiện tại

    final orderProducts = _orders[orderId]!;
    for (var entry in orderProducts.entries) {
      final product = Map<String, dynamic>.from(entry.value);
      await cartRef.child(entry.key).set({
        'name': product['name'],
        'image': product['image'],
        'price': product['price'],
        'quantity': product['quantity'],
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm lại sản phẩm vào giỏ hàng')));
  }

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate).toLocal();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _selectedStatus == 'Tất cả'
        ? _orders
        : Map.fromEntries(
      _orders.entries.where((entry) {
        final products = entry.value;
        return products.values.any((product) => product['status'] == _selectedStatus);
      }),
    );
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('Lịch sử mua hàng'),
        backgroundColor: Colors.black,
        actions: [
          DropdownButton<String>(
            value: _selectedStatus,
            dropdownColor: Colors.black,
            items: ['Tất cả', 'chưa giao', 'đang giao', 'đã giao']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status, style: TextStyle(color: Colors.white)),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
          SizedBox(width: 12),
        ],

      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : filteredOrders.isEmpty
          ? Center(child: Text('Bạn chưa có đơn hàng nào.', style: TextStyle(color: Colors.white)))
          : ListView(
        padding: EdgeInsets.all(12),
        children: filteredOrders.entries.map((entry) {
          final orderId = entry.key;
          final products = Map<String, dynamic>.from(entry.value);

          if (products.isEmpty) return SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Đơn hàng: $orderId", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (products.values.first['orderTime'] != null)
                Text(
                  "Ngày đặt: ${formatDate(products.values.first['orderTime'])}",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              SizedBox(height: 6),
              ...products.entries.map((e) {
                final product = Map<String, dynamic>.from(e.value);
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(product['image'] ?? '', width: 55, height: 55, fit: BoxFit.cover),
                    ),
                    title: Text(product['name'] ?? '', style: TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text("Giá: ${product['price']}đ", style: TextStyle(color: Colors.grey)),
                        Text("Giảm giá: ${product['discount']}%", style: TextStyle(color: Colors.grey)),
                        Text("Giá sau giảm: ${(product['price'] * (1 - (product['discount'] ?? 0) / 100)).toStringAsFixed(2)}đ", style: TextStyle(color: Colors.grey)),
                        Text("Số lượng: ${product['quantity']}", style: TextStyle(color: Colors.grey)),
                        Text("Trạng thái: ${product['status']}", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }),

              Divider(color: Colors.white24),
            ],
          );
        }).toList(),
      ),
    );
  }
}