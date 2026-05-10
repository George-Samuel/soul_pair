import 'package:flutter/services.dart';
import 'dart:io';  // ← добавили для Directory

class StoragePath {
  static const _channel = MethodChannel('soul_pair/storage');

  static Future<String> getFilesDir() async {
    try {
      // Явное приведение типа
      final String path = await _channel.invokeMethod('getFilesDir') as String;
      print('📁 [StoragePath] путь к внутреннему хранилищу: $path');
      return path;
    } catch (e) {
      print('❌ [StoragePath] ошибка получения пути: $e');
      return Directory.systemTemp.path; // fallback
    }
  }
}