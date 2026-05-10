import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../utils/theme_colors.dart';
import '../services/pollinations_avatar_service.dart';
import '../services/media_service.dart';
import '../services/user_manager.dart';
import '../data/countries.dart';
import '../services/storage_path.dart';
import '../services/favorite_avatars_service.dart';
import '../services/api_service.dart';   // импорт для NSFW

class EditProfileScreen extends StatefulWidget {
  final UserProfile initialProfile;
  final Function(UserProfile)? onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.initialProfile,
    this.onProfileUpdated,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late UserProfile _currentProfile;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _selectedAvatar;
  bool _hasChanges = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _interestsController;
  late TextEditingController _educationController;
  late TextEditingController _professionController;
  late TextEditingController _languagesController;
  late TextEditingController _birthDateController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _cityController;

  CountryItem? _selectedCountry;

  final List<String> _availableAvatars = [
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

  // Ценности
  late Map<String, int> _values;
  final List<Map<String, dynamic>> _valuesList = const [
    {'key': 'family', 'title': 'Семья и дети', 'description': 'Важность создания семьи, забота о детях'},
    {'key': 'career', 'title': 'Карьера и достижения', 'description': 'Стремление к профессиональному росту, успеху'},
    {'key': 'freedom', 'title': 'Свобода и независимость', 'description': 'Личное пространство, самовыражение'},
    {'key': 'stability', 'title': 'Стабильность и безопасность', 'description': 'Финансовая и эмоциональная надёжность'},
    {'key': 'adventure', 'title': 'Приключения и новые впечатления', 'description': 'Путешествия, риск, спонтанность'},
    {'key': 'tradition', 'title': 'Традиции и духовность', 'description': 'Уважение к обычаям, вере, семейным ценностям'},
    {'key': 'self_development', 'title': 'Саморазвитие и обучение', 'description': 'Постоянное развитие, новые знания'},
    {'key': 'altruism', 'title': 'Забота об окружающих и альтруизм', 'description': 'Помощь другим, экология, волонтёрство'},
    {'key': 'health', 'title': 'Здоровье и активный образ жизни', 'description': 'Спорт, питание, ментальное здоровье'},
    {'key': 'humor', 'title': 'Юмор и лёгкость', 'description': 'Важность веселья, иронии, умения не воспринимать себя слишком серьёзно'},
  ];

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.initialProfile;
    _selectedAvatar = _currentProfile.selectedAvatar;

    _nameController = TextEditingController(text: _currentProfile.name);
    _emailController = TextEditingController(text: _currentProfile.email);
    _ageController = TextEditingController(text: _currentProfile.age?.toString() ?? '');
    _interestsController = TextEditingController(text: _currentProfile.interests ?? '');
    _educationController = TextEditingController(text: _currentProfile.education ?? '');
    _professionController = TextEditingController(text: _currentProfile.profession ?? '');
    _languagesController = TextEditingController(text: _currentProfile.languages ?? '');
    _birthDateController = TextEditingController(text: _currentProfile.birthDate ?? '');
    _heightController = TextEditingController(text: _currentProfile.height ?? '');
    _weightController = TextEditingController(text: _currentProfile.weight ?? '');
    _cityController = TextEditingController(text: _currentProfile.city ?? '');

    if (_currentProfile.country != null && _currentProfile.country!.isNotEmpty) {
      _selectedCountry = countriesList.firstWhere(
            (c) => c.name == _currentProfile.country,
        orElse: () => countriesList.first,
      );
    }

    // Ценности
    _values = _currentProfile.values != null ? Map.from(_currentProfile.values!) : {};
    if (_values.isEmpty) {
      for (var item in _valuesList) {
        final key = item['key'] as String;
        _values[key] = 5;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _interestsController.dispose();
    _educationController.dispose();
    _professionController.dispose();
    _languagesController.dispose();
    _birthDateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _updateValue(String key, int newValue) {
    setState(() {
      _values[key] = newValue;
      _hasChanges = true;
    });
  }

  Widget _buildValueSlider(Map<String, dynamic> item) {
    final key = item['key'] as String;
    final title = item['title'] as String;
    final description = item['description'] as String;
    final currentValue = _values[key] ?? 5;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: currentValue.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: currentValue.toString(),
                    onChanged: (val) => _updateValue(key, val.round()),
                    activeColor: ThemeColors.accent(context),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    currentValue.toString(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== ОСТАЛЬНЫЕ МЕТОДЫ =====
  Future<void> _generateAIAvatar(BuildContext context) async {
    final profile = _currentProfile;
    final genderText = profile.gender == 'Мужской' ? 'мужчины' : 'женщины';
    final ageText = profile.age ?? profile.calculatedAge;
    final ageString = ageText != null ? '$ageText лет' : '';
    final profession = profile.profession ?? '';
    final interests = profile.interests ?? '';

    String prompt = 'Реалистичный портрет $genderText';
    if (ageString.isNotEmpty) prompt += ', $ageString';
    if (profession.isNotEmpty) prompt += ', $profession';
    if (interests.isNotEmpty) prompt += ', интересы: $interests';
    prompt += ', европеец(ка), фотографическое качество, нейтральный фон, дружелюбное выражение лица';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imageBytes = await PollinationsAvatarService.generateAvatar(prompt);
      final baseDir = await StoragePath.getFilesDir();
      final avatarsDir = Directory('$baseDir/avatars');
      if (!await avatarsDir.exists()) await avatarsDir.create(recursive: true);
      final fileName = 'ai_avatar_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${avatarsDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      setState(() {
        _selectedAvatar = file.path;
        _currentProfile = _currentProfile.copyWith(selectedAvatar: file.path);
        _hasChanges = true;
      });
      Navigator.pop(context);
      _askAddToFavorites(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✨ AI-аватар создан!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ========== ИСПРАВЛЕННЫЙ МЕТОД ЗАГРУЗКИ ФОТО С NSFW-ПРОВЕРКОЙ ==========
  Future<void> _pickImageFromSource(BuildContext context) async {
    final String? savedPath = await MediaService.showImageSourceDialog(context);
    if (savedPath == null) return;

    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool isSafe = false;
    try {
      final file = File(savedPath);
      isSafe = await ApiService.checkNsfw(file);
    } catch (e) {
      print('Ошибка модерации: $e');
    } finally {
      Navigator.pop(context); // закрываем индикатор
    }

    if (!isSafe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Изображение содержит неприемлемый контент. Пожалуйста, выберите другое фото.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _selectedAvatar = savedPath;
      _currentProfile = _currentProfile.copyWith(selectedAvatar: savedPath);
      _hasChanges = true;
    });
    _askAddToFavorites(savedPath);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Фото загружено!'), backgroundColor: Colors.green),
    );
  }
  // ====================================================================

  Future<void> _setRandomAvatar() async {
    final randomSeed = '${_currentProfile.id}_${DateTime.now().millisecondsSinceEpoch}';
    final url = 'https://api.dicebear.com/9.x/adventurer/png?seed=$randomSeed&size=200';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final baseDir = await StoragePath.getFilesDir();
        final avatarsDir = Directory('$baseDir/avatars');
        if (!await avatarsDir.exists()) await avatarsDir.create(recursive: true);
        final fileName = 'random_avatar_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${avatarsDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _selectedAvatar = file.path;
          _currentProfile = _currentProfile.copyWith(selectedAvatar: file.path);
          _hasChanges = true;
        });
        Navigator.pop(context);
        _askAddToFavorites(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎲 Случайный аватар установлен!'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка генерации: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _askAddToFavorites(String path) async {
    if (path.startsWith('assets/')) return;
    final alreadyFavorite = await FavoriteAvatarsService.isFavorite(path, _genderKey);
    if (alreadyFavorite) return;
    final add = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сохранить в избранное?'),
        content: const Text('Добавить этот аватар в вашу коллекцию избранных?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Да')),
        ],
      ),
    );
    if (add == true) {
      await FavoriteAvatarsService.addFavorite(path, _genderKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аватар добавлен в избранное'), backgroundColor: Colors.purple),
      );
    }
  }

  Future<void> _showFavoritesPicker(BuildContext context) async {
    final favorites = await FavoriteAvatarsService.loadFavorites(_genderKey);
    if (favorites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Избранное пусто. Сначала добавьте аватар в избранное.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Избранные аватары', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final path = favorites[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAvatar = path;
                              _currentProfile = _currentProfile.copyWith(selectedAvatar: path);
                              _hasChanges = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: ThemeColors.accent(context), width: 2),
                                ),
                                child: ClipOval(
                                  child: path.startsWith('assets/')
                                      ? Image.asset(path, fit: BoxFit.cover)
                                      : Image.file(File(path), fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    await FavoriteAvatarsService.removeFavorite(path, _genderKey);
                                    final newFavorites = await FavoriteAvatarsService.loadFavorites(_genderKey);
                                    setStateSheet(() {
                                      favorites.clear();
                                      favorites.addAll(newFavorites);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.remove_circle, size: 24, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String get _genderKey => _currentProfile.gender == 'Мужской' ? 'male' : 'female';

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColors.accent(context),
              onPrimary: ThemeColors.onAccent(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      _birthDateController.text = formattedDate;
      _updateProfileField('birthDate', formattedDate);
    }
  }

  void _updateProfileField(String field, String value) {
    setState(() {
      _hasChanges = true;
      switch (field) {
        case 'name':
          _currentProfile = _currentProfile.copyWith(name: value);
          break;
        case 'email':
          _currentProfile = _currentProfile.copyWith(email: value);
          break;
        case 'interests':
          _currentProfile = _currentProfile.copyWith(interests: value);
          break;
        case 'education':
          _currentProfile = _currentProfile.copyWith(education: value);
          break;
        case 'profession':
          _currentProfile = _currentProfile.copyWith(profession: value);
          break;
        case 'languages':
          _currentProfile = _currentProfile.copyWith(languages: value);
          break;
        case 'birthDate':
          _currentProfile = _currentProfile.copyWith(birthDate: value);
          break;
        case 'height':
          _currentProfile = _currentProfile.copyWith(height: value);
          break;
        case 'weight':
          _currentProfile = _currentProfile.copyWith(weight: value);
          break;
        case 'city':
          _currentProfile = _currentProfile.copyWith(city: value);
          break;
      }
    });
  }

  // ========== BUILD ==========
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          await _saveProfile();
          return true;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Редактирование профиля',
            style: TextStyle(color: ThemeColors.onAccent(context)),
          ),
          actions: [
            IconButton(
              icon: _isSaving
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeColors.onAccent(context)),
                ),
              )
                  : Icon(Icons.save, color: ThemeColors.onAccent(context)),
              onPressed: _isSaving ? null : _saveProfile,
              tooltip: 'Сохранить',
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarSection(context),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, 'Основная информация'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    controller: _nameController,
                    label: 'Имя',
                    icon: Icons.person,
                    isRequired: true,
                    onChanged: (value) => _updateProfileField('name', value),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Введите имя';
                      if (value.length < 2) return 'Имя слишком короткое';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    onChanged: (value) => _updateProfileField('email', value),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Введите email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Введите корректный email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            _buildTextField(
                              context,
                              controller: _ageController,
                              label: 'Возраст',
                              icon: Icons.cake,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final age = int.tryParse(value);
                                if (age != null) {
                                  setState(() {
                                    _hasChanges = true;
                                    _currentProfile = _currentProfile.copyWith(age: age);
                                  });
                                }
                              },
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final age = int.tryParse(value);
                                  if (age == null || age < 18 || age > 100) return 'Введите возраст от 18 до 100';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              context,
                              controller: _birthDateController,
                              label: 'Дата рождения (дд.мм.гггг)',
                              icon: Icons.calendar_today,
                              onTap: () => _selectBirthDate(context),
                              readOnly: true,
                              onChanged: (value) => _updateProfileField('birthDate', value),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                context,
                                controller: _ageController,
                                label: 'Возраст',
                                icon: Icons.cake,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final age = int.tryParse(value);
                                  if (age != null) {
                                    setState(() {
                                      _hasChanges = true;
                                      _currentProfile = _currentProfile.copyWith(age: age);
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final age = int.tryParse(value);
                                    if (age == null || age < 18 || age > 100) return 'Введите возраст от 18 до 100';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                context,
                                controller: _birthDateController,
                                label: 'Дата рождения',
                                icon: Icons.calendar_today,
                                onTap: () => _selectBirthDate(context),
                                readOnly: true,
                                onChanged: (value) => _updateProfileField('birthDate', value),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    context,
                    value: _currentProfile.gender ?? 'Не указано',
                    label: 'Пол',
                    icon: Icons.person_outline,
                    items: ['Мужской', 'Женский', 'Не указано'],
                    onChanged: (value) {
                      setState(() {
                        _hasChanges = true;
                        _currentProfile = _currentProfile.copyWith(gender: value);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Интересы и образование'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    controller: _interestsController,
                    label: 'Интересы (через запятую)',
                    icon: Icons.interests,
                    maxLines: 3,
                    onChanged: (value) => _updateProfileField('interests', value),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    controller: _educationController,
                    label: 'Образование',
                    icon: Icons.school,
                    onChanged: (value) => _updateProfileField('education', value),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    controller: _professionController,
                    label: 'Профессия',
                    icon: Icons.work,
                    onChanged: (value) => _updateProfileField('profession', value),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    controller: _languagesController,
                    label: 'Языки (через запятую)',
                    icon: Icons.language,
                    onChanged: (value) => _updateProfileField('languages', value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Дополнительная информация'),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            _buildTextField(
                              context,
                              controller: _heightController,
                              label: 'Рост (см)',
                              icon: Icons.height,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateProfileField('height', value),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final height = int.tryParse(value);
                                  if (height == null || height < 100 || height > 250) return 'Введите рост от 100 до 250 см';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              context,
                              controller: _weightController,
                              label: 'Вес (кг)',
                              icon: Icons.monitor_weight,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateProfileField('weight', value),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final weight = int.tryParse(value);
                                  if (weight == null || weight < 30 || weight > 300) return 'Введите вес от 30 до 300 кг';
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                context,
                                controller: _heightController,
                                label: 'Рост (см)',
                                icon: Icons.height,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => _updateProfileField('height', value),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final height = int.tryParse(value);
                                    if (height == null || height < 100 || height > 250) return 'Введите рост от 100 до 250 см';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                context,
                                controller: _weightController,
                                label: 'Вес (кг)',
                                icon: Icons.monitor_weight,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => _updateProfileField('weight', value),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final weight = int.tryParse(value);
                                    if (weight == null || weight < 30 || weight > 300) return 'Введите вес от 30 до 300 кг';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            _buildDropdown(
                              context,
                              value: _currentProfile.hasChildren ?? 'Не указано',
                              label: 'Дети',
                              icon: Icons.child_care,
                              items: ['Есть', 'Нет', 'Не указано'],
                              onChanged: (value) {
                                setState(() {
                                  _hasChanges = true;
                                  _currentProfile = _currentProfile.copyWith(hasChildren: value);
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildDropdown(
                              context,
                              value: _currentProfile.wantsChildren ?? 'Не указано',
                              label: 'Хочет детей',
                              icon: Icons.family_restroom,
                              items: ['Да', 'Нет', 'Не определился(ась)', 'Не указано'],
                              onChanged: (value) {
                                setState(() {
                                  _hasChanges = true;
                                  _currentProfile = _currentProfile.copyWith(wantsChildren: value);
                                });
                              },
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                context,
                                value: _currentProfile.hasChildren ?? 'Не указано',
                                label: 'Дети',
                                icon: Icons.child_care,
                                items: ['Есть', 'Нет', 'Не указано'],
                                onChanged: (value) {
                                  setState(() {
                                    _hasChanges = true;
                                    _currentProfile = _currentProfile.copyWith(hasChildren: value);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                context,
                                value: _currentProfile.wantsChildren ?? 'Не указано',
                                label: 'Хочет детей',
                                icon: Icons.family_restroom,
                                items: ['Да', 'Нет', 'Не определился(ась)', 'Не указано'],
                                onChanged: (value) {
                                  setState(() {
                                    _hasChanges = true;
                                    _currentProfile = _currentProfile.copyWith(wantsChildren: value);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'География'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CountryItem>(
                    value: _selectedCountry,
                    hint: const Text('Выберите страну'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.public),
                      labelText: 'Страна',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    items: countriesList.map((country) {
                      return DropdownMenuItem<CountryItem>(
                        value: country,
                        child: Row(
                          children: [
                            Text(country.flag, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Text(country.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (CountryItem? newValue) {
                      setState(() {
                        _selectedCountry = newValue;
                        _hasChanges = true;
                        _currentProfile = _currentProfile.copyWith(country: newValue?.name);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    controller: _cityController,
                    label: 'Город',
                    icon: Icons.location_city,
                    onChanged: (value) => _updateProfileField('city', value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Мои ценности'),
                  const SizedBox(height: 16),
                  ..._valuesList.map((item) => _buildValueSlider(item)).toList(),
                  const SizedBox(height: 32),
                  _buildActionButtons(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    final hasAvatar = _selectedAvatar != null && _selectedAvatar!.isNotEmpty;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showFavoritesPicker(context),
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeColors.accent(context).withOpacity(0.1),
                    border: Border.all(color: ThemeColors.accent(context), width: 2),
                  ),
                  child: ClipOval(
                    child: hasAvatar
                        ? (_selectedAvatar!.startsWith('assets/')
                        ? Image.asset(_selectedAvatar!, fit: BoxFit.cover)
                        : Image.file(File(_selectedAvatar!), fit: BoxFit.cover))
                        : Icon(Icons.person_add_alt_1, size: 60, color: ThemeColors.accent(context)),
                  ),
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
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showFavoritesPicker(context),
            icon: Icon(Icons.favorite, size: 18, color: ThemeColors.textPrimary(context)),
            label: Text('Выбрать из избранного', style: TextStyle(color: ThemeColors.textPrimary(context))),
            style: TextButton.styleFrom(foregroundColor: ThemeColors.textPrimary(context)),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _pickImageFromSource(context), // ← используем метод с NSFW-проверкой
            icon: const Icon(Icons.photo_library, size: 18),
            label: const Text('Загрузить фото'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColors.textPrimary(context),
              side: BorderSide(color: ThemeColors.accent(context)),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _generateAIAvatar(context),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Создать AI-аватар'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColors.textPrimary(context),
              side: BorderSide(color: ThemeColors.accent(context)),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _setRandomAvatar(),
            icon: const Icon(Icons.casino, size: 18),
            label: const Text('Случайный аватар'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColors.textPrimary(context),
              side: BorderSide(color: ThemeColors.accent(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      BuildContext context, {
        required String value,
        required String label,
        required IconData icon,
        required List<String> items,
        required ValueChanged<String?> onChanged,
      }) {
    final validValue = items.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).iconTheme.color ?? ThemeColors.textSecondary(context),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: ThemeColors.textPrimary(context)),
          ),
        ),
      )
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
      hint: Text(
        'Выберите...',
        style: TextStyle(color: ThemeColors.textHint(context)),
      ),
      validator: (value) {
        if (validValue == null && value == null) {
          return 'Пожалуйста, выберите значение';
        }
        return null;
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.purple,
        ),
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        bool isRequired = false,
        TextInputType? keyboardType,
        int maxLines = 1,
        bool readOnly = false,
        VoidCallback? onTap,
        String? Function(String?)? validator,
        ValueChanged<String>? onChanged,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        labelStyle: TextStyle(color: ThemeColors.textSecondary(context)),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).iconTheme.color ?? ThemeColors.textSecondary(context),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.all(16.0),
      ),
      style: TextStyle(color: ThemeColors.textPrimary(context)),
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeColors.onAccent(context)),
              ),
            )
                : const Icon(Icons.save),
            label: Text(
              _isSaving ? 'Сохранение...' : 'Сохранить изменения',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.accent(context),
              foregroundColor: ThemeColors.onAccent(context),
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSaving
                ? null
                : () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel),
            label: const Text(
              'Отмена',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColors.textSecondary(context),
              side: BorderSide(color: ThemeColors.divider(context)),
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, исправьте ошибки в форме'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final city = _cityController.text.trim();
      if (city.isNotEmpty) {
        _currentProfile = _currentProfile.copyWith(city: city);
      }

      final updatedProfile = _currentProfile.copyWith(
        selectedAvatar: _selectedAvatar,
        completedAt: DateTime.now().toIso8601String(),
        values: _values,
      );

      ProfileService.updateProfile(updatedProfile);

      debugPrint('✅ Профиль сохранен: ${updatedProfile.name}');
      debugPrint('✅ Аватар: ${updatedProfile.selectedAvatar}');

      setState(() {
        _isSaving = false;
        _hasChanges = false;
      });

      Navigator.pop(context, updatedProfile);
      widget.onProfileUpdated?.call(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль успешно сохранен!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      debugPrint('❌ Ошибка при сохранении профиля: $error');
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}