import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class GigaChatService {
  // 🔥 ВСТАВЬТЕ СВОИ ДАННЫЕ ИЗ ЛИЧНОГО КАБИНЕТА СБЕРА!
  static const String _clientId = 'ТВОЙ_CLIENT_ID';
  static const String _clientSecret = 'ТВОЙ_CLIENT_SECRET';

  static const String _authUrl = 'https://ngw.devices.sberbank.ru:9443/api/v2/oauth';
  static const String _apiUrl = 'https://gigachat.devices.sberbank.ru/api/v1/chat/completions';

  static Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'model': 'GigaChat',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isEmpty) throw Exception('Нет ответа');
        final firstChoice = choices[0] as Map<String, dynamic>;
        final message = firstChoice['message'] as Map<String, dynamic>;
        final content = message['content'] as String;
        return content.trim();
      } else {
        throw Exception('Ошибка API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ GigaChat ошибка: $e');
      return 'Извините, произошла ошибка. Попробуйте позже.';
    }
  }

  static Future<String> _getAccessToken() async {
    final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
    final response = await http.post(
      Uri.parse(_authUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Basic $credentials',
        'RqUID': _generateUuid(),
      },
      body: {
        'scope': 'GIGACHAT_API_PERS', // для физических лиц
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['access_token'] as String;
      return token;
    } else {
      throw Exception('Ошибка авторизации: ${response.statusCode}');
    }
  }

  static String _generateUuid() {
    // Простая генерация UUID v4 для демонстрации
    final random = Random();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 1
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0,8)}-${hex.substring(8,12)}-${hex.substring(12,16)}-${hex.substring(16,20)}-${hex.substring(20,32)}';
  }
}