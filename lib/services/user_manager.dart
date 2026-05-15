import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'storage_path.dart';

class UserManager {
  static Future<String> get _usersFilePath async {
    final baseDir = await StoragePath.getFilesDir();
    return '$baseDir/users.json';
  }

  static Future<String> get _activeUserIdFilePath async {
    final baseDir = await StoragePath.getFilesDir();
    return '$baseDir/active_user.txt';
  }

  static Map<String, String> _usersPasswords = {};
  static String? _currentUserId;

  static Future<void> loadUsers() async {
    final usersFile = File(await _usersFilePath);
    if (await usersFile.exists()) {
      try {
        final json = await usersFile.readAsString();
        final decoded = jsonDecode(json);
        if (decoded is Map<String, dynamic>) {
          _usersPasswords = {};
          decoded.forEach((key, value) {
            if (value is String) {
              _usersPasswords[key] = value;
            }
          });
        } else {
          _usersPasswords = {};
        }
      } catch (e) {
        _usersPasswords = {};
      }
    } else {
      _usersPasswords = {};
    }

    final activeFile = File(await _activeUserIdFilePath);
    if (await activeFile.exists()) {
      _currentUserId = await activeFile.readAsString();
      if (!_usersPasswords.containsKey(_currentUserId)) {
        _currentUserId = null;
      }
    } else {
      _currentUserId = null;
    }
  }

  static Future<void> _saveUsers() async {
    final usersFile = File(await _usersFilePath);
    final json = jsonEncode(_usersPasswords);
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

  static List<String> getUsers() => _usersPasswords.keys.toList();
  static String? get currentUserId => _currentUserId;

  static Future<bool> createUser(String userId, String password) async {
    if (_usersPasswords.containsKey(userId)) return false;
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    _usersPasswords[userId] = hashedPassword;
    await _saveUsers();

    final baseDir = await StoragePath.getFilesDir();
    final userDir = Directory('$baseDir/user_$userId');
    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }
    return true;
  }

  static Future<bool> switchToUser(String userId, String password) async {
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    if (_usersPasswords.containsKey(userId) && _usersPasswords[userId] == hashedPassword) {
      _currentUserId = userId;
      await _saveActiveUser();
      return true;
    }
    return false;
  }

  static Future<void> deleteUser(String userId) async {
    if (_usersPasswords.containsKey(userId)) {
      _usersPasswords.remove(userId);
      await _saveUsers();

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

  static Future<void> logout() async {
    _currentUserId = null;
    await _saveActiveUser();
  }
}