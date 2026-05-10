import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AvatarGeneratorService {
  static const String _workerUrl = 'https://square-unit-60d8.electron-geo.workers.dev';

  static Future<Uint8List> generateAvatar(String prompt) async {
    final response = await http.post(
      Uri.parse(_workerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final String base64Image = data['image'] as String; // явное приведение
      return base64Decode(base64Image);
    } else {
      throw Exception('Ошибка генерации: ${response.statusCode} - ${response.body}');
    }
  }
}