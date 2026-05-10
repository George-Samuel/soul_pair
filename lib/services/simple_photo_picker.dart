// lib/services/simple_photo_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimplePhotoPicker {
  static const MethodChannel _channel =
      MethodChannel('com.soulpairmind/photo_picker');

  // 1. ПРОСТОЙ ВЫЗОВ ГАЛЕРЕИ
  static Future<Map<String, dynamic>?> pickFromGallery() async {
    try {
      print('📸 Вызов нативной галереи...');

      final result = await _channel.invokeMethod('pickImageFromGallery');
      print('📸 Результат: $result');

      if (result != null) {
        return {
          'success': true,
          'uri': result.toString(),
          'type': 'gallery',
        };
      }

      return {'success': false, 'error': 'Пользователь отменил'};
    } on PlatformException catch (e) {
      print('❌ PlatformException: ${e.message}');
      return {'success': false, 'error': 'Ошибка платформы: ${e.message}'};
    } catch (e) {
      print('❌ Ошибка: $e');
      return {'success': false, 'error': 'Неизвестная ошибка: $e'};
    }
  }

  // 2. ПРОСТОЙ ВЫЗОВ КАМЕРЫ
  static Future<Map<String, dynamic>?> takeWithCamera() async {
    try {
      print('📷 Вызов нативной камеры...');

      final result = await _channel.invokeMethod('takePhotoWithCamera');
      print('📷 Результат: $result');

      if (result != null) {
        return {
          'success': true,
          'uri': result.toString(),
          'type': 'camera',
        };
      }

      return {'success': false, 'error': 'Пользователь отменил'};
    } on PlatformException catch (e) {
      print('❌ PlatformException: ${e.message}');
      return {'success': false, 'error': 'Ошибка платформы: ${e.message}'};
    } catch (e) {
      print('❌ Ошибка: $e');
      return {'success': false, 'error': 'Неизвестная ошибка: $e'};
    }
  }

  // 3. ПРОСТОЙ ДИАЛОГ ВЫБОРА
  static Future<void> showSourceDialog(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.green),
            title: const Text('Галерея'),
            subtitle: const Text('Выбрать фото из галереи'),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('Камера'),
            subtitle: const Text('Сделать фото сейчас'),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );

    if (result == 'gallery') {
      final galleryResult = await pickFromGallery();
      _showResult(context, galleryResult, 'Галерея');
    } else if (result == 'camera') {
      final cameraResult = await takeWithCamera();
      _showResult(context, cameraResult, 'Камера');
    }
  }

  // 4. ПОКАЗ РЕЗУЛЬТАТА
  static void _showResult(
      BuildContext context, Map<String, dynamic>? result, String source) {
    if (result == null) return;

    if (result['success'] == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ Успешно!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Источник: $source'),
              const SizedBox(height: 10),
              Text('URI: ${result['uri']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Ошибка'),
          content: Text('$source: ${result['error']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // 5. СОЗДАТЬ ДЕМО-ФАЙЛ (для теста)
  static Future<File> createDemoFile(String type) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempDir = Directory.systemTemp;

    String fileName;
    if (type == 'gallery') {
      fileName = 'gallery_demo_$timestamp.jpg';
    } else {
      fileName = 'camera_demo_$timestamp.jpg';
    }

    final file = File('${tempDir.path}/$fileName');
    await file.create();

    print('📁 Создан демо-файл: ${file.path}');
    return file;
  }
}
