import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import 'edit_profile_screen.dart';

class ProfileFixedScreen extends StatefulWidget {
  const ProfileFixedScreen({super.key});

  @override
  State<ProfileFixedScreen> createState() => _ProfileFixedScreenState();
}

class _ProfileFixedScreenState extends State<ProfileFixedScreen> {
  UserProfile? _currentProfile;
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _loadProfile();

    // Слушаем изменения в ProfileService
    ProfileService.addListener(_refreshProfile);
  }

  @override
  void dispose() {
    ProfileService.removeListener(_refreshProfile);
    super.dispose();
  }

  void _loadProfile() {
    print('🔄 Загружаем профиль из ProfileService...');

    setState(() {
      _currentProfile = ProfileService.currentProfile;
      _selectedAvatar = _currentProfile?.selectedAvatar;
    });

    print('✅ Загружен профиль: ${_currentProfile?.name}');
    print('✅ Аватар: $_selectedAvatar');
  }

  void _refreshProfile() {
    if (mounted) {
      print('🔄 Обновляем UI из ProfileService');
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Профиль')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 60, color: Colors.grey),
              SizedBox(height: 20),
              Text('Профиль не найден'),
              Text('Создайте профиль через анкету',
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final profile = _currentProfile!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
            tooltip: 'Обновить',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openEditProfileScreen(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // АВАТАР
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.purple,
              backgroundImage:
                  _selectedAvatar != null ? AssetImage(_selectedAvatar!) : null,
              child: _selectedAvatar == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 20),

            // ИМЯ (ОБНОВЛЯЕТСЯ АВТОМАТИЧЕСКИ!)
            Text(
              profile.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              profile.email,
              style: const TextStyle(color: Colors.grey),
            ),

            if (profile.age != null || profile.calculatedAge != null)
              Text(
                '${profile.age ?? profile.calculatedAge} лет',
                style: const TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 30),

            // ИНФОРМАЦИЯ
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Основная информация',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildInfoRow('Пол', profile.gender ?? 'Не указан'),
                    _buildInfoRow(
                        'Образование', profile.education ?? 'Не указано'),
                    _buildInfoRow(
                        'Профессия', profile.profession ?? 'Не указана'),
                    _buildInfoRow(
                        'Интересы', profile.interests ?? 'Не указаны'),
                    _buildInfoRow('Языки', profile.languages ?? 'Не указаны'),
                    _buildInfoRow(
                        'Аватар', profile.selectedAvatar ?? 'Не выбран'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // СТАТИСТИКА
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Статистика профиля',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: profile.profileCompletion,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Заполнено: ${(profile.profileCompletion * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // КНОПКИ ТЕСТИРОВАНИЯ
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Тестирование',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        print('=== ТЕСТ ProfileService ===');
                        print('Имя: ${ProfileService.currentProfile?.name}');
                        print(
                            'Аватар: ${ProfileService.currentProfile?.selectedAvatar}');
                        print('=========================');
                      },
                      child: const Text('Проверить данные в Service'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _openEditProfileScreen(BuildContext context) async {
    if (_currentProfile == null) return;

    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialProfile: _currentProfile!,
        ),
      ),
    );

    if (updatedProfile != null && updatedProfile is UserProfile) {
      // Данные уже сохранены в ProfileService через EditProfileScreen
      print('✅ Получен обновленный профиль: ${updatedProfile.name}');
      _loadProfile(); // Обновляем экран
    }
  }
}
