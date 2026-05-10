import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static bool _envLoaded = false;

  static Future<void> _ensureEnvLoaded() async {
    if (_envLoaded) return;
    try {
      await dotenv.load(fileName: ".env");
      _envLoaded = true;
      print('✅ AIService: .env загружен повторно');
    } catch (e) {
      print('❌ AIService: не удалось загрузить .env: $e');
      rethrow;
    }
  }

  static Future<String> sendMessage(List<Map<String, String>> messages) async {
    print('🔥🔥 [AIService] sendMessage ВЫЗВАН 🔥🔥');
    try {
      await _ensureEnvLoaded();
    } catch (e) {
      return "Ошибка: не удалось загрузить .env. Убедитесь, что файл существует и включён в активы.";
    }

    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('❌ Ключ OPENROUTER_API_KEY отсутствует после загрузки .env');
      return "Ошибка: API ключ не найден. Проверьте .env файл.";
    }

    print('🔑 Ключ найден: ${apiKey.substring(0, 8)}...');

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'openrouter/free',
          'messages': messages,
        }),
      ).timeout(Duration(seconds: 15));

      print('📡 Статус: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        print('❌ Ошибка API: ${response.body}');
        return "Ошибка ${response.statusCode}: сервер вернул ошибку. Попробуйте позже.";
      }
    } catch (e) {
      print('❌ Исключение: $e');
      return "Ошибка соединения. Проверьте интернет.";
    }
  }
}