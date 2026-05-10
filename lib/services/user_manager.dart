import 'dart:io';
import 'dart:convert';
import 'storage_path.dart';  // ваш канал к filesDir

class UserManager {
  // Пути получаем асинхронно через StoragePath
  static Future<String> get _usersFilePath async {
    final baseDir = await StoragePath.getFilesDir();
    return '$baseDir/users.json';
  }

  static Future<String> get _activeUserIdFilePath async {
    final baseDir = await StoragePath.getFilesDir();
    return '$baseDir/active_user.txt';
  }

  static List<String> _users = [];
  static String? _currentUserId;

  static Future<void> loadUsers() async {
    final usersFile = File(await _usersFilePath);
    if (await usersFile.exists()) {
      try {
        final json = await usersFile.readAsString();
        final List<dynamic> list = jsonDecode(json) as List<dynamic>;
        _users = list.cast<String>();
      } catch (e) {
        _users = [];
      }
    } else {
      _users = [];
    }

    final activeFile = File(await _activeUserIdFilePath);
    if (await activeFile.exists()) {
      _currentUserId = await activeFile.readAsString();
    } else {
      _currentUserId = null;
    }
  }

  static Future<void> _saveUsers() async {
    final usersFile = File(await _usersFilePath);
    final json = jsonEncode(_users);
    await usersFile.writeAsString(json);
  }

  static Future<void> _saveActiveUser() async {
    final activeFile = File(await _activeUserIdFilePath);
    if (_currentUserId != null) {
      await activeFile.writeAsString(_currentUserId!);
    } else {
      if (await activeFile.exists()) await activeFile.delete();
    }
  }

  static List<String> getUsers() => List.unmodifiable(_users);
  static String? get currentUserId => _currentUserId;

  static Future<void> createUser(String userId) async {
    if (!_users.contains(userId)) {
      _users.add(userId);
      await _saveUsers();

      // Создаём папку пользователя в постоянном хранилище (для единообразия)
      final baseDir = await StoragePath.getFilesDir();
      final userDir = Directory('$baseDir/user_$userId');
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }
    }
  }

  static Future<void> switchToUser(String? userId) async {
    if (userId == null) {
      _currentUserId = null;
      await _saveActiveUser();
      return;
    }
    if (_users.contains(userId)) {
      _currentUserId = userId;
      await _saveActiveUser();
    }
  }

  static Future<void> deleteUser(String userId) async {
    if (_users.contains(userId)) {
      _users.remove(userId);
      await _saveUsers();

      // Удаляем папку пользователя из постоянного хранилища
      final baseDir = await StoragePath.getFilesDir();
      final userDir = Directory('$baseDir/user_$userId');
      if (await userDir.exists()) {
        await userDir.delete(recursive: true);
      }

      if (_currentUserId == userId) {
        _currentUserId = null;
        await _saveActiveUser();
      }
    }
  }
}