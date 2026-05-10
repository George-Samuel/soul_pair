import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../services/text_moderation.dart'; // импорт модерации

class RealChatScreen extends StatefulWidget {
  final String targetUserId;
  final String targetName;

  const RealChatScreen({
    super.key,
    required this.targetUserId,
    required this.targetName,
  });

  @override
  State<RealChatScreen> createState() => _RealChatScreenState();
}

class _RealChatScreenState extends State<RealChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  int _lastMessageId = 0;
  Timer? _pollTimer;
  Timer? _heartbeatTimer;
  bool _isLoading = true;

  String get _myUserId => ProfileService.currentProfile?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startPolling();
    _startHeartbeat();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _heartbeatTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      ApiService.sendHeartbeat(_myUserId);
    });
    ApiService.sendHeartbeat(_myUserId);
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchNewMessages();
    });
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    await _fetchNewMessages(reset: true);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchNewMessages({bool reset = false}) async {
    if (reset) _lastMessageId = 0;
    final List<Map<String, dynamic>> newMessages = await ApiService.getDialog(
      user1: _myUserId,
      user2: widget.targetUserId,
      lastId: _lastMessageId,
    );
    if (newMessages.isNotEmpty && mounted) {
      setState(() {
        for (final msg in newMessages) {
          final int msgId = msg['id'] as int;
          if (msgId > _lastMessageId) {
            _messages.add(msg);
            _lastMessageId = msgId;
          }
        }
      });
      await ApiService.markRead(_myUserId, widget.targetUserId, _lastMessageId);
    }
  }

  // Метод отправки сообщения с модерацией
  Future<void> _sendMessage() async {
    final String text = _textController.text.trim();
    if (text.isEmpty) return;

    // Проверка на недопустимые выражения
    if (TextModeration.containsProfanity(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сообщение содержит недопустимые слова. Оно не будет отправлено.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _textController.clear();

    final bool success = await ApiService.sendMessage(
      fromId: _myUserId,
      toId: widget.targetUserId,
      text: text,
    );
    if (success) {
      await _fetchNewMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось отправить сообщение'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.targetName),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text('Нет сообщений. Начните диалог!'))
                : ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> msg = _messages[_messages.length - 1 - index];
                final bool isMe = msg['from'] == _myUserId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.purple : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text'] as String,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Сообщение...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: Colors.purple),
          ),
        ],
      ),
    );
  }
}