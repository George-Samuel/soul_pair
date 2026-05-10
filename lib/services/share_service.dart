import 'package:flutter/services.dart';

class ShareService {
  static const MethodChannel _channel = MethodChannel('soul_pair/share');

  /// Открыть системный диалог "Поделиться" с текстом
  static Future<bool> shareText(String text) async {
    try {
      final dynamic result = await _channel.invokeMethod('shareText', {'text': text});
      // Приводим результат к bool, безопасно обрабатывая null
      final bool success = (result as bool?) ?? false;
      return success;
    } on PlatformException catch (e) {
      print('Ошибка при шаринге текста: ${e.message}');
      return false;
    } catch (e) {
      print('Неизвестная ошибка: $e');
      return false;
    }
  }

  /// Открыть системный диалог "Поделиться" с файлом (изображение, документ и т.п.)
  static Future<bool> shareFile(String filePath, {String mimeType = '*/*'}) async {
    try {
      final dynamic result = await _channel.invokeMethod('shareFile', {
        'filePath': filePath,
        'mimeType': mimeType,
      });
      final bool success = (result as bool?) ?? false;
      return success;
    } on PlatformException catch (e) {
      print('Ошибка при шаринге файла: ${e.message}');
      return false;
    } catch (e) {
      print('Неизвестная ошибка: $e');
      return false;
    }
  }
}