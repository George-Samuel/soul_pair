import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../widgets/puzzle_progress_widget.dart';
import 'puzzle_complete_screen.dart';

class UserDataCollectionScreen extends StatefulWidget {
  final String userEmail;

  const UserDataCollectionScreen({super.key, required this.userEmail});

  @override
  State<UserDataCollectionScreen> createState() =>
      _UserDataCollectionScreenState();
}

class _UserDataCollectionScreenState extends State<UserDataCollectionScreen> {
  final Map<String, dynamic> _userData = {
    'email': '',
    'birth_date': '',
    'gender': '',
    'education': '',
    'profession': '',
    'interests': '',
    'languages': '',
    'height': '',
    'weight': '',
    'has_children': '',
    'wants_children': '',
    'religion': '',
    'attitude_to_animals': '',
    'smoking': '',
    'alcohol': '',
  };

  int _currentStep = 0;
  DateTime? _selectedDate;
  int? _calculatedAge;

  final List<String> _heightOptions = List.generate(
    13,
        (i) => (150 + i * 5).toString(),
  );
  final List<String> _weightOptions = List.generate(
    23,
        (i) => (40 + i * 5).toString(),
  );

  // ========== СТАТИЧЕСКИЕ РАСШИРЕННЫЕ СПИСКИ ==========
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
    'Русский',
    'Английский',
    'Испанский',
    'Французский',
    'Немецкий',
    'Итальянский',
    'Португальский',
    'Китайский (мандарин)',
    'Японский',
    'Корейский',
    'Арабский',
    'Турецкий',
    'Польский',
    'Украинский',
    'Белорусский',
    'Казахский',
    'Чешский',
    'Греческий',
    'Нидерландский',
    'Шведский',
    'Финский',
    'Венгерский',
    'Иврит',
    'Хинди',
    'Вьетнамский',
  ];

  static final List<String> _languageLevels = [
    'Начальный',
    'Средний',
    'Хороший',
    'Свободный',
    'Родной',
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
    'Православие',
    'Католичество',
    'Протестантизм',
    'Ислам',
    'Иудаизм',
    'Буддизм',
    'Индуизм',
    'Атеизм',
    'Агностицизм',
    'Другое',
    'Не указывать',
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

  // ========== КОНФИГУРАЦИЯ ШАГОВ ФОРМЫ ==========
  final List<Map<String, dynamic>> _dataFields = [
    {'title': 'Дата рождения', 'key': 'birth_date', 'type': 'date_picker'},
    {'title': 'Ваш пол', 'key': 'gender', 'type': 'dropdown', 'options': ['Мужской', 'Женский']},
    {'title': 'Образование', 'key': 'education', 'type': 'dropdown', 'options': _educationOptions},
    {'title': 'Профессия', 'key': 'profession', 'type': 'dropdown', 'options': _professionOptions},
    {'title': 'Интересы и хобби', 'key': 'interests', 'type': 'multi_select', 'items': _interestsList},
    {'title': 'Языки', 'key': 'languages', 'type': 'languages_select'},
    {'title': 'Рост', 'key': 'height', 'type': 'height_dropdown'},
    {'title': 'Вес', 'key': 'weight', 'type': 'weight_dropdown'},
    {'title': 'Есть ли у вас дети?', 'key': 'has_children', 'type': 'dropdown', 'options': _hasChildrenOptions},
    {'title': 'Хотите ли детей в будущем?', 'key': 'wants_children', 'type': 'dropdown', 'options': _wantsChildrenOptions},
    {'title': 'Религия', 'key': 'religion', 'type': 'dropdown', 'options': _religionOptions},
    {'title': 'Отношение к животным', 'key': 'attitude_to_animals', 'type': 'dropdown', 'options': _attitudeToAnimalsOptions},
    {'title': 'Отношение к курению', 'key': 'smoking', 'type': 'dropdown', 'options': _smokingOptions},
    {'title': 'Отношение к алкоголю', 'key': 'alcohol', 'type': 'dropdown', 'options': _alcoholOptions},
  ];

  // Для множественного выбора интересов и языков
  List<String> _selectedInterests = [];
  List<Map<String, String>> _selectedLanguages = [];

  @override
  void initState() {
    super.initState();
    _userData['email'] = widget.userEmail;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculatedAge = _calculateAge(picked);
        _userData['birth_date'] = '${picked.day}.${picked.month}.${picked.year}';
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    final monthDifference = now.month - birthDate.month;
    if (monthDifference < 0 || (monthDifference == 0 && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _submitUserData() {
    _userData['interests'] = _selectedInterests.join(', ');
    _userData['languages'] = _selectedLanguages.map((item) => '${item['language']} (${item['level']})').join(', ');
    final completeProfile = UserProfile.fromMap(_userData);
    ProfileService.updateProfile(completeProfile);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0.95),
      builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.person_search, color: Colors.purple),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Создаём ваш профиль',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 50, width: 50, child: CircularProgressIndicator(strokeWidth: 4, color: Colors.purple)),
              SizedBox(height: 20),
              Text('Анализируем данные для подбора идеальной пары...', style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PuzzleCompleteScreen(
            userProfile: completeProfile,
            puzzleImageAsset: 'assets/images/puzzle/main_puzzle.jpg',
          ),
        ),
      );
    });
  }

  Widget _buildHeightDropdown() {
    final currentValue = _userData['height']?.toString() ?? '';
    return DropdownButtonFormField<String>(
      value: currentValue.isNotEmpty ? currentValue : null,
      isExpanded: true,
      hint: Text('Выберите рост', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
      decoration: InputDecoration(
        hintText: 'Выберите рост (см)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      items: _heightOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text('$value см', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _userData['height'] = value);
      },
    );
  }

  Widget _buildWeightDropdown() {
    final currentValue = _userData['weight']?.toString() ?? '';
    return DropdownButtonFormField<String>(
      value: currentValue.isNotEmpty ? currentValue : null,
      isExpanded: true,
      hint: Text('Выберите вес', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
      decoration: InputDecoration(
        hintText: 'Выберите вес (кг)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      items: _weightOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text('$value кг', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _userData['weight'] = value);
      },
    );
  }

  Widget _buildDropdown(String key, List<String> options) {
    final currentValue = _userData[key]?.toString() ?? '';
    return DropdownButtonFormField<String>(
      value: currentValue.isNotEmpty ? currentValue : null,
      isExpanded: true,
      hint: Text('Выберите вариант', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _userData[key] = value);
      },
    );
  }

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
                    _userData['interests'] = _selectedInterests.join(', ');
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
              onDeleted: () => setState(() => _selectedLanguages.remove(item)),
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
            child: Text('Добавьте языки, чтобы другие знали ваши возможности',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
      ],
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
              onDeleted: () => setState(() => _selectedInterests.remove(interest)),
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
            child: Text('Выберите свои увлечения, чтобы алгоритмы лучше подобрали пару',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
      ],
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    final String fieldKey = field['key'] as String;
    final String fieldType = field['type'] as String;
    switch (fieldType) {
      case 'height_dropdown':
        return _buildHeightDropdown();
      case 'weight_dropdown':
        return _buildWeightDropdown();
      case 'dropdown':
        final List<String> options = (field['options'] as List).cast<String>();
        return _buildDropdown(fieldKey, options);
      case 'date_picker':
        return GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.purple, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}'
                        : (field['hint'] as String? ?? 'Нажмите чтобы выбрать'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _selectedDate != null ? FontWeight.w500 : FontWeight.normal,
                      color: _selectedDate != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: Text('$_calculatedAge лет', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: Theme.of(context).iconTheme.color?.withOpacity(0.7), size: 24),
              ],
            ),
          ),
        );
      case 'multi_select':
        return _buildInterestsWidget();
      case 'languages_select':
        return _buildLanguagesWidget();
      default:
        return const SizedBox.shrink();
    }
  }

  Map<String, dynamic> _getCurrentField() {
    if (_dataFields.isEmpty) return {'title': 'Ошибка', 'key': 'error', 'type': 'text'};
    if (_currentStep < 0) _currentStep = 0;
    if (_currentStep >= _dataFields.length) _currentStep = _dataFields.length - 1;
    return _dataFields[_currentStep];
  }

  @override
  Widget build(BuildContext context) {
    final currentField = _getCurrentField();
    final String currentKey = currentField['key'] as String;
    final String currentTitle = currentField['title'] as String;
    final String currentType = currentField['type'] as String;

    if (currentKey == 'error') {
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: const Center(child: Text('Ошибка загрузки формы. Пожалуйста, перезагрузите приложение.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расскажите о себе'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          PuzzleProgressWidget(
            currentStep: _currentStep,
            totalSteps: _dataFields.length,
            imageAsset: 'assets/images/puzzle/main_puzzle.jpg',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _dataFields.length,
                  backgroundColor: Theme.of(context).dividerColor,
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text('${_currentStep + 1} из ${_dataFields.length}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 20),
              child: Column(
                children: [
                  Text(currentTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2), textAlign: TextAlign.center),
                  if (currentType != 'date_picker' && currentType != 'multi_select' && currentType != 'languages_select')
                    ...[
                      const SizedBox(height: 8),
                      Text(currentField['hint'] as String? ?? 'Выберите вариант',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                          textAlign: TextAlign.center),
                    ],
                  const SizedBox(height: 24),
                  _buildField(currentField),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                            if (_currentStep < 0) _currentStep = 0;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.purple),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Назад', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentKey == 'birth_date' && _selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пожалуйста, выберите дату рождения'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        if (currentKey == 'interests' && _selectedInterests.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пожалуйста, выберите хотя бы один интерес'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        if (currentKey == 'languages' && _selectedLanguages.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Добавьте хотя бы один язык'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        if (currentType == 'dropdown') {
                          final currentValue = _userData[currentKey];
                          if (currentValue == null || currentValue.toString().trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Пожалуйста, заполните поле "$currentTitle"'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                        }
                        if (_currentStep < _dataFields.length - 1) {
                          setState(() => _currentStep++);
                        } else {
                          _submitUserData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_currentStep < _dataFields.length - 1 ? 'Следующий вопрос' : 'Завершить профиль',
                          style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}