import 'dart:typed_data';
import 'package:http/http.dart' as http;

class DicebearAvatarService {
  static Future<Uint8List> generateAvatar(String prompt) async {
    // Используем текущее время как seed — гарантированно новый аватар
    final seed = DateTime.now().millisecondsSinceEpoch.toString();
    // Фиксированный стиль (можно любой, например 'avataaars')
    const style = 'adventurer';
    final url = Uri.parse('https://api.dicebear.com/9.x/$style/png?seed=$seed');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Ошибка DiceBear: ${response.statusCode}');
    }
  }
}