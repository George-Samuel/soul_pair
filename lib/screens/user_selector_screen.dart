import 'package:flutter/material.dart';
import '../services/user_manager.dart';
import '../services/profile_service.dart';
import 'path_selection_screen.dart';
import 'email_registration_screen.dart';

class UserSelectorScreen extends StatefulWidget {
  const UserSelectorScreen({super.key});

  @override
  State<UserSelectorScreen> createState() => _UserSelectorScreenState();
}

class _UserSelectorScreenState extends State<UserSelectorScreen> {
  List<String> _users = [];
  final TextEditingController _newUserController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await UserManager.loadUsers();
    setState(() {
      _users = UserManager.getUsers();
    });
  }

  Future<void> _createUser() async {
    final name = _newUserController.text.trim();
    if (name.isEmpty) return;
    await UserManager.createUser(name);
    await UserManager.switchToUser(name);
    await ProfileService.loadProfileFromFile();
    _newUserController.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmailRegistrationScreen()),
      );
    }
  }

  Future<void> _selectUser(String userId) async {
    await UserManager.switchToUser(userId);
    await ProfileService.loadProfileFromFile();
    if (mounted) {
      final profile = ProfileService.currentProfile;
      if (profile != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PathSelectionScreen(userProfile: profile),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const EmailRegistrationScreen(),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(String userId) async {
    await UserManager.deleteUser(userId);
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор пользователя')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newUserController,
                    decoration: const InputDecoration(
                      labelText: 'Имя нового пользователя',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _createUser,
                  child: const Text('Создать'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final userId = _users[index];
                return ListTile(
                  title: Text(userId),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(userId),
                  ),
                  onTap: () => _selectUser(userId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}