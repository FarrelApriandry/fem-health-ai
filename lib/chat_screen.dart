import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String name;

  const ChatScreen({super.key, this.name = 'there'});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <Map<String, String>>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'ai',
      'text':
          'Hi ${widget.name}! 👋 I am FemHealth AI. How can I help you today?',
    });
  }

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
        body: jsonEncode({
          'message': text,
          'user_message': text,
          'prompt': text,
        }),
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final reply = jsonDecode(response.body)['reply'] as String;
        setState(() {
          _messages.add({'role': 'ai', 'text': reply});
        });
      } else {
        _showError('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showError('Failed to connect: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _cleanMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\s*\【[^】]*\】'), '')
        .replaceAll(RegExp(r'  +'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.favorite, color: colors.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FemHealth AI',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Your wellness companion',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final msg = _messages[i];
              final isUser = msg['role'] == 'user';

              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? colors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isUser
                      ? Text(
                          msg['text'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        )
                      : MarkdownBody(
                          data: _cleanMarkdown(msg['text'] ?? ''),
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
                icon: Icon(Icons.send, color: colors.primary),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
