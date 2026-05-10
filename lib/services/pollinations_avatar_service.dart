import 'dart:typed_data';
import 'package:http/http.dart' as http;

class PollinationsAvatarService {
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 10);
  static const Duration _retryDelay = Duration(seconds: 1);

  static Future<Uint8List> generateAvatar(String prompt) async {
    final encodedPrompt = Uri.encodeComponent(prompt);
    final url = Uri.parse('https://image.pollinations.ai/prompt/$encodedPrompt');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('🖼 Генерация аватара, попытка $attempt из $_maxRetries');
        final response = await http.get(url).timeout(_timeout);

        if (response.statusCode == 200) {
          print('✅ Аватар успешно сгенерирован');
          return response.bodyBytes;
        } else {
          print('❌ Ошибка HTTP: ${response.statusCode}');
          if (attempt == _maxRetries) break;
          await Future.delayed(_retryDelay);
        }
      } on Exception catch (e) {
        print('❌ Ошибка при попытке $attempt: $e');
        if (attempt == _maxRetries) rethrow;
        await Future.delayed(_retryDelay);
      }
    }

    throw Exception('Не удалось сгенерировать аватар после $_maxRetries попыток');
  }
}