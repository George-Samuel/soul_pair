import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import 'real_chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  final String currentUserId;
  const MatchesScreen({super.key, required this.currentUserId});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    final matches = await ApiService.getMatches(widget.currentUserId);
    setState(() {
      _matches = matches;
      _isLoading = false;
    });
  }

  Future<void> _confirmMatch(int matchId) async {
    final success = await ApiService.confirmMatch(widget.currentUserId, matchId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пара подтверждена!'), backgroundColor: Colors.green),
      );
      _loadMatches();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось подтвердить'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои симпатии')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
          ? const Center(child: Text('Пока нет взаимных симпатий'))
          : ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          final String avatarPath = match['avatar'] as String? ?? '';
          final String userName = match['name'] as String? ?? 'Пользователь';
          final String status = match['status'] as String? ?? 'pending';
          final String otherUserId = match['user_id'] as String? ?? '';
          final int matchId = match['match_id'] as int? ?? 0;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: avatarPath.isNotEmpty
                    ? (avatarPath.startsWith('assets')
                    ? AssetImage(avatarPath) as ImageProvider
                    : FileImage(File(avatarPath)))
                    : null,
                child: avatarPath.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(userName),
              subtitle: Text(status == 'confirmed' ? '✅ Пара' : '💕 Взаимная симпатия'),
              trailing: status == 'pending'
                  ? ElevatedButton(
                onPressed: () => _confirmMatch(matchId),
                child: const Text('Подтвердить'),
              )
                  : IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RealChatScreen(
                        targetUserId: otherUserId,
                        targetName: userName,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}