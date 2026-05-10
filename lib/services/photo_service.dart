// lib/services/photo_service.dart - БЕЗ path_provider
import 'dart:io';
import 'package:flutter/material.dart';

class PhotoService {
  // 🆕 БУФЕР ДЛЯ ВРЕМЕННЫХ ФОТО В ПАМЯТИ
  static final Map<String, String> _photoData =
      {}; // path -> base64 или временный ID

  // 🆕 SIMULATED PHOTO PICKER - имитация загрузки фото
  static Future<File?> pickImageFromGallery() async {
    debugPrint('📸 Имитация выбора фото из галереи...');

    // ⚠️ ЭТО ВРЕМЕННАЯ ЗАГЛУШКА!
    // В реальном приложении здесь будет вызов нативного Photo Picker

    await Future.delayed(const Duration(milliseconds: 500));

    // Показываем сообщение, что функция в разработке
    debugPrint('⚠️ Photo Picker временно недоступен');
    return null;
  }

  // 🆕 SIMULATED CAMERA - имитация камеры
  static Future<File?> takePhotoWithCamera() async {
    debugPrint('📷 Имитация съемки фото...');

    await Future.delayed(const Duration(milliseconds: 500));

    debugPrint('⚠️ Камера временно недоступна');
    return null;
  }

  // 🆕 ДИАЛОГ ВЫБОРА ИСТОЧНИКА ФОТО
  static Future<dynamic> showImageSourceDialog(BuildContext context) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ЗАГОЛОВОК
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Добавить фото',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),

            // ОПЦИИ
            _buildOptionTile(
              context,
              icon: Icons.photo_library,
              title: 'Выбрать из галереи',
              subtitle: 'Выбрать фото из вашей галереи',
              onTap: () {
                Navigator.pop(context, 'gallery');
              },
              color: Colors.green,
            ),

            _buildOptionTile(
              context,
              icon: Icons.camera_alt,
              title: 'Сделать фото',
              subtitle: 'Сфотографироваться сейчас',
              onTap: () {
                Navigator.pop(context, 'camera');
              },
              color: Colors.blue,
            ),

            _buildOptionTile(
              context,
              icon: Icons.photo,
              title: 'Выбрать готовый аватар',
              subtitle: 'Выбрать из коллекции аватарок',
              onTap: () {
                Navigator.pop(context, 'avatar');
              },
              color: Colors.purple,
            ),

            const Divider(),

            // ОТМЕНА
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    return result;
  }

  // 🆕 ПОКАЗАТЬ, ЧТО ФУНКЦИЯ В РАЗРАБОТКЕ
  static void _showFeatureInDevelopment(
      BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - функция в разработке'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 🆕 СОЗДАТЬ ВРЕМЕННЫЙ ПУТЬ ДЛЯ ФОТО
  static String _createTempPath() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomId = timestamp % 10000;
    return '/temp/user_photo_$timestamp$randomId.jpg';
  }

  // 🆕 СОХРАНИТЬ ВРЕМЕННОЕ ФОТО
  static String saveTemporaryPhoto(String photoData) {
    final path = _createTempPath();
    _photoData[path] = photoData;
    return path;
  }

  // 🆕 ПОЛУЧИТЬ ВРЕМЕННОЕ ФОТО
  static String? getTemporaryPhoto(String path) {
    return _photoData[path];
  }

  // 🆕 ВСПОМОГАТЕЛЬНЫЙ МЕТОД ДЛЯ ОПЦИЙ
  static Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // 🆕 УДАЛИТЬ ВРЕМЕННЫЕ ФАЙЛЫ
  static void cleanupTemporaryFiles() {
    _photoData.clear();
    debugPrint('Временные фото очищены');
  }

  // 🆕 ПРОВЕРИТЬ, ЯВЛЯЕТСЯ ЛИ ПУТЬ ВРЕМЕННЫМ ФАЙЛОМ
  static bool isTemporaryFile(String path) {
    return _photoData.containsKey(path) ||
        path.contains('/temp/') ||
        path.contains('user_photo_');
  }
}
