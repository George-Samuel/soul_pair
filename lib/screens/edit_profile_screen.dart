import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../utils/theme_colors.dart';
import '../services/openrouter_avatar_service.dart';
import '../services/media_service.dart';
import '../services/user_manager.dart';
import '../data/countries.dart';
import '../services/storage_path.dart';
import '../services/favorite_avatars_service.dart';
import '../services/api_service.dart';


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

  // Текстовые контроллеры для простых полей
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _birthDateController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _cityController;

  CountryItem? _selectedCountry;

  // Для множественного выбора
  List<String> _selectedInterests = [];
  List<Map<String, String>> _selectedLanguages = [];
  String? _education;
  String? _profession;
  String? _hasChildren;
  String? _wantsChildren;
  String? _religion;
  String? _attitudeToAnimals;
  String? _smoking;
  String? _alcohol;

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

  // Расширенные списки (статически)
  static final List<String> _educationOptions = [
    'Нет образования',
    'Неполное среднее (9 классов)',
    'Среднее (11 классов)',
    'Среднее специальное (колледж, техникум)',
    'Неоконченное высшее',
    'Высшее (бакалавр)',
    'Высшее (магистр / специалист)',
    'Ученая степень (кандидат / доктор наук)',
    'Два и более высших образований',
    'Еще учусь',
    'Свой вариант',
  ];

  static final List<String> _professionOptions = [
    'Программист, разработчик',
    'Системный администратор',
    'Специалист в области ИТ и связи',
    'Специалист в области интернет-маркетинга, SEO, SMM',
    'Дизайнер (графический, веб-дизайн, UI/UX)',
    'Аналитик данных',
    'Специалист по информационной безопасности',
    'Врач',
    'Медицинская сестра / Медбрат',
    'Ученый, исследователь',
    'Фармацевт',
    'Психолог',
    'Ветеринар',
    'Преподаватель, учитель',
    'Юрист, адвокат',
    'HR-менеджер, специалист по подбору персонала',
    'PR-менеджер, специалист по связям с общественностью',
    'Бухгалтер',
    'Экономист, финансист',
    'Банковский служащий',
    'Библиотекарь',
    'Социальный работник',
    'Художник, арт-директор',
    'Музыкант, композитор',
    'Артист театра и кино',
    'Актер или актриса',
    'Журналист, редактор',
    'Писатель, поэт, сценарист',
    'Фотограф, видеооператор',
    'Архитектор',
    'Другое',
    'Не работаю',
  ];

  static final List<String> _interestsList = [
    'Спорт (бег, фитнес, тренажёрный зал)',
    'Командные виды спорта (футбол, волейбол, баскетбол)',
    'Единоборства (бокс, борьба, карате)',
    'Йога, медитация',
    'Танцы',
    'Велоспорт',
    'Плавание',
    'Лыжи, сноуборд',
    'Туризм, походы',
    'Экстремальные виды спорта',
    'Рисование, живопись',
    'Музыка (игра на инструментах)',
    'Пение, вокал',
    'Фотография',
    'Видеомонтаж',
    'Рукоделие (вязание, вышивание)',
    'Скрапбукинг, создание открыток',
    'Писательство, литературное творчество',
    'Театр, актёрское мастерство',
    'Каллиграфия',
    'Чтение книг',
    'Изучение иностранных языков',
    'Психология, саморазвитие',
    'Научно-популярная литература',
    'История',
    'Астрономия',
    'Программирование, IT',
    'Робототехника',
    'Шахматы, логические игры',
    'Настольные игры',
    'Кулинария, приготовление еды',
    'Выпечка, кондитерское искусство',
    'Садоводство, огородничество',
    'Дизайн интерьера',
    'Флористика',
    'Путешествия',
    'Посещение кино, театров, выставок',
    'Видеоигры, компьютерные игры',
    'Общение с друзьями',
    'Блогинг, ведение соцсетей',
    'Караоке',
    'Посещение концертов, фестивалей',
    'Рестораны, кафе',
    'Животные (уход, воспитание)',
    'Природа, экология',
    'Аквариумистика',
  ];

  static final List<String> _languagesList = [
    'Русский', 'Английский', 'Испанский', 'Французский', 'Немецкий',
    'Итальянский', 'Португальский', 'Китайский (мандарин)', 'Японский',
    'Корейский', 'Арабский', 'Турецкий', 'Польский', 'Украинский',
    'Белорусский', 'Казахский', 'Чешский', 'Греческий', 'Нидерландский',
    'Шведский', 'Финский', 'Венгерский', 'Иврит', 'Хинди', 'Вьетнамский',
  ];

  static final List<String> _languageLevels = [
    'Начальный', 'Средний', 'Хороший', 'Свободный', 'Родной'
  ];

  static final List<String> _hasChildrenOptions = [
    'Да, есть дети',
    'Да, уже взрослые',
    'Нет',
    'Не хочу говорить',
  ];

  static final List<String> _wantsChildrenOptions = [
    'Да, хочу',
    'Нет, не хочу',
    'Не определился(ась)',
    'Уже есть, больше не планирую',
    'Не хочу говорить',
  ];

  static final List<String> _religionOptions = [
    'Православие', 'Католичество', 'Протестантизм', 'Ислам', 'Иудаизм',
    'Буддизм', 'Индуизм', 'Атеизм', 'Агностицизм', 'Другое', 'Не указывать',
  ];

  static final List<String> _attitudeToAnimalsOptions = [
    'Да, люблю животных',
    'У меня есть домашние питомцы',
    'Нейтрально',
    'Затрудняюсь ответить / Не задумывался',
    'Нет, не люблю',
    'Мне нравятся только некоторые виды животных (например, кошки, но не собаки)',
    'Предпочитаю не говорить',
  ];

  static final List<String> _smokingOptions = [
    'Не курю и не переношу табачный дым',
    'Не курю, но отношусь нейтрально',
    'Курю редко (по праздникам, в компаниях)',
    'Курю регулярно',
    'Пытаюсь бросить',
    'Нейтрально, курение партнёра не имеет значения',
    'Не хочу отвечать',
  ];

  static final List<String> _alcoholOptions = [
    'Не пью вообще',
    'Не пью',
    'Не пью, но отношусь спокойно',
    'Редко (по праздникам)',
    'Пью в компании (умеренно)',
    'Пью',
    'Не хочу отвечать',
  ];

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

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.initialProfile;
    _selectedAvatar = _currentProfile.selectedAvatar;

    _nameController = TextEditingController(text: _currentProfile.name);
    _emailController = TextEditingController(text: _currentProfile.email);
    _ageController = TextEditingController(text: _currentProfile.age?.toString() ?? '');
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

    // Загружаем выбранные интересы из строки
    if (_currentProfile.interests != null && _currentProfile.interests!.isNotEmpty) {
      _selectedInterests = _currentProfile.interests!.split(',').map((e) => e.trim()).toList();
    }
    // Загружаем языки из строки формата "Русский (Родной), Английский (Свободный)"
    if (_currentProfile.languages != null && _currentProfile.languages!.isNotEmpty) {
      final parts = _currentProfile.languages!.split(',');
      for (var part in parts) {
        final match = RegExp(r'^(.*?)\s*\((.*?)\)$').firstMatch(part.trim());
        if (match != null) {
          _selectedLanguages.add({
            'language': match.group(1)!,
            'level': match.group(2)!,
          });
        } else {
          // fallback: без уровня
          _selectedLanguages.add({'language': part.trim(), 'level': 'Средний'});
        }
      }
    }

    // Загружаем значения из выпадающих списков
    _education = _currentProfile.education;
    _profession = _currentProfile.profession;
    _hasChildren = _currentProfile.hasChildren;
    _wantsChildren = _currentProfile.wantsChildren;
    _religion = _currentProfile.religion;
    _attitudeToAnimals = _currentProfile.attitudeToAnimals;
    _smoking = _currentProfile.smoking;
    _alcohol = _currentProfile.alcohol;

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

  // ===== МЕТОДЫ ДЛЯ ВЫБОРА ИНТЕРЕСОВ И ЯЗЫКОВ =====
  Future<void> _showInterestsDialog() async {
    List<String> tempSelected = List.from(_selectedInterests);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Выберите интересы и хобби'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView(
                children: _interestsList.map((interest) {
                  return CheckboxListTile(
                    title: Text(interest),
                    value: tempSelected.contains(interest),
                    onChanged: (value) {
                      setStateDialog(() {
                        if (value == true) {
                          tempSelected.add(interest);
                        } else {
                          tempSelected.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedInterests = tempSelected;
                    _hasChanges = true;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showLanguageDialog() async {
    String? selectedLanguage;
    String? selectedLevel;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              hint: const Text('Выберите язык'),
              items: _languagesList.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
              onChanged: (value) => selectedLanguage = value,
              decoration: const InputDecoration(labelText: 'Язык', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedLevel,
              hint: const Text('Уровень владения'),
              items: _languageLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
              onChanged: (value) => selectedLevel = value,
              decoration: const InputDecoration(labelText: 'Уровень', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (selectedLanguage != null && selectedLevel != null) {
                setState(() {
                  _selectedLanguages.add({'language': selectedLanguage!, 'level': selectedLevel!});
                  _hasChanges = true;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._selectedInterests.map((interest) => Chip(
              label: Text(interest),
              onDeleted: () => setState(() {
                _selectedInterests.remove(interest);
                _hasChanges = true;
              }),
            )),
            ActionChip(
              label: const Text('+ Выбрать интересы'),
              onPressed: _showInterestsDialog,
              avatar: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
        if (_selectedInterests.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('Выберите свои увлечения',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
      ],
    );
  }

  Widget _buildLanguagesWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._selectedLanguages.map((item) => Chip(
              label: Text('${item['language']} (${item['level']})'),
              onDeleted: () => setState(() {
                _selectedLanguages.remove(item);
                _hasChanges = true;
              }),
            )),
            ActionChip(
              label: const Text('+ Добавить язык'),
              onPressed: _showLanguageDialog,
              avatar: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
        if (_selectedLanguages.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('Добавьте языки',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
      ],
    );
  }

  // ===== ОСТАЛЬНЫЕ МЕТОДЫ =====
  Future<void> _generateAIAvatar(BuildContext context) async {
    final profile = _currentProfile;
    final genderText = profile.gender == 'Мужской' ? 'мужчины' : 'женщины';
    final ageText = profile.age ?? profile.calculatedAge;
    final ageString = ageText != null ? '$ageText лет' : '';
    final profession = profile.profession ?? '';
    // 🆕 Берём интересы из _selectedInterests, а не из profile.interests
    final interests = _selectedInterests.isNotEmpty ? _selectedInterests.join(', ') : (profile.interests ?? '');

    String prompt = 'Реалистичный портрет $genderText';
    if (ageString.isNotEmpty) prompt += ', $ageString';
    if (profession.isNotEmpty) prompt += ', $profession';
    if (interests.isNotEmpty) prompt += ', интересы: $interests';
    prompt += ', европеец(ка), фотографическое качество, нейтральный фон, дружелюбное выражение лица';

    // Показываем диалог загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imageBytes = await OpenRouterAvatarService.generateAvatar(prompt);
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
      Navigator.pop(context); // закрываем индикатор
      _askAddToFavorites(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✨ AI-аватар создан!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      Navigator.pop(context); // закрываем индикатор
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickImageFromSource(BuildContext context) async {
    final String? savedPath = await MediaService.showImageSourceDialog(context);
    if (savedPath == null) return;

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
      Navigator.pop(context);
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
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      _birthDateController.text = formattedDate;
      setState(() {
        _currentProfile = _currentProfile.copyWith(birthDate: formattedDate);
        _hasChanges = true;
      });
    }
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
          title: Text('Редактирование профиля', style: TextStyle(color: ThemeColors.onAccent(context))),
          actions: [
            IconButton(
              icon: _isSaving
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.onAccent(context)),
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
                    controller: _nameController,
                    label: 'Имя',
                    icon: Icons.person,
                    isRequired: true,
                    onChanged: (value) => _markChanges('name', value),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Введите имя';
                      if (value.length < 2) return 'Имя слишком короткое';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    onChanged: (value) => _markChanges('email', value),
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
                              controller: _ageController,
                              label: 'Возраст',
                              icon: Icons.cake,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final age = int.tryParse(value);
                                if (age != null) {
                                  setState(() {
                                    _currentProfile = _currentProfile.copyWith(age: age);
                                    _hasChanges = true;
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
                              controller: _birthDateController,
                              label: 'Дата рождения (дд.мм.гггг)',
                              icon: Icons.calendar_today,
                              onTap: () => _selectBirthDate(context),
                              readOnly: true,
                              onChanged: (value) => _markChanges('birthDate', value),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _ageController,
                                label: 'Возраст',
                                icon: Icons.cake,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final age = int.tryParse(value);
                                  if (age != null) {
                                    setState(() {
                                      _currentProfile = _currentProfile.copyWith(age: age);
                                      _hasChanges = true;
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
                                controller: _birthDateController,
                                label: 'Дата рождения',
                                icon: Icons.calendar_today,
                                onTap: () => _selectBirthDate(context),
                                readOnly: true,
                                onChanged: (value) => _markChanges('birthDate', value),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _currentProfile.gender ?? 'Не указано',
                    label: 'Пол',
                    icon: Icons.person_outline,
                    items: ['Мужской', 'Женский', 'Не указано'],
                    onChanged: (value) {
                      setState(() {
                        _currentProfile = _currentProfile.copyWith(gender: value);
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Интересы и образование'),
                  const SizedBox(height: 16),
                  _buildInterestsWidget(),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _education,
                    label: 'Образование',
                    icon: Icons.school,
                    items: _educationOptions,
                    onChanged: (value) {
                      setState(() {
                        _education = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _profession,
                    label: 'Профессия',
                    icon: Icons.work,
                    items: _professionOptions,
                    onChanged: (value) {
                      setState(() {
                        _profession = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildLanguagesWidget(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Дополнительная информация'),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            _buildTextField(
                              controller: _heightController,
                              label: 'Рост (см)',
                              icon: Icons.height,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _markChanges('height', value),
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
                              controller: _weightController,
                              label: 'Вес (кг)',
                              icon: Icons.monitor_weight,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _markChanges('weight', value),
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
                                controller: _heightController,
                                label: 'Рост (см)',
                                icon: Icons.height,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => _markChanges('height', value),
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
                                controller: _weightController,
                                label: 'Вес (кг)',
                                icon: Icons.monitor_weight,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => _markChanges('weight', value),
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
                  _buildDropdown(
                    value: _hasChildren,
                    label: 'Есть ли у вас дети?',
                    icon: Icons.child_care,
                    items: _hasChildrenOptions,
                    onChanged: (value) {
                      setState(() {
                        _hasChildren = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _wantsChildren,
                    label: 'Хотите ли детей в будущем?',
                    icon: Icons.family_restroom,
                    items: _wantsChildrenOptions,
                    onChanged: (value) {
                      setState(() {
                        _wantsChildren = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _religion,
                    label: 'Религия',
                    icon: Icons.temple_buddhist,
                    items: _religionOptions,
                    onChanged: (value) {
                      setState(() {
                        _religion = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _attitudeToAnimals,
                    label: 'Отношение к животным',
                    icon: Icons.pets,
                    items: _attitudeToAnimalsOptions,
                    onChanged: (value) {
                      setState(() {
                        _attitudeToAnimals = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _smoking,
                    label: 'Отношение к курению',
                    icon: Icons.smoke_free,
                    items: _smokingOptions,
                    onChanged: (value) {
                      setState(() {
                        _smoking = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _alcohol,
                    label: 'Отношение к алкоголю',
                    icon: Icons.local_bar,
                    items: _alcoholOptions,
                    onChanged: (value) {
                      setState(() {
                        _alcohol = value;
                        _hasChanges = true;
                      });
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
                    controller: _cityController,
                    label: 'Город',
                    icon: Icons.location_city,
                    onChanged: (value) => _markChanges('city', value),
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

  void _markChanges(String field, String value) {
    setState(() {
      _hasChanges = true;
      switch (field) {
        case 'name':
          _currentProfile = _currentProfile.copyWith(name: value);
          break;
        case 'email':
          _currentProfile = _currentProfile.copyWith(email: value);
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
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _pickImageFromSource(context),
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

  Widget _buildDropdown({
    required String? value,
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
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color ?? ThemeColors.textSecondary(context)),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      isExpanded: true,
      hint: Text('Выберите...', style: TextStyle(color: ThemeColors.textHint(context))),
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

  Widget _buildTextField({
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
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color ?? ThemeColors.textSecondary(context)),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.onAccent(context)),
              ),
            )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Сохранение...' : 'Сохранить изменения', style: const TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.accent(context),
              foregroundColor: ThemeColors.onAccent(context),
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
            label: const Text('Отмена', style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColors.textSecondary(context),
              side: BorderSide(color: ThemeColors.divider(context)),
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
        const SnackBar(content: Text('Пожалуйста, исправьте ошибки в форме'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final city = _cityController.text.trim();
      final updatedProfile = _currentProfile.copyWith(
        selectedAvatar: _selectedAvatar,
        completedAt: DateTime.now().toIso8601String(),
        values: _values,
        education: _education,
        profession: _profession,
        interests: _selectedInterests.join(', '),
        languages: _selectedLanguages.map((item) => '${item['language']} (${item['level']})').join(', '),
        hasChildren: _hasChildren,
        wantsChildren: _wantsChildren,
        religion: _religion,
        attitudeToAnimals: _attitudeToAnimals,
        smoking: _smoking,
        alcohol: _alcohol,
        city: city,
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
        const SnackBar(content: Text('Профиль успешно сохранен!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
      );
    } catch (error) {
      debugPrint('❌ Ошибка при сохранении профиля: $error');
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $error'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
      );
    }
  }
}