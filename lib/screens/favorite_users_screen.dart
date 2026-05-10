import 'package:flutter/material.dart';
import '../services/favorite_users_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class FavoriteUsersScreen extends StatefulWidget {
  const FavoriteUsersScreen({super.key});

  @override
  State<FavoriteUsersScreen> createState() => _FavoriteUsersScreenState();
}

class _FavoriteUsersScreenState extends State<FavoriteUsersScreen> {
  List<UserProfile> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favoriteIds = await FavoriteUsersService.loadFavorites();
    final List<UserProfile> users = [];
    for (final id in favoriteIds) {
      final profileMap = await ApiService.fetchProfile(id);
      if (profileMap != null) {
        users.add(UserProfile.fromMap(profileMap));
      }
    }
    setState(() {
      _favorites = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранные пользователи')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? const Center(child: Text('Пока никого не добавили в избранное'))
          : ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final user = _favorites[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await FavoriteUsersService.removeFavorite(user.id);
                  _loadFavorites(); // обновить список
                },
              ),
            ),
          );
        },
      ),
    );
  }
}