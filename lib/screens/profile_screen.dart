import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'chat_history_screen.dart';
import '../main.dart';
import '../utils/theme_colors.dart';
import 'dart:io';
import '../screens/support_screen.dart'; // <-- добавлен импорт

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _currentProfile;
  String? _selectedAvatar;

  final List<String> availableAvatars = [
    'assets/images/Anna.jpg',
    'assets/images/Freya.jpg',
    'assets/images/Hana.jpg',
    'assets/images/Isabella.jpg',
    'assets/images/Kira.jpg',
    'assets/images/Liza.jpg',
    'assets/images/Natalie.jpg',
    'assets/images/Priya.jpg',
    'assets/images/Sakura.jpg',
    'assets/images/Sofia.jpg',
    'assets/images/characters/mark_astrophysicist.jpg',
    'assets/images/characters/dmitry_chef.jpg',
    'assets/images/characters/luke_helicopter_pilot.jpg',
    'assets/images/characters/carlos_winemaker.jpg',
    'assets/images/characters/kai_game_designer.jpg',
    'assets/images/characters/elina_psychotherapist.jpg',
    'assets/images/characters/jasmine_journalist.jpg',
    'assets/images/characters/alisa_art_curator.jpg',
    'assets/images/characters/roza_yacht_captain.jpg',
    'assets/images/characters/mia_eco_activist.jpg',
    'assets/images/hybrid_path/trainers/trainer_anna.jpg',
    'assets/images/hybrid_path/trainers/trainer_maxim.jpg',
    'assets/images/hybrid_path/trainers/trainer_sofia.jpg',
    'assets/images/hybrid_path/matches/match_alexey.jpg',
    'assets/images/hybrid_path/matches/match_maria.jpg',
    'assets/images/hybrid_path/matches/match_dmitry.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    ProfileService.addListener(_refreshProfile);
  }

  @override
  void dispose() {
    ProfileService.removeListener(_refreshProfile);
    super.dispose();
  }

  void _loadProfile() {
    setState(() {
      _currentProfile = ProfileService.currentProfile;
      _selectedAvatar = _currentProfile?.selectedAvatar;
    });
  }

  void _refreshProfile() {
    if (mounted) _loadProfile();
  }

  void _showThemeDialog(BuildContext context) {
    if (appState == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Выберите тему', style: TextStyle(color: ThemeColors.textPrimary(context))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Дневная (светлая)'),
                leading: Icon(Icons.wb_sunny, color: ThemeColors.accent(context)),
                onTap: () {
                  appState?.changeTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Ночная (тёмная)'),
                leading: Icon(Icons.nightlight_round, color: ThemeColors.accent(context)),
                onTap: () {
                  appState?.changeTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
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
    if (_currentProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Мой профиль')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 60, color: ThemeColors.textHint(context)),
              const SizedBox(height: 20),
              Text('Профиль не найден', style: TextStyle(color: ThemeColors.textPrimary(context))),
              const SizedBox(height: 10),
              Text('Создайте профиль через анкету', style: TextStyle(fontSize: 12, color: ThemeColors.textHint(context))),
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
            tooltip: 'Редактировать профиль',
            onPressed: () => _openEditProfileScreen(context),
          ),
          IconButton(
            icon: Icon(Icons.brightness_4, color: ThemeColors.onAccent(context)),
            tooltip: 'Тема',
            onPressed: () => _showThemeDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    userProfile: profile,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'История чатов',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Центральная часть с аватаром, именем и типом
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showAvatarPicker(context),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: ThemeColors.accent(context),
                            backgroundImage: _selectedAvatar != null
                                ? (_selectedAvatar!.startsWith('assets/')
                                ? AssetImage(_selectedAvatar!)
                                : FileImage(File(_selectedAvatar!)) as ImageProvider)
                                : null,
                            child: _selectedAvatar == null
                                ? Icon(Icons.person, size: 60, color: ThemeColors.onAccent(context))
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: ThemeColors.onAccent(context), width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.textPrimary(context),
                      ),
                    ),
                    if (profile.dominantType != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildTypeChip(profile.dominantType!),
                      ),
                    if (profile.age != null || profile.calculatedAge != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.zodiacSign.isEmpty
                            ? '${profile.age ?? profile.calculatedAge} лет'
                            : '${profile.age ?? profile.calculatedAge} лет, ${profile.zodiacSign}',
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Карточка с основной информацией
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (profile.email != null && profile.email!.isNotEmpty)
                        _buildProfileItem(context, '📧 Email', profile.email!),
                      if (profile.gender != null && profile.gender!.isNotEmpty)
                        _buildProfileItem(context, '👤 Пол', profile.gender!),
                      if (profile.interests != null && profile.interests!.isNotEmpty)
                        _buildProfileItem(context, '🎯 Интересы', profile.interests!),
                      if (profile.education != null && profile.education!.isNotEmpty)
                        _buildProfileItem(context, '🎓 Образование', profile.education!),
                      if (profile.profession != null && profile.profession!.isNotEmpty)
                        _buildProfileItem(context, '💼 Профессия', profile.profession!),
                      if (profile.languages != null && profile.languages!.isNotEmpty)
                        _buildProfileItem(context, '🌐 Языки', profile.languages!),
                      if (profile.country != null && profile.country!.isNotEmpty)
                        _buildProfileItem(context, '🌍 Страна', profile.country!),
                      if (profile.city != null && profile.city!.isNotEmpty)
                        _buildProfileItem(context, '🏙️ Город', profile.city!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Карточка со статистикой профиля
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 Статистика профиля',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: profile.profileCompletion,
                        backgroundColor: ThemeColors.divider(context),
                        color: ThemeColors.accent(context),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Заполнено: ${(profile.profileCompletion * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text('${profile.allPersonalityTraits.length} черт'),
                            backgroundColor: ThemeColors.accent(context).withOpacity(0.1),
                            side: BorderSide.none,
                          ),
                          Chip(
                            label: Text(profile.age != null
                                ? '${profile.age} лет'
                                : profile.calculatedAge != null
                                ? '${profile.calculatedAge} лет'
                                : 'Возраст'),
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            side: BorderSide.none,
                          ),
                          if (profile.completedAt != null)
                            Chip(
                              label: const Text('Обновлён'),
                              backgroundColor: Colors.green.withOpacity(0.1),
                              side: BorderSide.none,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_hasAdditionalInfo(profile))
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📝 Дополнительная информация',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (profile.height != null && profile.height!.isNotEmpty)
                          _buildProfileItem(context, '📏 Рост', '${profile.height} см'),
                        if (profile.weight != null && profile.weight!.isNotEmpty)
                          _buildProfileItem(context, '⚖️ Вес', '${profile.weight} кг'),
                        if (profile.hasChildren != null && profile.hasChildren!.isNotEmpty)
                          _buildProfileItem(context, '👶 Дети', profile.hasChildren!),
                        if (profile.wantsChildren != null && profile.wantsChildren!.isNotEmpty)
                          _buildProfileItem(context, '👨‍👩‍👧‍👦 Хочет детей', profile.wantsChildren!),
                        if (profile.religion != null && profile.religion!.isNotEmpty)
                          _buildProfileItem(context, '🕊️ Религия', profile.religion!),
                        if (profile.attitudeToAnimals != null && profile.attitudeToAnimals!.isNotEmpty)
                          _buildProfileItem(context, '🐕 Отношение к животным', profile.attitudeToAnimals!),
                        if (profile.smoking != null && profile.smoking!.isNotEmpty)
                          _buildProfileItem(context, '🚬 Курение', profile.smoking!),
                        if (profile.alcohol != null && profile.alcohol!.isNotEmpty)
                          _buildProfileItem(context, '🍷 Алкоголь', profile.alcohol!),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Карточка "Редактировать профиль" и "Черты характера"
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.edit, color: ThemeColors.textPrimary(context)),
                      title: Text('Редактировать профиль', style: TextStyle(color: ThemeColors.textPrimary(context))),
                      subtitle: Text('Изменить информацию о себе', style: TextStyle(color: ThemeColors.textSecondary(context))),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: ThemeColors.textHint(context)),
                      onTap: () => _openEditProfileScreen(context),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    const Divider(height: 0, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.psychology, color: Colors.blue),
                      title: Text('Черты характера', style: TextStyle(color: ThemeColors.textPrimary(context))),
                      subtitle: Text('${profile.allPersonalityTraits.length} черт определено', style: TextStyle(color: ThemeColors.textSecondary(context))),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: ThemeColors.textHint(context)),
                      onTap: () => _showPersonalityTraits(context),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // НОВАЯ КАРТОЧКА "ПОДДЕРЖАТЬ ПРОЕКТ"
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.favorite, color: Colors.red),
                  title: Text('Поддержать проект', style: TextStyle(color: ThemeColors.textPrimary(context))),
                  subtitle: Text('Добровольная помощь проекту', style: TextStyle(color: ThemeColors.textSecondary(context))),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: ThemeColors.textHint(context)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SupportScreen()),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Выберите аватарку',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    '${availableAvatars.length} вариантов',
                    style: TextStyle(color: ThemeColors.textSecondary(context)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: availableAvatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        ProfileService.updateAvatar(availableAvatars[index]);
                        setState(() {
                          _selectedAvatar = availableAvatars[index];
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Аватарка сохранена!'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedAvatar == availableAvatars[index]
                                ? ThemeColors.accent(context)
                                : ThemeColors.accent(context).withOpacity(0.3),
                            width: _selectedAvatar == availableAvatars[index] ? 3 : 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            availableAvatars[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: ThemeColors.divider(context),
                                child: Icon(
                                  Icons.person,
                                  color: ThemeColors.textHint(context),
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Закрыть',
                    style: TextStyle(color: ThemeColors.textPrimary(context)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      _loadProfile();
    }
  }

  void _showPersonalityTraits(BuildContext context) {
    if (_currentProfile == null) return;
    final traits = _currentProfile!.allPersonalityTraits;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Черты характера', style: TextStyle(color: ThemeColors.textPrimary(context))),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: traits
                .map((trait) => Chip(
              label: Text(trait),
              backgroundColor: ThemeColors.accent(context).withOpacity(0.1),
            ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: ThemeColors.accent(context))),
          ),
        ],
      ),
    );
  }

  bool _hasAdditionalInfo(UserProfile profile) {
    return (profile.height != null && profile.height!.isNotEmpty) ||
        (profile.weight != null && profile.weight!.isNotEmpty) ||
        (profile.hasChildren != null && profile.hasChildren!.isNotEmpty) ||
        (profile.wantsChildren != null && profile.wantsChildren!.isNotEmpty) ||
        (profile.religion != null && profile.religion!.isNotEmpty) ||
        (profile.attitudeToAnimals != null && profile.attitudeToAnimals!.isNotEmpty) ||
        (profile.smoking != null && profile.smoking!.isNotEmpty) ||
        (profile.alcohol != null && profile.alcohol!.isNotEmpty);
  }

  Widget _buildProfileItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeColors.textSecondary(context),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: ThemeColors.textPrimary(context),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}