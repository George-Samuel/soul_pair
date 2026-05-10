import 'dart:convert';
import 'dart:io';
import 'storage_path.dart';

class FavoriteAvatarsService {
  static Future<File> _getFile(String gender) async {
    final dir = await StoragePath.getFilesDir();
    final fileName = 'favorite_avatars_${gender.toLowerCase()}.json';
    return File('$dir/$fileName');
  }

  static Future<List<String>> loadFavorites(String gender) async {
    final file = await _getFile(gender);
    if (!await file.exists()) return [];
    try {
      final json = await file.readAsString();
      final List<dynamic> list = jsonDecode(json) as List<dynamic>;
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveFavorites(List<String> paths, String gender) async {
    final file = await _getFile(gender);
    await file.writeAsString(jsonEncode(paths));
  }

  static Future<void> addFavorite(String path, String gender) async {
    final list = await loadFavorites(gender);
    if (!list.contains(path)) {
      list.add(path);
      await saveFavorites(list, gender);
    }
  }

  static Future<void> removeFavorite(String path, String gender) async {
    final list = await loadFavorites(gender);
    list.removeWhere((p) => p == path);
    await saveFavorites(list, gender);
  }

  static Future<bool> isFavorite(String path, String gender) async {
    final list = await loadFavorites(gender);
    return list.contains(path);
  }
}