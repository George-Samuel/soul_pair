import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenRouterAvatarService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'black-forest-labs/flux.2-klein-4b'; // или другая модель

  static Future<Uint8List> generateAvatar(String prompt) async {
    await dotenv.load();
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENROUTER_API_KEY not found in .env');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': _model,
      'messages': [{'role': 'user', 'content': prompt}],
      'modalities': ['image'],
      'image': {'format': 'png', 'size': '512x512'}
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      print('❌ OpenRouter error: ${response.statusCode} - ${response.body}');
      throw Exception('OpenRouter API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    try {
      final choices = data['choices'] as List<dynamic>;
      if (choices.isEmpty) throw Exception('No choices in response');
      final message = choices[0]['message'] as Map<String, dynamic>;
      final images = message['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        final imageData = images[0]['image_url']['url'] as String;
        if (imageData.startsWith('data:image')) {
          final base64Part = imageData.split(',').last;
          return base64Decode(base64Part);
        } else {
          final imageResponse = await http.get(Uri.parse(imageData));
          if (imageResponse.statusCode == 200) {
            return imageResponse.bodyBytes;
          } else {
            throw Exception('Failed to download image from URL');
          }
        }
      } else {
        throw Exception('No image in response');
      }
    } catch (e) {
      print('Error parsing OpenRouter response: $e');
      throw Exception('Invalid response format');
    }
  }
}