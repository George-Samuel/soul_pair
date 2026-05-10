import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

class StorageService {
  static const MethodChannel _channel = MethodChannel('soul_pair/storage');

  static Future<String> getFilesDir() async {
    try {
      return await _channel.invokeMethod('getFilesDir') as String;
    } catch (e) {
      return Directory.systemTemp.path;
    }
  }

  static Future<bool> saveProfile({
    required String id,
    required String name,
    String? avatarPath,
    int? lastSeen,
  }) async {
    try {
      return await _channel.invokeMethod('saveProfile', {
        'id': id,
        'name': name,
        'avatarPath': avatarPath,
        'lastSeen': lastSeen ?? DateTime.now().millisecondsSinceEpoch,
      }) as bool;
    } catch (e) {
      print('❌ saveProfile error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getProfile(String id) async {
    try {
      final String? json = await _channel.invokeMethod('getProfile', {'id': id}) as String?;
      if (json != null) {
        return jsonDecode(json) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ getProfile error: $e');
      return null;
    }
  }

  static Future<bool> saveMessage({
    required String chatId,
    required String profileId,
    required String text,
    int? timestamp,
    bool isSent = false,
  }) async {
    try {
      return await _channel.invokeMethod('saveMessage', {
        'chatId': chatId,
        'profileId': profileId,
        'text': text,
        'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
        'isSent': isSent,
      }) as bool;
    } catch (e) {
      print('❌ saveMessage error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getChatHistory(String chatId, {int limit = 100}) async {
    try {
      final String json = await _channel.invokeMethod('getChatHistory', {
        'chatId': chatId,
        'limit': limit,
      }) as String;

      final Map<String, dynamic> data = jsonDecode(json) as Map<String, dynamic>;
      final List<dynamic> messagesList = data['messages'] as List<dynamic>? ?? [];
      return messagesList.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ getChatHistory error: $e');
      return [];
    }
  }

  static Future<String?> saveAvatarImage(String profileId, Uint8List bytes) async {
    try {
      return await _channel.invokeMethod('saveAvatarImage', {
        'profileId': profileId,
        'imageBytes': bytes,
      }) as String?;
    } catch (e) {
      print('❌ saveAvatarImage error: $e');
      return null;
    }
  }
}