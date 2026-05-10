import 'dart:convert';
import 'dart:io';
import 'storage_path.dart';

class FavoriteUsersService {
  static const String _fileName = 'favorites.json';

  static Future<File> _getFile() async {
    final dir = await StoragePath.getFilesDir();
    return File('$dir/$_fileName');
  }

  static Future<List<String>> loadFavorites() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final json = await file.readAsString();
      final dynamic decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      print('Ошибка загрузки избранного: $e');
      return [];
    }
  }

  static Future<void> saveFavorites(List<String> favorites) async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(favorites));
    } catch (e) {
      print('Ошибка сохранения избранного: $e');
    }
  }

  static Future<bool> isFavorite(String userId) async {
    final list = await loadFavorites();
    return list.contains(userId);
  }

  static Future<void> addFavorite(String userId) async {
    final list = await loadFavorites();
    if (!list.contains(userId)) {
      list.add(userId);
      await saveFavorites(list);
    }
  }

  static Future<void> removeFavorite(String userId) async {
    final list = await loadFavorites();
    if (list.contains(userId)) {
      list.remove(userId);
      await saveFavorites(list);
    }
  }

  static Future<void> toggleFavorite(String userId) async {
    if (await isFavorite(userId)) {
      await removeFavorite(userId);
    } else {
      await addFavorite(userId);
    }
  }
}