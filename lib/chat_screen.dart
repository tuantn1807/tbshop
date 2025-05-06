import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": message});
    });
    //ip của server
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5005/webhooks/rest/webhook") ,// sửa localhost
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"sender": "user", "message": message}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> botResponses = jsonDecode(response.body);
        for (var res in botResponses) {
          if (res.containsKey("text")) {
            setState(() {
              messages.add({"sender": "bot", "text": res["text"]});
            });
          }
        }
      } else {
        setState(() {
          messages.add({"sender": "bot", "text": "Bot không phản hồi."});
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        messages.add({"sender": "bot", "text": "Lỗi kết nối tới server."});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat với AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  title: Align(
                    alignment: msg["sender"] == "user"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: msg["sender"] == "user"
                            ? Colors.blue[200]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(msg["text"] ?? ""),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Nhập tin nhắn..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
