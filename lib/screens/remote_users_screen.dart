import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../services/favorite_users_service.dart';
import '../models/user_model.dart';
import 'real_chat_screen.dart';
import 'matches_screen.dart'; // импорт экрана матчей

class RemoteUsersScreen extends StatefulWidget {
  final String currentUserId;
  const RemoteUsersScreen({super.key, required this.currentUserId});

  @override
  State<RemoteUsersScreen> createState() => _RemoteUsersScreenState();
}

class _RemoteUsersScreenState extends State<RemoteUsersScreen> {
  List<UserProfile> _users = [];
  bool _isLoading = true;
  Set<String> _onlineUsers = {};
  Map<String, int> _unreadCounts = {};
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdate() {
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchStatuses();
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    await _fetchUsers();
    await _fetchStatuses();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchUsers() async {
    try {
      final profilesMap = await ApiService.fetchOtherProfiles(widget.currentUserId);
      final List<UserProfile> users = [];
      profilesMap.forEach((key, value) {
        users.add(UserProfile.fromMap(value as Map<String, dynamic>));
      });
      setState(() => _users = users);
    } catch (e) {
      print('Ошибка загрузки пользователей: $e');
    }
  }

  Future<void> _fetchStatuses() async {
    if (!mounted) return;
    final online = await ApiService.fetchOnlineUsers();
    final unread = await ApiService.fetchUnreadCounts(widget.currentUserId);
    if (mounted) {
      setState(() {
        _onlineUsers = online;
        _unreadCounts = unread;
      });
    }
  }

  Widget _buildFavoriteButton(UserProfile user) {
    return FutureBuilder<bool>(
      future: FavoriteUsersService.isFavorite(user.id),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: () async {
            await FavoriteUsersService.toggleFavorite(user.id);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildLikeButton(UserProfile user) {
    return IconButton(
      icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.blue),
      onPressed: () async {
        final result = await ApiService.likeUser(widget.currentUserId, user.id);
        if (result['status'] == 'matched') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Взаимная симпатия!'), backgroundColor: Colors.green),
          );
        } else if (result['status'] == 'liked') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Симпатия отправлена'), duration: Duration(seconds: 1)),
          );
        }
        setState(() {});
      },
    );
  }

  Widget _buildTypeChip(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'Очаг':
        icon = Icons.home;
        color = Colors.brown;
        break;
      case 'Активный':
        icon = Icons.directions_run;
        color = Colors.green;
        break;
      case 'Авантюрист':
        icon = Icons.explore;
        color = Colors.orange;
        break;
      case 'Проводник':
        icon = Icons.flash_on;
        color = Colors.purple;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(type, style: TextStyle(color: color)),
      backgroundColor: color.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользователи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Обновить',
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchesScreen(currentUserId: widget.currentUserId),
                ),
              );
            },
            tooltip: 'Мои симпатии',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _users.isEmpty
            ? const Center(child: Text('Нет других пользователей'))
            : ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            final bool isOnline = _onlineUsers.contains(user.id);
            final int unreadCount = _unreadCounts[user.id] ?? 0;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: user.selectedAvatar != null
                          ? (user.selectedAvatar!.startsWith('assets')
                          ? AssetImage(user.selectedAvatar!) as ImageProvider
                          : FileImage(File(user.selectedAvatar!)))
                          : null,
                      child: user.selectedAvatar == null ? const Icon(Icons.person) : null,
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(user.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.zodiacSign != null && user.zodiacSign.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Знак: ${user.zodiacSign}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                    if (user.dominantType != null)
                      _buildTypeChip(user.dominantType!),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLikeButton(user),
                    _buildFavoriteButton(user),
                    IconButton(
                      icon: const Icon(Icons.chat),
                      onPressed: () async {
                        await ApiService.markRead(widget.currentUserId, user.id, 999999);
                        await _fetchStatuses();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RealChatScreen(
                              targetUserId: user.id,
                              targetName: user.name,
                            ),
                          ),
                        ).then((_) => _fetchStatuses());
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}