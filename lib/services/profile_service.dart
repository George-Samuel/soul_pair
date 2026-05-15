import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'user_manager.dart';
import 'storage_path.dart';
import 'api_service.dart';

class ProfileService {
  static UserProfile? _currentProfile;
  static final List<VoidCallback> _listeners = [];

  static UserProfile? get currentProfile => _currentProfile;
  static bool get isRegistered => _currentProfile != null && _currentProfile!.name.isNotEmpty;
  static double get completionPercentage => _currentProfile?.profileCompletion ?? 0.0;

  static Future<String> get _userDirPath async {
    final baseDir = await StoragePath.getFilesDir();
    final userId = UserManager.currentUserId ?? 'default';
    final path = '$baseDir/user_$userId';
    return path;
  }

  static Future<File> _getProfileFile() async {
    final dirPath = await _userDirPath;
    final dir = Directory(dirPath);
    await dir.create(recursive: true);
    final file = File('$dirPath/profile.json');
    return file;
  }

  static Future<void> _saveToFile() async {
    if (_currentProfile == null) return;
    try {
      final file = await _getProfileFile();
      await file.writeAsString(jsonEncode(_currentProfile!.toMap()));
      print('✅ [ProfileService] профиль сохранён в ${file.path}');
    } catch (e) {
      print('❌ [ProfileService] ошибка сохранения: $e');
    }
  }

  static Future<void> loadProfileFromFile() async {
    try {
      final file = await _getProfileFile();
      if (!await file.exists()) {
        print('ℹ️ [ProfileService] файл профиля не существует');
        _currentProfile = null;
        _notifyListeners();
        return;
      }
      final json = await file.readAsString();
      final Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>;
      _currentProfile = UserProfile.fromMap(map);

      // Проверяем существование аватара (только для файловых путей, не для assets)
      final avatarPath = _currentProfile?.selectedAvatar;
      if (avatarPath != null && avatarPath.isNotEmpty && !avatarPath.startsWith('assets/')) {
        final exists = await File(avatarPath).exists();
        if (!exists) {
          print('⚠️ [ProfileService] Аватар не найден, сбрасываю: $avatarPath');
          _currentProfile = _currentProfile!.copyWith(selectedAvatar: null);
          await _saveToFile(); // сохраняем исправленный профиль
        }
      }

      print('✅ [ProfileService] профиль загружен, имя: ${_currentProfile?.name}');
      _notifyListeners();
    } catch (e) {
      print('❌ [ProfileService] ошибка загрузки: $e');
      _currentProfile = null;
      _notifyListeners();
    }
  }

  static Future<void> _deleteProfileFile() async {
    try {
      final file = await _getProfileFile();
      if (await file.exists()) {
        await file.delete();
        print('🗑 [ProfileService] файл профиля удалён');
      }
    } catch (e) {
      print('❌ [ProfileService] ошибка удаления: $e');
    }
  }

  static Future<void> registerWithEmail(String email, [String? name]) async {
    _currentProfile = UserProfile(
      email: email,
      name: name ?? _extractNameFromEmail(email),
      completedAt: DateTime.now().toIso8601String(),
      selectedAvatar: 'assets/images/Anna.jpg',
    );
    print('✅ Пользователь зарегистрирован: ${_currentProfile!.name}');
    await _saveToFile();
    await ApiService.registerProfile(_currentProfile!);
    _notifyListeners();
  }

  static Future<void> updateAvatar(String avatarPath) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(
        selectedAvatar: avatarPath,
        completedAt: DateTime.now().toIso8601String(),
      );
      print('✅ Аватар обновлён: $avatarPath');
      await _saveToFile();
      await ApiService.registerProfile(_currentProfile!);
      _notifyListeners();
    }
  }

  static Future<void> updateProfile(UserProfile newProfile) async {
    _currentProfile = newProfile.copyWith(
      completedAt: DateTime.now().toIso8601String(),
    );
    print('✅ Профиль обновлён: ${newProfile.name}');
    await _saveToFile();
    await ApiService.registerProfile(_currentProfile!);
    _notifyListeners();
  }

  static Future<void> updateName(String name) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(name: name);
      await _saveToFile();
      await ApiService.registerProfile(_currentProfile!);
      _notifyListeners();
    }
  }

  static Future<void> updateEmail(String email) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(email: email);
      await _saveToFile();
      await ApiService.registerProfile(_currentProfile!);
      _notifyListeners();
    }
  }

  static Future<void> updateAge(int? age) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(age: age);
      await _saveToFile();
      await ApiService.registerProfile(_currentProfile!);
      _notifyListeners();
    }
  }

  static Future<void> reset() async {
    _currentProfile = null;
    await _deleteProfileFile();
    _notifyListeners();
  }

  static void addListener(VoidCallback listener) => _listeners.add(listener);
  static void removeListener(VoidCallback listener) => _listeners.remove(listener);

  static void _notifyListeners() {
    for (final listener in List.from(_listeners)) {
      try {
        listener();
      } catch (e) {
        print('Ошибка в слушателе ProfileService: $e');
      }
    }
  }

  static String _extractNameFromEmail(String email) {
    final namePart = email.split('@').first;
    final cleanName = namePart.replaceAll(RegExp(r'[0-9._+-]'), ' ');
    if (cleanName.isNotEmpty) {
      return cleanName[0].toUpperCase() + cleanName.substring(1);
    }
    return 'Пользователь';
  }
  static Future<void> saveProfile(UserProfile profile) async {
    _currentProfile = profile;
    await _saveToFile();
    _notifyListeners();
    print('✅ [ProfileService] профиль сохранён (saveProfile)');
  }
}