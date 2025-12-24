import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
//use n8n webhook
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  /// message structure:
  /// {
  ///   sender: 'user' | 'bot',
  ///   type: 'text' | 'product',
  ///   text: String,
  ///   images: List<String>
  /// }
  final List<Map<String, dynamic>> messages = [];

  final String webhookUrl =
      'https://n8n.tuantran.io.vn/webhook/55b5ca1e-e679-46bb-93e2-ac35ed11680b';

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // add user message
    setState(() {
      messages.add({
        'sender': 'user',
        'type': 'text',
        'text': message,
        'images': [],
      });
    });

    try {
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender': 'user',
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data.containsKey('type')) {
          setState(() {
            messages.add({
              'sender': 'bot',
              'type': data['type'] ?? 'text',
              'text': data['text'] ?? '',
              'images': data['images'] is List
                  ? List<String>.from(data['images'])
                  : [],
            });
          });
        } else {
          _addBotError('Dữ liệu phản hồi không hợp lệ');
        }
      } else {
        _addBotError('Bot không phản hồi (HTTP ${response.statusCode})');
      }
    } catch (e) {
      _addBotError('Lỗi kết nối tới server');
    }
  }

  void _addBotError(String text) {
    setState(() {
      messages.add({
        'sender': 'bot',
        'type': 'text',
        'text': text,
        'images': [],
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat với AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildMessageContent(msg),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      sendMessage(value);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
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

  Widget _buildMessageContent(Map<String, dynamic> msg) {
    final String text = msg['text'] ?? '';
    final List<String> images =
    msg['images'] != null ? List<String>.from(msg['images']) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text.isNotEmpty)
          Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        if (images.isNotEmpty) const SizedBox(height: 8),
        if (images.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      images[index],
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
