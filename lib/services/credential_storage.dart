import 'dart:convert';
import 'dart:io';
import 'storage_path.dart';

class CredentialStorage {
  static const _fileName = 'credentials.json';

  static Future<File> _getFile() async {
    final dir = await StoragePath.getFilesDir(); // возвращает String (путь)
    final filePath = '$dir/$_fileName';
    return File(filePath);
  }

  static Future<void> saveCredentials(String email, String password) async {
    try {
      final file = await _getFile();
      final data = {'email': email, 'password': password};
      await file.writeAsString(jsonEncode(data));
      print('🔐 [CredentialStorage] Сохранены учётные данные для $email');
    } catch (e) {
      print('❌ Ошибка сохранения учётных данных: $e');
    }
  }

  static Future<Map<String, String>?> loadCredentials() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final Map<String, dynamic> map = jsonDecode(content) as Map<String, dynamic>;
      return {
        'email': map['email'] as String? ?? '',
        'password': map['password'] as String? ?? '',
      };
    } catch (e) {
      print('❌ Ошибка загрузки учётных данных: $e');
      return null;
    }
  }

  static Future<void> clearCredentials() async {
    final file = await _getFile();
    if (await file.exists()) await file.delete();
  }
}