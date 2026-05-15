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
  final TextEditingController _newUserNameController = TextEditingController();
  final TextEditingController _newUserPasswordController = TextEditingController();

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
    final name = _newUserNameController.text.trim();
    final password = _newUserPasswordController.text.trim();
    if (name.isEmpty || password.isEmpty) {
      _showSnackBar('Введите имя и пароль');
      return;
    }
    if (password.length < 6) {
      _showSnackBar('Пароль должен быть не менее 6 символов');
      return;
    }
    final success = await UserManager.createUser(name, password);
    if (!success) {
      _showSnackBar('Пользователь с таким именем уже существует');
      return;
    }
    // После создания автоматически переключаемся на нового пользователя
    await UserManager.switchToUser(name, password);
    await ProfileService.loadProfileFromFile();
    _newUserNameController.clear();
    _newUserPasswordController.clear();
    if (mounted) {
      // Если у пользователя ещё нет профиля, отправляем на регистрацию
      if (ProfileService.currentProfile == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EmailRegistrationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PathSelectionScreen(
              userProfile: ProfileService.currentProfile!,
            ),
          ),
        );
      }
    }
  }

  Future<void> _selectUser(String userId) async {
    final password = await _showPasswordDialog(userId);
    if (password == null) return; // отмена
    final success = await UserManager.switchToUser(userId, password);
    if (!success) {
      _showSnackBar('Неверный пароль');
      return;
    }
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
          MaterialPageRoute(builder: (context) => const EmailRegistrationScreen()),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog(String userId) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Вход для $userId'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Пароль',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: Text('Все данные пользователя $userId будут удалены без возможности восстановления.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await UserManager.deleteUser(userId);
    await _loadUsers();
    _showSnackBar('Пользователь удалён');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор пользователя')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _newUserNameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя нового пользователя',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newUserPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль (не менее 6 символов)',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _createUser,
                      child: const Text('Создать'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final userId = _users[index];
                return ListTile(
                  leading: const Icon(Icons.account_circle),
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