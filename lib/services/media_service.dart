import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MediaService {
  static const MethodChannel _imageChannel = MethodChannel('com.george_samusevich.soul_pair/image_picker');

  static Future<String?> pickImageFromGallery() async {
    try {
      print('📷 [MediaService] Вызов pickImageFromGallery');
      final String? path = await _imageChannel.invokeMethod('pickFromGallery');
      print('📷 [MediaService] Галерея вернула путь: $path');
      return path;
    } catch (e) {
      print('❌ [MediaService] Ошибка выбора из галереи: $e');
      return null;
    }
  }

  static Future<String?> showImageSourceDialog(BuildContext context) async {
    print('📷 [MediaService] Показываем диалог выбора');
    final completer = Completer<String?>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purple),
                title: const Text('Выбрать из галереи'),
                onTap: () async {
                  print('📷 [MediaService] Нажата галерея');
                  final path = await pickImageFromGallery();
                  print('📷 [MediaService] Получен путь: $path');
                  Navigator.pop(context);
                  completer.complete(path);
                },
              ),
            ],
          ),
        );
      },
    );

    final result = await completer.future;
    print('📷 [MediaService] Диалог завершён, возвращаем путь: $result');
    return result;
  }
}