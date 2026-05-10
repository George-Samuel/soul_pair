import 'dart:convert';
import 'dart:io';
import '../models/chat/chat_session.dart';
import '../models/chat/message.dart';
import 'user_manager.dart';
import 'storage_path.dart'; // твой канал

class ChatHistoryService {
  // --- Базовый путь к папке пользователя (асинхронный) ---
  static Future<String> get _baseDir async {
    final baseDir = await StoragePath.getFilesDir();
    final userId = UserManager.currentUserId ?? 'default';
    final path = '$baseDir/user_$userId';
    final dir = Directory(path);
    await dir.create(recursive: true);
    return path;
  }

  static Future<File> _getSessionsFile() async {
    final dir = await _baseDir;
    return File('$dir/chat_sessions.json');
  }

  static Future<File> _getMessagesFile(String sessionId) async {
    final dir = await _baseDir;
    final safeId = sessionId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return File('$dir/messages_$safeId.json');
  }

  // --- Загрузка всех сессий ---
  static Future<List<ChatSession>> getAllSessions() async {
    final file = await _getSessionsFile();
    if (!await file.exists()) return [];
    try {
      final json = await file.readAsString();
      final List<dynamic> list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _saveSessions(List<ChatSession> sessions) async {
    final file = await _getSessionsFile();
    final json = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await file.writeAsString(json);
  }

  // --- Сообщения ---
  static Future<List<Message>> loadMessages(String sessionId) async {
    final file = await _getMessagesFile(sessionId);
    if (!await file.exists()) return [];
    try {
      final json = await file.readAsString();
      final List<dynamic> list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveMessage({
    required String sessionId,
    required Message message,
    required String characterName,
    required String pathType,
    bool isTrainer = false,
    String? characterImage,
    String? characterProfession,
    String? characterPersonality,
  }) async {
    // 1. Загружаем старые сообщения, добавляем новое
    final messages = await loadMessages(sessionId);
    messages.add(message);
    final msgFile = await _getMessagesFile(sessionId);
    await msgFile.writeAsString(jsonEncode(messages.map((m) => m.toJson()).toList()));

    // 2. Обновляем или создаём сессию
    final sessions = await getAllSessions();
    final index = sessions.indexWhere((s) => s.id == sessionId);
    final updatedSession = ChatSession(
      id: sessionId,
      characterName: characterName,
      characterImage: characterImage,
      lastMessage: message.text,
      lastUpdated: message.time,
      pathType: pathType,
      isTrainer: isTrainer,
      characterProfession: characterProfession,
      characterPersonality: characterPersonality,
    );
    if (index != -1) {
      sessions[index] = updatedSession;
    } else {
      sessions.add(updatedSession);
    }
    await _saveSessions(sessions);
  }

  static Future<void> deleteSession(String sessionId) async {
    final sessions = await getAllSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await _saveSessions(sessions);
    final msgFile = await _getMessagesFile(sessionId);
    if (await msgFile.exists()) await msgFile.delete();
  }

  static Future<void> clearAll() async {
    final sessions = await getAllSessions();
    for (final session in sessions) {
      final msgFile = await _getMessagesFile(session.id);
      if (await msgFile.exists()) await msgFile.delete();
    }
    final sessionsFile = await _getSessionsFile();
    if (await sessionsFile.exists()) await sessionsFile.delete();
  }
}