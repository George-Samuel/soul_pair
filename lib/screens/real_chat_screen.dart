import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../services/text_moderation.dart';
import '../services/media_service.dart';
import '../services/share_service.dart';

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

  Future<void> _pickAndSendImage() async {
    final imagePath = await MediaService.showImageSourceDialog(context);
    if (imagePath == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final photoUrl = await ApiService.uploadPhoto(imagePath);
      if (mounted) Navigator.pop(context);
      if (photoUrl != null) {
        final success = await ApiService.sendMessage(
          fromId: _myUserId,
          toId: widget.targetUserId,
          imageUrl: photoUrl,
        );
        if (success) {
          await _fetchNewMessages();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Не удалось отправить фото'), backgroundColor: Colors.red),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка загрузки фото'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки фото'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEmojiPickerSheet() {
    final List<String> emojis = [
      '😀', '😁', '😂', '😃', '😄', '😅', '😆', '😉', '😊', '😋',
      '😎', '😍', '😘', '🥰', '😗', '😙', '😚', '🙂', '🤗', '🤔',
      '😐', '😑', '😶', '🙄', '😏', '😣', '😥', '😮', '🤐', '😌',
      '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮', '🤧',
      '🥵', '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '😎', '🤓', '🧐',
      '😕', '😟', '🙁', '☹️', '😮', '😯', '😲', '😳', '🥺', '😦',
      '😧', '😨', '😰', '😥', '😢', '😭', '😱', '😖', '😣', '😞',
      '😓', '😩', '😫', '🥱', '😤', '😡', '😠', '🤬', '😈', '👿',
      '💀', '☠️', '💩', '🤡', '👹', '👺', '👻', '💀', '👽', '🤖',
      '💪', '🦾', '🖕', '✌️', '🤞', '🤟', '🤘', '🤙', '👌', '👍',
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔',
    ];
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            childAspectRatio: 1,
          ),
          itemCount: emojis.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                _textController.text += emojis[index];
                Navigator.pop(context);
                FocusScope.of(context).requestFocus();
              },
              child: Center(child: Text(emojis[index], style: const TextStyle(fontSize: 28))),
            );
          },
        ),
      ),
    );
  }

  bool _isImageUrl(String text) {
    return text.startsWith('http') &&
        (text.endsWith('.jpg') || text.endsWith('.jpeg') ||
            text.endsWith('.png') || text.endsWith('.gif') ||
            text.endsWith('.webp'));
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendTextMessage(String text) async {
    if (text.isEmpty) return;

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
    final success = await ApiService.sendMessage(
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

  void _showMessageOptions(Map<String, dynamic> message, int originalIndex) {
    final isMe = message['from'] == _myUserId;
    final messageId = message['id'] as int;
    final messageText = (message['text'] ?? '').toString();
    final messageTime = message['timestamp'] ?? '';

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Поделиться'),
              onTap: () async {
                Navigator.pop(context);
                await ShareService.shareText(messageText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Скопировать текст'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: messageText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Текст скопирован'), duration: Duration(seconds: 1)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: const Text('Пожаловаться'),
              onTap: () {
                Navigator.pop(context);
                // Здесь можно добавить вызов ApiService.reportMessage
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Жалоба отправлена'), backgroundColor: Colors.orange),
                );
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Удалить'),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await ApiService.deleteMessage(
                    userId: _myUserId,
                    messageId: messageId,
                  );
                  if (success && mounted) {
                    setState(() {
                      _messages.removeAt(originalIndex);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Не удалось удалить'), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
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
                final originalIndex = _messages.length - 1 - index;
                final msg = _messages[originalIndex];
                final bool isMe = msg['from'] == _myUserId;
                final String text = (msg['text'] ?? '') as String;
                final String? imageUrl = msg['image_url'] as String?;
                final String timestamp = (msg['timestamp'] ?? '') as String;
                return GestureDetector(
                  onLongPress: () => _showMessageOptions(msg, originalIndex),
                  child: _buildMessageBubble(
                    text,
                    isMe,
                    timestamp,
                    imageUrl,
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

  Widget _buildMessageBubble(String text, bool isMe, String timestamp, String? imageUrl) {
    final bubbleColor = isMe ? Colors.purple : Colors.grey.shade300;
    final textColor = isMe ? Colors.white : Colors.black87;
    final bool isPhoto = imageUrl != null || _isImageUrl(text);
    final String? displayUrl = imageUrl ?? (_isImageUrl(text) ? text : null);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayUrl != null)
              GestureDetector(
                onTap: () => _showFullScreenImage(displayUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    displayUrl,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                ),
              ),
            if (displayUrl == null && text.isNotEmpty)
              Text(
                text,
                style: TextStyle(color: textColor),
              ),
            if (timestamp.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTime(timestamp),
                  style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final time = DateTime.parse(isoString).toLocal();
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
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
          IconButton(
            icon: const Icon(Icons.photo_camera, color: Colors.purple),
            onPressed: _pickAndSendImage,
          ),
          IconButton(
            icon: const Icon(Icons.emoji_emotions, color: Colors.purple),
            onPressed: _showEmojiPickerSheet,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Сообщение...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (_) => _sendTextMessage(_textController.text),
            ),
          ),
          IconButton(
            onPressed: () => _sendTextMessage(_textController.text),
            icon: const Icon(Icons.send, color: Colors.purple),
          ),
        ],
      ),
    );
  }
}