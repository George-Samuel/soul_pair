import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class ApiService {
  static const String baseUrl = 'https://soul-backend-5pcj.onrender.com';

  static Future<bool> registerProfile(UserProfile profile) async {
    try {
      final url = Uri.parse('$baseUrl/register');
      print('🌐 Регистрация: $url');

      String finalPassword = profile.password ?? '';
      if (finalPassword.isEmpty) {
        print('❌ Пароль не передан! Регистрация отменена.');
        return false;
      }
      print('🔑 Пароль из профиля: $finalPassword');

      Map<String, dynamic> data = profile.toMap();
      data['password'] = finalPassword;
      print('📦 Отправляемые данные: $data');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        print('✅ Регистрация успешна');
        return true;
      } else {
        print(
            '❌ Ошибка регистрации: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Исключение при регистрации: $e');
      return false;
    }
  }

  static Future<bool> login(String userId, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      print('🌐 Вход: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': userId, 'password': password}),
      );
      if (response.statusCode == 200) {
        print('✅ Вход выполнен');
        return true;
      } else {
        print('❌ Ошибка входа: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Исключение при входе: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔵 1. Начинаем вход через Google');
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '69193608569-lljeikos3ttitkug6vg05dn43mshsivq.apps.googleusercontent.com',
      );
      await _googleSignIn.signOut();
      print('🔵 2. Выполнен выход из предыдущей сессии Google');
      print('🔵 3. Объект GoogleSignIn создан');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) return null;

      print('🔵 6. Отправляем idToken на сервер');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final String userId = data['user_id'] as String;
        final String email = userId.replaceAll('_at_', '@').replaceAll('_dot_', '.');
        return {
          'user_id': userId,
          'email': email,
          'name': googleUser.displayName ?? '',
          'picture': googleUser.photoUrl ?? '',
        };
      } else {
        print('❌ Ошибка верификации Google: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка входа через Google: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile/$userId'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ Ошибка получения профиля: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchOtherProfiles(String myId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profiles?exclude=$myId'));
      print('🔍 [fetchOtherProfiles] status: ${response.statusCode}, body length: ${response.body.length}');
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        print('🔍 [fetchOtherProfiles] decoded type: ${decoded.runtimeType}');
        if (decoded is Map<String, dynamic>) {
          print('🔍 [fetchOtherProfiles] найдено пользователей: ${decoded.length}');
          return decoded;
        } else {
          print('❌ [fetchOtherProfiles] Ответ не является картой: $decoded');
          return {};
        }
      }
      return {};
    } catch (e) {
      print('❌ [fetchOtherProfiles] ошибка: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> fetchAllProfiles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profiles'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      }
      return {};
    } catch (e) {
      print(e);
      return {};
    }
  }

  static Future<bool> sendMessage({
    required String fromId,
    required String toId,
    String text = '',
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from': fromId,
          'to': toId,
          'text': text,
          if (imageUrl != null) 'image_url': imageUrl,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getDialog({
    required String user1,
    required String user2,
    int lastId = 0,
  }) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/get_dialog?user1=$user1&user2=$user2&last_id=$lastId'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final messages = decoded['messages'];
          if (messages is List) {
            return messages.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<void> sendHeartbeat(String userId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/heartbeat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<Set<String>> fetchOnlineUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/online'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return {for (var e in decoded) e.toString()};
      }
    } catch (e) {
      print(e);
    }
    return {};
  }

  static Future<Map<String, int>> fetchUnreadCounts(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/unread?user_id=$userId'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded.map((k, v) => MapEntry(k, v as int));
        }
      }
    } catch (e) {
      print(e);
    }
    return {};
  }

  static Future<void> markRead(String userId, String fromUserId, int lastReadId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/mark_read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'from_user': fromUserId,
          'last_read_id': lastReadId
        }),
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> banUser(String adminId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ban_user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'admin_id': adminId, 'user_id': userId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> deleteUser(String adminId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'admin_id': adminId, 'user_id': userId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> reportMessage(String fromUserId, String reportedUserId,
      String messageId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/report_message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from_user': fromUserId,
          'reported_user': reportedUserId,
          'message_id': messageId,
          'reason': reason
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_reports'));
      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        if (body is List) return body.whereType<Map<String, dynamic>>().toList();
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  static Future<bool> resolveReport(String adminId, int reportId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resolve_report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'admin_id': adminId, 'report_id': reportId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<Map<String, dynamic>> fetchStats() async {
    try {
      final userId = ProfileService.currentProfile?.id ?? '';
      final response = await http.get(Uri.parse('$baseUrl/stats?admin_id=$userId'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (e) {
      print(e);
    }
    return {};
  }

  static Future<bool> checkNsfw(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/check_nsfw'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        var data = jsonDecode(await response.stream.bytesToString());
        return data['safe'] == true;
      } else {
        print('NSFW check failed with status ${response.statusCode}, allowing upload');
        return true;
      }
    } catch (e) {
      print('NSFW check exception: $e, allowing upload');
      return true;
    }
  }

  // ===== НОВЫЙ МЕТОД УДАЛЕНИЯ СООБЩЕНИЯ =====
  static Future<bool> deleteMessage({
    required String userId,
    required int messageId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'message_id': messageId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка удаления сообщения: $e');
      return false;
    }
  }

  static Future<String?> uploadPhoto(String imagePath) async {
    try {
      final url = Uri.parse('$baseUrl/upload_photo');
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData) as Map<String, dynamic>;
        final photoUrl = json['photo_url'] as String?;
        return photoUrl;
      } else {
        print('Ошибка загрузки фото: статус ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Исключение при загрузке фото: $e');
      return null;
    }
  }
}