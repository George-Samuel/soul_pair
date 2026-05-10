import 'dart:convert';
import 'package:http/http.dart' as http;

class YandexGptService {
  // 🔥 ВСТАВЬТЕ ВАШИ ДАННЫЕ ИЗ ЛИЧНОГО КАБИНЕТА YANDEX CLOUD
  static const String _apiKey = 'ВАШ_API_КЛЮЧ';     // API-ключ сервисного аккаунта
  static const String _catalogId = 'ВАШ_ID_КАТАЛОГА'; // ID вашего каталога

  // Актуальный эндпоинт YandexGPT API (для модели yandexgpt-lite)
  static const String _baseUrl = 'https://llm.api.cloud.yandex.net/foundationModels/v1/completion';

  static Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      // Преобразуем историю сообщений
      final List<Map<String, String>> apiMessages = messages.map((msg) {
        return {
          'role': msg['role']!,
          'text': msg['content']!,
        };
      }).toList();

      // Формируем тело запроса
      final Map<String, dynamic> requestBody = {
        'modelUri': 'gpt://$_catalogId/yandexgpt-lite',
        'completionOptions': {
          'stream': false,
          'temperature': 0.7,
          'maxTokens': 500,
        },
        'messages': apiMessages,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Api-Key $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        // Проверяем структуру ответа
        final result = data['result'] as Map<String, dynamic>?;
        if (result == null) throw Exception('Нет поля result');
        final alternatives = result['alternatives'] as List<dynamic>?;
        if (alternatives == null || alternatives.isEmpty) throw Exception('Нет alternatives');
        final firstAlternative = alternatives[0] as Map<String, dynamic>;
        final message = firstAlternative['message'] as Map<String, dynamic>;
        final text = message['text'] as String;
        return text.trim();
      } else {
        print('❌ Ошибка YandexGPT: ${response.statusCode} - ${response.body}');
        return 'Извините, сервер временно недоступен. Попробуйте позже.';
      }
    } catch (e) {
      print('❌ Исключение YandexGPT: $e');
      return 'Извините, произошла ошибка. Попробуйте ещё раз.';
    }
  }
}