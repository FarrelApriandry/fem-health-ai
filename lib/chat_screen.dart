import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <Map<String, String>>[];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://mpqteprqsvnjbhfnecoz.supabase.co/functions/v1/femhealth-ai',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_message': text}),
      );

      if (response.statusCode == 200) {
        final reply = jsonDecode(response.body)['reply'] as String;
        setState(() => _messages.add({'role': 'ai', 'text': reply}));
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to connect: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FemHealth AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurple[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isUser
                        ? Text(msg['text'] ?? '')
                        : MarkdownBody(
                            data: (msg['text'] ?? '')
                                .replaceAll(RegExp(r'\s*\【[^】]*\】'), '')
                                .replaceAll(RegExp(r'  +'), ' ')
                                .trim(),
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Colors.black87),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
