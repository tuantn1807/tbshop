import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/click_event_model.dart';

class TrackingService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<String> _getAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    String? anonId = prefs.getString('id');
    if (anonId == null) {
      anonId = const Uuid().v4();
      await prefs.setString('id', anonId);
    }
    return anonId;
  }

  Future<void> logClick(String? userId, String productId) async {
    // Dùng anonymousId nếu userId bị null hoặc rỗng
    final String finalUserId = (userId != null && userId.isNotEmpty)
        ? userId
        : await _getAnonymousId();

    final timestamp = DateTime.now().toIso8601String();

    await _db.child('click_events').child(finalUserId).push().set({
      'productId': productId,
      'timestamp': timestamp,
    });
  }
  Future<List<ClickEvent>> fetchClickEventsForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("id");

    final snapshot = await FirebaseDatabase.instance
        .ref('click_events/$userId')
        .get();

    List<ClickEvent> clickEvents = [];

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
     clickEvents.add(ClickEvent.fromMap(Map<String, dynamic>.from(value), userId!));
      });
    }

    return clickEvents;
  }

}
