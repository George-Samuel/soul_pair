import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import 'profile_screen.dart';
import '../utils/theme_colors.dart';
import '../services/ai_service.dart';
import '../services/chat_history_service.dart';
import '../services/share_service.dart';
import '../services/report_service.dart';
import '../services/text_moderation.dart';
import '../services/media_service.dart';
import '../services/api_service.dart';
import '../models/chat/message.dart';

class ChatScreen extends StatefulWidget {
  final String characterName;
  final UserProfile userProfile;
  final String pathType;
  final bool isTrainer;
  final String? characterImage;
  final String? characterProfession;
  final String? characterPersonality;
  final String? characterGender;

  const ChatScreen({
    super.key,
    required this.characterName,
    required this.userProfile,
    required this.pathType,
    this.isTrainer = false,
    this.characterImage,
    this.characterProfession,
    this.characterPersonality,
    this.characterGender,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isWaitingForAI = false;
  late String sessionId;

  UserProfile? get _currentUser => ProfileService.currentProfile;

  @override
  void initState() {
    super.initState();
    sessionId = '${widget.characterName}_${widget.pathType}_${widget.userProfile.id}';
    sessionId = sessionId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    _loadHistory();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_messages.isEmpty) {
        _addAIMessage(_getWelcomeMessage());
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await ChatHistoryService.loadMessages(sessionId);
    for (var msg in history) {
      setState(() {
        _messages.add({
          'text': msg.text,
          'isUser': msg.isUser,
          'time': msg.time,
          'image_url': msg.imageUrl,
          'id': msg.id,
        });
      });
    }
  }

  Future<void> _saveMessageToHistory(String text, bool isUser, DateTime time, {String? imageUrl, int? id}) async {
    final message = Message(
      text: text,
      isUser: isUser,
      time: time,
      imageUrl: imageUrl,
      id: id,
    );
    await ChatHistoryService.saveMessage(
      sessionId: sessionId,
      message: message,
      characterName: widget.characterName,
      pathType: widget.pathType,
      isTrainer: widget.isTrainer,
      characterImage: widget.characterImage,
      characterProfession: widget.characterProfession,
      characterPersonality: widget.characterPersonality,
    );
  }

  void _addAIMessage(String text) {
    final time = DateTime.now();
    final fakeId = -DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _messages.add({
        'text': text,
        'isUser': false,
        'time': time,
        'id': fakeId,
      });
    });
    _saveMessageToHistory(text, false, time, id: fakeId);
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
        final userTime = DateTime.now();
        final fakeId = -DateTime.now().millisecondsSinceEpoch;
        setState(() {
          _messages.add({
            'text': '',
            'isUser': true,
            'time': userTime,
            'image_url': photoUrl,
            'id': fakeId,
          });
        });
        await _saveMessageToHistory('', true, userTime, imageUrl: photoUrl, id: fakeId);

        setState(() {
          _isWaitingForAI = true;
        });

        final parts = [
          {'type': 'image_url', 'image_url': {'url': photoUrl}},
          {'type': 'text', 'text': 'Опиши, что ты видишь на этом фото. Дай дружелюбный, поддерживающий комментарий.'},
        ];
        final aiResponse = await AIService.sendMessageWithParts(parts);
        if (mounted) {
          _addAIMessage(aiResponse);
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
    } finally {
      if (mounted) {
        setState(() {
          _isWaitingForAI = false;
        });
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

  void _showMessageOptions(Map<String, dynamic> message, int index) {
    final messageText = (message['text'] ?? '').toString();
    final messageTime = message['time'] as DateTime;
    final isUser = message['isUser'] as bool? ?? false;
    final messageId = message['id'] as int?;
    final senderId = isUser ? (_currentUser?.id ?? 'user') : widget.characterName;

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
                _showReportDialog(messageText, senderId, messageTime);
              },
            ),
            // === УДАЛЕНИЕ: для своих сообщений (без проверки id) ===
            if (isUser)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Удалить'),
                onTap: () async {
                  Navigator.pop(context);
                  // Удаляем из UI
                  setState(() {
                    _messages.removeAt(index);
                  });
                  // Удаляем из локальной истории (если метод есть)
                  try {
                    await ChatHistoryService.deleteMessage(sessionId, messageId);
                  } catch (e) {
                    print('Ошибка удаления из истории: $e');
                  }
                  // Если сообщение реальное (положительный ID) – удаляем и через API
                  if (messageId != null && messageId > 0) {
                    await ApiService.deleteMessage(
                      userId: _currentUser?.id ?? '',
                      messageId: messageId,
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Сообщение удалено'), duration: Duration(seconds: 1)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(String messageText, String senderId, DateTime messageTime) {
    String? selectedReason;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Пожаловаться на сообщение'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Выберите причину:'),
              RadioListTile<String>(
                title: const Text('Оскорбление / мат'),
                value: 'insult',
                groupValue: selectedReason,
                onChanged: (v) => setState(() => selectedReason = v),
              ),
              RadioListTile<String>(
                title: const Text('Спам / реклама'),
                value: 'spam',
                groupValue: selectedReason,
                onChanged: (v) => setState(() => selectedReason = v),
              ),
              RadioListTile<String>(
                title: const Text('Непристойное предложение'),
                value: 'lewd',
                groupValue: selectedReason,
                onChanged: (v) => setState(() => selectedReason = v),
              ),
              RadioListTile<String>(
                title: const Text('Угрозы / насилие'),
                value: 'violence',
                groupValue: selectedReason,
                onChanged: (v) => setState(() => selectedReason = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedReason == null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Выберите причину')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              final messageId = 'msg_${messageTime.millisecondsSinceEpoch}_${senderId.hashCode}';
              ReportService.sendReport(
                targetUserId: senderId,
                messageId: messageId,
                reason: selectedReason!,
                additionalInfo: messageText.length > 100 ? messageText.substring(0, 100) : messageText,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Жалоба отправлена'), backgroundColor: Colors.orange),
              );
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTextMessage(String text) async {
    if (text.isEmpty || _isWaitingForAI) return;

    if (TextModeration.containsProfanity(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сообщение содержит недопустимые слова. Оно не будет отправлено.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userTime = DateTime.now();
    final fakeId = -DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'time': userTime,
        'id': fakeId,
      });
      _isWaitingForAI = true;
    });
    _textController.clear();
    await _saveMessageToHistory(text, true, userTime, id: fakeId);

    final history = _messages.map((msg) {
      return {
        'role': (msg['isUser'] as bool?) == true ? 'user' : 'assistant',
        'content': msg['text'] as String,
      };
    }).toList();

    try {
      final aiResponse = await AIService.sendMessage(history);
      if (mounted) {
        _addAIMessage(aiResponse);
      }
    } catch (e) {
      print('Ошибка AI: $e');
      if (mounted) {
        _addAIMessage('Извините, произошла ошибка. Попробуйте позже.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isWaitingForAI = false;
        });
      }
    }
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

  // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========
  String _safeSubstring(String? text, int maxLength) {
    if (text == null || text.isEmpty) return 'не указано';
    final length = text.length;
    if (length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  bool get _isMale {
    if (widget.characterGender != null) return widget.characterGender == 'male';
    final maleNames = [
      'марк', 'дмитрий', 'люк', 'карлос', 'кай',
      'артём', 'михаил', 'николай', 'виктор', 'евгений',
      'алексей', 'максим'
    ];
    return maleNames.contains(widget.characterName.toLowerCase());
  }

  Color _getCharacterColor() {
    final name = widget.characterName.toLowerCase();
    if (name.contains('лиза') || name.contains('liza')) return Colors.purple;
    if (name.contains('аня') || name.contains('anna')) return Colors.green;
    if (name.contains('кира') || name.contains('kira')) return Colors.blue;
    if (name.contains('софия') || name.contains('sofia') || name.contains('софи')) return Colors.orange;
    if (name.contains('фрейя') || name.contains('freya')) return Colors.red;
    if (name.contains('хана') || name.contains('hana')) return Colors.pink;
    if (name.contains('изабелла') || name.contains('isabella')) return Colors.teal;
    if (name.contains('натали') || name.contains('natalie')) return Colors.amber;
    if (name.contains('прия') || name.contains('priya')) return Colors.deepOrange;
    if (name.contains('сакура') || name.contains('sakura')) return Colors.lightGreen;
    if (name.contains('марк')) return Colors.indigo;
    if (name.contains('дмитрий')) return Colors.redAccent;
    if (name.contains('люк')) return Colors.blueGrey;
    if (name.contains('карлос')) return Colors.deepPurple;
    if (name.contains('кай')) return Colors.cyan;
    if (name.contains('артём')) return Colors.amber;
    if (name.contains('михаил')) return Colors.indigo.shade300;
    if (name.contains('николай')) return Colors.lightBlue;
    if (name.contains('виктор')) return Colors.lime;
    if (name.contains('евгений')) return Colors.cyan.shade700;
    return Colors.purple;
  }

  String _getWelcomeMessage() {
    switch (widget.pathType) {
      case 'ai_guide':
        return 'Привет! Я твой виртуальный проводник. Готов(а) помочь тебе в мире знакомств и общения. Задавай любые вопросы, давай обсуждать интересные темы!';
      case 'ai_matching':
        return 'Привет! Я помогу тебе найти идеального партнёра. Расскажи, что для тебя важно в отношениях, и вместе мы подберём лучшие варианты.';
      case 'hybrid':
        if (widget.isTrainer) {
          return 'Привет! Я твой AI-тренер по общению. Давай потренируемся начинать разговор, поддерживать беседу и производить хорошее впечатление.';
        } else {
          return 'Привет! Я здесь, чтобы общаться с тобой. Можешь рассказать о своих интересах, мечтах, или просто поболтать. Начнём?';
        }
      default:
        return 'Привет! Я твой AI-собеседник. Чем могу быть полезен?';
    }
  }

  String _getColorName(Color color) {
    if (color == Colors.purple) return 'фиолетовый';
    if (color == Colors.green) return 'зелёный';
    if (color == Colors.blue) return 'синий';
    if (color == Colors.orange) return 'оранжевый';
    if (color == Colors.red) return 'красный';
    if (color == Colors.pink) return 'розовый';
    if (color == Colors.teal) return 'бирюзовый';
    if (color == Colors.amber) return 'янтарный';
    if (color == Colors.deepOrange) return 'тёмно-оранжевый';
    if (color == Colors.lightGreen) return 'светло-зелёный';
    if (color == Colors.indigo) return 'индиго';
    if (color == Colors.redAccent) return 'красный';
    if (color == Colors.blueGrey) return 'сине-серый';
    if (color == Colors.deepPurple) return 'тёмно-фиолетовый';
    if (color == Colors.cyan) return 'циан';
    if (color == Colors.lime) return 'лаймовый';
    return 'фиолетовый';
  }

  String _getPersonalityByColor(Color color) {
    if (color == Colors.purple) return 'творческой и загадочной';
    if (color == Colors.green) return 'спокойной и натуральной';
    if (color == Colors.blue) return 'умной и технологичной';
    if (color == Colors.orange) return 'страстной и энергичной';
    if (color == Colors.red) return 'решительной и смелой';
    if (color == Colors.pink) return 'нежной и креативной';
    if (color == Colors.teal) return 'практичной и утончённой';
    if (color == Colors.amber) return 'мудрой и загадочной';
    if (color == Colors.deepOrange) return 'духовной и гармоничной';
    if (color == Colors.lightGreen) return 'терпеливой и нежной';
    if (color == Colors.indigo) return 'интеллектуальной и вдумчивой';
    if (color == Colors.redAccent) return 'страстной и перфекционистской';
    if (color == Colors.blueGrey) return 'смелой и свободолюбивой';
    if (color == Colors.deepPurple) return 'чувственной и традиционной';
    if (color == Colors.cyan) return 'креативной и техничной';
    if (color == Colors.lime) return 'энергичной и жизнерадостной';
    return 'уникальной';
  }

  @override
  Widget build(BuildContext context) {
    final characterColor = _getCharacterColor();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.characterImage != null && !widget.isTrainer)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white70, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: characterColor.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    widget.characterImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 20, color: characterColor);
                    },
                  ),
                ),
              ),
            Text(
              widget.characterName,
              style: TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: characterColor.withOpacity(0.7),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: characterColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(widget.characterName, style: TextStyle(color: characterColor)),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.characterImage != null)
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(color: characterColor, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: characterColor.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.asset(
                                  widget.characterImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.person, size: 60, color: characterColor);
                                  },
                                ),
                              ),
                            ),
                          ),
                        if (widget.characterProfession != null)
                          Text(
                            _isMale ? '👨‍🎓 ${widget.characterProfession!}' : '👩‍🎓 ${widget.characterProfession!}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        if (widget.characterPersonality != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text('💭 ${widget.characterPersonality!}', style: const TextStyle(fontSize: 14)),
                          ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: characterColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📊 Информация о чате:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('🎯 Путь: ${widget.pathType}'),
                              Text('🔧 Режим: ${widget.isTrainer ? "Тренировка" : "Обычный"}'),
                              Text('🎨 Цвет: ${_getColorName(characterColor)}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Закрыть', style: TextStyle(color: characterColor)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.isTrainer)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: const Row(
                children: [
                  Icon(Icons.school, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Тренировочный режим: AI поможет улучшить навыки общения',
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return GestureDetector(
                  onLongPress: () => _showMessageOptions(message, index),
                  child: _buildMessageBubble(message, index, characterColor),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: ThemeColors.divider(context))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo_camera, color: characterColor),
                  onPressed: _pickAndSendImage,
                ),
                IconButton(
                  icon: Icon(Icons.emoji_emotions, color: characterColor),
                  onPressed: _showEmojiPickerSheet,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: characterColor.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: ThemeColors.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: 'Напишите сообщение...',
                        hintStyle: TextStyle(color: ThemeColors.textHint(context)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      onSubmitted: (_) => _sendTextMessage(_textController.text),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: characterColor.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () => _sendTextMessage(_textController.text),
                    backgroundColor: _isWaitingForAI ? Colors.grey : characterColor,
                    foregroundColor: Colors.white,
                    child: _isWaitingForAI
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index, Color characterColor) {
    final isUser = (message['isUser'] as bool?) ?? false;
    final text = message['text'] as String;
    final imageUrl = message['image_url'] as String?;
    final time = message['time'] as DateTime;

    Color bubbleColor;
    Color textColor;
    Color timeColor;

    if (isUser) {
      bubbleColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : characterColor.withOpacity(0.15);
      textColor = Theme.of(context).brightness == Brightness.dark ? Colors.black : characterColor;
      timeColor = textColor.withOpacity(0.7);
    } else {
      bubbleColor = Colors.grey[50]!;
      textColor = Colors.grey[900]!;
      timeColor = Colors.grey[600]!.withOpacity(0.7);
    }

    final bool isPhoto = imageUrl != null || _isImageUrl(text);
    final String? displayUrl = imageUrl ?? (_isImageUrl(text) ? text : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: characterColor.withOpacity(0.7), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: characterColor.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: widget.characterImage != null && !widget.isTrainer
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  widget.characterImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.psychology, size: 20, color: characterColor);
                  },
                ),
              )
                  : Icon(Icons.psychology, size: 20, color: characterColor),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isUser ? characterColor.withOpacity(0.3) : Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? characterColor : Colors.grey).withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    Text(text, style: TextStyle(fontSize: 16, color: textColor)),
                  const SizedBox(height: 6),
                  Text(
                    '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 11, color: timeColor),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.withOpacity(0.7), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: _currentUser?.selectedAvatar != null
                    ? (_currentUser!.selectedAvatar!.startsWith('assets/')
                    ? Image.asset(_currentUser!.selectedAvatar!, fit: BoxFit.cover)
                    : Image.file(File(_currentUser!.selectedAvatar!), fit: BoxFit.cover))
                    : const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}