import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:tbshop/View/User/vnpay_config.dart';
import 'package:url_launcher/url_launcher.dart';



class VNPayService {
  static Future<void> openVNPay(double amount, String orderId) async {
    final DateFormat formatter = DateFormat('yyyyMMddHHmmss');
    final String createDate = formatter.format(DateTime.now());

    // 1) Các tham số (giữ giá trị raw, chưa encode)
    final Map<String, String> params = {
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': VNPayConfig.tmnCode,
      'vnp_Amount': (amount * 100).toInt().toString(), // nhân 100 theo quy ước VNPAY
      'vnp_CurrCode': 'VND',
      'vnp_TxnRef': orderId,
      'vnp_OrderInfo': 'Thanh toan don hang $orderId',
      'vnp_Locale': 'vn',
      'vnp_ReturnUrl': VNPayConfig.returnUrl,
      'vnp_CreateDate': createDate,
      // Thêm một số tham số khuyến nghị
      'vnp_OrderType': 'other',
      'vnp_IpAddr': '127.0.0.1',
    };

// 2) Tạo chuỗi raw để hash (PHẢI encode các giá trị trước khi hash)
    final sortedKeys = params.keys.toList()..sort();
    final String hashData = sortedKeys
        .map((k) => '$k=${Uri.encodeQueryComponent(params[k] ?? '')}')
        .join('&');

    // 3) Sinh secure hash bằng HMAC SHA512 (key = hashSecret)
    final hmac = Hmac(sha512, utf8.encode(VNPayConfig.hashSecret));
    final digest = hmac.convert(utf8.encode(hashData));
    final String secureHash = digest.toString();

    // 4) Tạo queryString dùng cho URL (encode các value)
    final String query = sortedKeys
        .map((k) => '$k=${Uri.encodeComponent(params[k] ?? '')}')
        .join('&');

    final paymentUrl = '${VNPayConfig.vnpUrl}?$query&vnp_SecureHash=$secureHash';

    // DEBUG: in ra URL để kiểm tra
    print('VNPAY paymentUrl: $paymentUrl');
    print('hashData (raw): $hashData');
    print('vnp_SecureHash: $secureHash');

    // 5) Mở trình duyệt
    final Uri uri = Uri.parse(paymentUrl);

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // bắt buộc mở bằng trình duyệt hệ thống
        webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
      );
    } catch (e) {
      print("Không thể mở URL: $e");
    }

  }
}
