// lib/services/emulator_test_service.dart

import 'package:flutter/services.dart';
//import 'package:path/path.dart' as path;

class EmulatorTestService {
  static const MethodChannel _channel =
      MethodChannel('com.george_samusevich.soul_pair/emulator_test');

  /// Проверяет доступность галереи на эмуляторе
  static Future<bool> checkGalleryExists() async {
    try {
      final bool? exists =
          await _channel.invokeMethod<bool>('checkGalleryExists');
      return exists ?? false;
    } on PlatformException catch (e) {
      print('❌ Ошибка проверки галереи: ${e.message}');
      return false;
    }
  }

  /// Создает галерею на эмуляторе
  static Future<bool> createGallery() async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('createGallery');
      return success ?? false;
    } on PlatformException catch (e) {
      print('❌ Ошибка создания галереи: ${e.message}');
      return false;
    }
  }

  /// Копирует тестовые файлы в галерею
  static Future<bool> copyTestFilesToGallery() async {
    try {
      final bool? success =
          await _channel.invokeMethod<bool>('copyTestFilesToGallery');
      return success ?? false;
    } on PlatformException catch (e) {
      print('❌ Ошибка копирования файлов: ${e.message}');
      return false;
    }
  }

  /// Настраивает камеру эмулятора
  static Future<bool> setupEmulatorCamera() async {
    try {
      final bool? success =
          await _channel.invokeMethod<bool>('setupEmulatorCamera');
      return success ?? false;
    } on PlatformException catch (e) {
      print('❌ Ошибка настройки камеры: ${e.message}');
      return false;
    }
  }

  /// Копирует тестовые файлы камеры
  static Future<bool> copyCameraTestFiles() async {
    try {
      final bool? success =
          await _channel.invokeMethod<bool>('copyCameraTestFiles');
      return success ?? false;
    } on PlatformException catch (e) {
      print('❌ Ошибка копирования файлов камеры: ${e.message}');
      return false;
    }
  }

  /// Получает список тестовых файлов
  static Future<List<String>> getTestFileList() async {
    try {
      final List<dynamic>? files =
          await _channel.invokeMethod<List<dynamic>>('getTestFileList');
      return files?.cast<String>() ?? [];
    } on PlatformException catch (e) {
      print('❌ Ошибка получения списка файлов: ${e.message}');
      return [];
    }
  }

  /// Проверяет наличие директории DCIM
  static Future<bool> checkDcimDirectory() async {
    try {
      final bool? exists =
          await _channel.invokeMethod<bool>('checkDcimDirectory');
      return exists ?? false;
    } on PlatformException catch (e) {
      print('❌ Ошибка проверки DCIM: ${e.message}');
      return false;
    }
  }

  /// Тест выбора файла через приложение
  static Future<String?> testGalleryPick() async {
    try {
      final String? path =
          await _channel.invokeMethod<String>('testGalleryPick');
      return path;
    } on PlatformException catch (e) {
      print('❌ Ошибка теста галереи: ${e.message}');
      return null;
    }
  }

  /// Тест съемки через камеру
  static Future<String?> testCameraCapture() async {
    try {
      final String? path =
          await _channel.invokeMethod<String>('testCameraCapture');
      return path;
    } on PlatformException catch (e) {
      print('❌ Ошибка теста камеры: ${e.message}');
      return null;
    }
  }
}
