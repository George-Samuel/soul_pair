import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'character_list_screen.dart';
import 'ai_matching_screen.dart';
import 'hybrid_path_screen.dart';
import 'profile_screen.dart';
import 'user_selector_screen.dart';
import 'remote_users_screen.dart';          // ← список пользователей с сервера
import '../services/user_manager.dart';
import 'favorite_users_screen.dart';        // ← избранное

class PathSelectionScreen extends StatelessWidget {
  final UserProfile userProfile;

  const PathSelectionScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите ваш путь'),
        centerTitle: true,
        actions: [
          // 1. Мой профиль
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Мой профиль',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          // 2. Сменить пользователя
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: 'Сменить пользователя',
            onPressed: () async {
              await UserManager.logout();   // ✅ выход
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const UserSelectorScreen()),
                );
              }
            },
          ),
          // 3. Список пользователей с сервера (БЫЛО УТЕРЯНО, ВОЗВРАЩАЕМ)
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Пользователи',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RemoteUsersScreen(
                    currentUserId: userProfile.id,
                  ),
                ),
              );
            },
          ),
          // 4. Избранное (лайки) – НОВАЯ ИКОНКА
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Избранное',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteUsersScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    const Icon(Icons.account_tree, size: 70, color: Colors.purple),
                    const SizedBox(height: 20),
                    const Text(
                      'Куда отправимся?',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ваш профиль готов. Выберите, как продолжить:',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              _buildPathCard(
                context,
                title: 'AI-Проводник',
                subtitle: 'Общайтесь с виртуальным персонажем',
                icon: Icons.psychology,
                color: Colors.purple,
                description: 'Выберите одного из 10 AI-персонажей для глубоких бесед',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CharacterListScreen(
                        userProfile: userProfile,
                        pathType: 'ai_guide',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildPathCard(
                context,
                title: 'AI-Матчинг',
                subtitle: 'Найдите реального человека',
                icon: Icons.favorite,
                color: Colors.red,
                description: 'AI подберёт вам идеальных партнёров на основе вашей анкеты',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIMatchingScreen(
                        userProfile: userProfile,
                        pathType: 'ai_matching',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildPathCard(
                context,
                title: 'Гибридный путь',
                subtitle: 'AI подготовит вас к общению',
                icon: Icons.auto_awesome,
                color: Colors.blue,
                description: 'Сначала пообщайтесь с AI, затем перейдите к реальным людям',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HybridPathScreen(
                        userProfile: userProfile,
                        pathType: 'hybrid',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.grey, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Можно изменить путь позже',
                          style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Вы всегда сможете вернуться и выбрать другой вариант в настройках профиля.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required String description,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[500]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}