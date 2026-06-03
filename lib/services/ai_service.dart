import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static bool _envLoaded = false;

  static const String _primaryModel = 'anthropic/claude-3-haiku';
  static const String _fallbackModel = 'openrouter/free';

  static const double _temperature = 0.7;
  static const int _maxTokens = 800;
  static const int _maxContextMessages = 10;

  // Базовый промпт
  static const String _basePrompt =
      'Ты — эмпатичный психолог-консультант в приложении для знакомств "Soul Pair". '
      'Твоя задача — помогать пользователям лучше понимать себя, свои желания и строить здоровые отношения. '
      'Ты задаёшь уточняющие вопросы, даёшь мягкие советы, избегаешь осуждения. '
      'Отвечай тепло, поддерживающе, но без излишней эмоциональности. Будь кратким и по делу (2-4 предложения).';

  // Строим системный промпт с инструкцией избегать пола
  static String _buildSystemPrompt() {
    const String avoidGender =
        ' ВАЖНО: В своих ответах НЕ УКАЗЫВАЙ СВОЙ ПОЛ. '
        'ВСЕГДА, КОГДА ТЫ ДОЛЖЕН ИСПОЛЬЗОВАТЬ ГЛАГОЛ, КОТОРЫЙ ЗАВИСИТ ОТ ПОЛА (например, "видел", "думал", "решил", "понял", "сказал", "спросил"), '
        'ТО ПИШИ ИХ В УНИВЕРСАЛЬНОЙ ФОРМЕ С СУФФИКСОМ "(а)": рад(а), видел(а), думал(а), решил(а), понял(а), сказал(а), спросил(а). '
        'Это позволит избежать указания на пол. '
        'ИЛИ Используй безличные обороты: '
        '"можно предположить", "похоже", "видимо", "это говорит о том, что", "создаётся впечатление", "вероятно", "предположительно". '
        'Например, вместо "Я уверен, что..." пиши "Вероятно, что..." или "Можно предположить, что...". '
        'Вместо "Я рад(а) помочь" пиши "Всегда приятно помочь" (без "я") или просто "Помогу с радостью". '
        'Твоя задача — помогать, не акцентируя внимание на своём поле.';
    return _basePrompt + avoidGender;
  }

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

  // Метод для мультимодальных запросов (текст + изображения)
  static Future<String> sendMessageWithParts(
      List<Map<String, dynamic>> parts, {
        String? characterGender, // параметр сохранён для совместимости, но не используется
      }) async {
    print('🔥 [AIService] sendMessageWithParts вызван');
    try {
      await _ensureEnvLoaded();
    } catch (e) {
      return "Ошибка: не удалось загрузить .env. Проверьте файл.";
    }

    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('❌ Ключ OPENROUTER_API_KEY отсутствует');
      return "Ошибка: API ключ не найден. Проверьте .env файл.";
    }
    print('🔑 Ключ найден: ${apiKey.substring(0, 8)}...');

    final systemPrompt = _buildSystemPrompt();
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': parts},
    ];

    var response = await _sendRequest(_primaryModel, messages, apiKey);
    if (response != null && response.statusCode == 200) {
      return _parseResponse(response);
    }

    print('⚠️ Платная модель не ответила, переключаемся на $_fallbackModel');
    response = await _sendRequest(_fallbackModel, messages, apiKey);
    if (response != null && response.statusCode == 200) {
      return _parseResponse(response);
    }

    return "Извините, сейчас не могу ответить. Попробуйте позже.";
  }

  // Старый метод (только текст) – для обратной совместимости
  static Future<String> sendMessage(
      List<Map<String, String>> messages, {
        String? characterGender,
      }) async {
    final parts = messages.map((msg) {
      return {
        'type': 'text',
        'text': msg['content'] ?? '',
      };
    }).toList();
    return sendMessageWithParts(parts, characterGender: characterGender);
  }

  static Future<http.Response?> _sendRequest(
      String model,
      List<Map<String, dynamic>> messages,
      String apiKey,
      ) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'temperature': _temperature,
      'max_tokens': _maxTokens,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://soulpair.app',
          'X-Title': 'Soul Pair App',
        },
        body: body,
      ).timeout(const Duration(seconds: 30));
      print('📡 Модель $model, статус: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Ошибка запроса к $model: $e');
      return null;
    }
  }

  static String _parseResponse(http.Response response) {
    final data = jsonDecode(response.body);
    final choices = data['choices'] as List;
    if (choices.isEmpty) throw Exception('Пустой ответ от модели');
    final content = choices[0]['message']['content'] as String;
    return content.trim();
  }
}