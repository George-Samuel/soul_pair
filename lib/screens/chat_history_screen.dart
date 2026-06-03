import 'package:flutter/material.dart';
import '../services/chat_history_service.dart';
import '../models/chat/chat_session.dart';
import 'chat_screen.dart';
import '../services/profile_service.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await ChatHistoryService.getAllSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    await ChatHistoryService.deleteSession(sessionId);
    await _loadSessions();
  }

  Future<void> _clearAll() async {
    await ChatHistoryService.clearAll();
    await _loadSessions();
  }

  void _confirmDeleteSession(String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить чат?'),
        content: const Text('История этого чата будет удалена без возможности восстановления.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteSession(sessionId);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить всю историю?'),
        content: const Text('Все чаты будут удалены без возможности восстановления.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAll();
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = ProfileService.currentProfile;
    if (currentProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('История чатов')),
        body: const Center(child: Text('Пользователь не авторизован')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('История чатов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _confirmClearAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
          ? const Center(child: Text('Нет сохранённых чатов'))
          : ListView.builder(
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return ListTile(
            leading: session.characterImage != null
                ? ClipOval(
              child: Image.asset(
                session.characterImage!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person),
              ),
            )
                : const Icon(Icons.chat),
            title: Text(session.characterName),
            subtitle: Text(session.lastMessage),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteSession(session.id),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    characterName: session.characterName,
                    userProfile: currentProfile,
                    pathType: session.pathType,
                    isTrainer: session.isTrainer,
                    characterImage: session.characterImage,
                    characterProfession: session.characterProfession,
                    characterPersonality: session.characterPersonality,
                  ),
                ),
              );
              // Обновляем список после возврата из чата (например, изменилось последнее сообщение)
              await _loadSessions();
            },
          );
        },
      ),
    );
  }
}