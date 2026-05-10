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

  final List<Map<String, dynamic>> _dataFields = [
    {
      'title': 'Дата рождения',
      'hint': 'Нажмите чтобы выбрать дату',
      'key': 'birth_date',
      'type': 'date_picker',
    },
    {
      'title': 'Ваш пол',
      'hint': 'Выберите пол',
      'key': 'gender',
      'type': 'dropdown',
      'options': ['Мужской', 'Женский'],
    },
    {
      'title': 'Образование',
      'hint': 'Ваш уровень образования',
      'key': 'education',
      'type': 'dropdown',
      'options': ['Среднее', 'Среднее специальное', 'Высшее', 'Ученая степень'],
    },
    {
      'title': 'Профессия',
      'hint': 'Чем вы занимаетесь?',
      'key': 'profession',
      'type': 'dropdown',
      'options': ['Юрист', 'Программист', 'Инженер', 'Врач'],
    },
    {
      'title': 'Интересы и хобби',
      'hint': 'Что вам нравится? (через запятую)',
      'key': 'interests',
      'type': 'dropdown',
      'options': ['Шахматы', 'Ролики', 'Теннис', 'Бег'],
    },
    {
      'title': 'Языки',
      'hint': 'Какими языками владеете? (через запятую)',
      'key': 'languages',
      'type': 'dropdown',
      'options': ['Русский', 'Английский', 'итальянский'],
    },
    {
      'title': 'Рост',
      'hint': 'Выберите рост (см)',
      'key': 'height',
      'type': 'height_dropdown',
    },
    {
      'title': 'Вес',
      'hint': 'Выберите вес (кг)',
      'key': 'weight',
      'type': 'weight_dropdown',
    },
    {
      'title': 'Есть ли у вас дети?',
      'hint': 'Выберите вариант',
      'key': 'has_children',
      'type': 'dropdown',
      'options': ['Да', 'Нет', 'Не хочу говорить'],
    },
    {
      'title': 'Хотите ли детей в будущем?',
      'hint': 'Выберите вариант',
      'key': 'wants_children',
      'type': 'dropdown',
      'options': ['Да', 'Нет', 'Не определился(ась)', 'Уже есть'],
    },
    {
      'title': 'Религия',
      'hint': 'Ваше вероисповедание',
      'key': 'religion',
      'type': 'dropdown',
      'options': [
        'Христианство',
        'Католичество',
        'Протестанство',
        'Ислам',
        'Православие',
        'Буддизм',
        'Иудаизм',
        'Другое',
        'Не указывать'
      ],
    },
    {
      'title': 'Отношение к животным',
      'hint': 'Как вы относитесь к домашним питомцам?',
      'key': 'attitude_to_animals',
      'type': 'dropdown',
      'options': ['Да, люблю животных', 'Нет, не люблю', 'Нейтрально'],
    },
    {
      'title': 'Отношение к курению',
      'hint': 'Ваше отношение к курению',
      'key': 'smoking',
      'type': 'dropdown',
      'options': ['Не курю', 'Курю', 'Нейтрально отношусь'],
    },
    {
      'title': 'Отношение к алкоголю',
      'hint': 'Ваше отношение к алкоголю',
      'key': 'alcohol',
      'type': 'dropdown',
      'options': ['Не пью', 'Пью', 'Нейтрально отношусь'],
    },
  ];

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
        _userData['birth_date'] =
            '${picked.day}.${picked.month}.${picked.year}';
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    final monthDifference = now.month - birthDate.month;

    if (monthDifference < 0 ||
        (monthDifference == 0 && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _submitUserData() {
    final completeProfile = UserProfile.fromMap(_userData);
    ProfileService.updateProfile(completeProfile);
    print(
        '✅ Профиль создан и сохранен в ProfileService: ${completeProfile.name}');
    print('✅ Email: ${completeProfile.email}');
    print('✅ Данные: ${completeProfile.toMap()}');

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.person_search, color: Colors.purple),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Создаём ваш профиль',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Анализируем данные для подбора идеальной пары...',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
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
      hint: Text(
        'Выберите рост',
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      ),
      decoration: InputDecoration(
        hintText: 'Выберите рост (см)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      items: _heightOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            '$value см',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _userData['height'] = value;
          });
        }
      },
    );
  }

  Widget _buildWeightDropdown() {
    final currentValue = _userData['weight']?.toString() ?? '';
    return DropdownButtonFormField<String>(
      value: currentValue.isNotEmpty ? currentValue : null,
      isExpanded: true,
      hint: Text(
        'Выберите вес',
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      ),
      decoration: InputDecoration(
        hintText: 'Выберите вес (кг)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      items: _weightOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            '$value кг',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _userData['weight'] = value;
          });
        }
      },
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    final String fieldKey = field['key'] as String;
    final String fieldType = field['type'] as String;
    final String? fieldHint = field['hint'] as String?;
    final currentValue = _userData[fieldKey] ?? '';

    switch (fieldType) {
      case 'height_dropdown':
        return _buildHeightDropdown();
      case 'weight_dropdown':
        return _buildWeightDropdown();
      case 'dropdown':
        final List<String> options = (field['options'] as List).cast<String>();
        return DropdownButtonFormField<String>(
          value: (currentValue?.toString() ?? '').isNotEmpty
              ? currentValue.toString()
              : null,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: fieldHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _userData[fieldKey] = value;
              });
            }
          },
        );
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
                const Icon(Icons.calendar_month,
                    color: Colors.purple, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}'
                        : (fieldHint ?? 'Нажмите чтобы выбрать'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _selectedDate != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: _selectedDate != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$_calculatedAge лет',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                  size: 24,
                ),
              ],
            ),
          ),
        );
      default:
        return TextFormField(
          controller: TextEditingController(text: currentValue.toString()),
          decoration: InputDecoration(
            hintText: fieldHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            _userData[fieldKey] = value;
          },
        );
    }
  }

  Map<String, dynamic> _getCurrentField() {
    if (_dataFields.isEmpty) {
      return {'title': 'Ошибка', 'key': 'error', 'type': 'text'};
    }
    if (_currentStep < 0) {
      _currentStep = 0;
    } else if (_currentStep >= _dataFields.length) {
      _currentStep = _dataFields.length - 1;
    }
    return _dataFields[_currentStep];
  }

  @override
  Widget build(BuildContext context) {
    final currentField = _getCurrentField();
    final String currentKey = currentField['key'] as String;
    final String currentTitle = currentField['title'] as String;
    final String currentType = currentField['type'] as String;
    final String? currentHint = currentField['hint'] as String?;

    if (currentKey == 'error') {
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: const Center(
          child: Text(
            'Ошибка загрузки формы. Пожалуйста, перезагрузите приложение.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расскажите о себе'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      resizeToAvoidBottomInset: false, // ✅ ИСПРАВЛЕНИЕ ОVERFLOW НА ПЛАНШЕТЕ
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
                Text(
                  '${_currentStep + 1} из ${_dataFields.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                  .copyWith(bottom: 20),
              child: Column(
                children: [
                  Text(
                    currentTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (currentHint != null && currentType != 'date_picker') ...[
                    const SizedBox(height: 8),
                    Text(
                      currentHint,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
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
                          side: BorderSide(color: Colors.purple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Назад',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentKey == 'birth_date' &&
                            _selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Пожалуйста, выберите дату рождения'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        final currentValue = _userData[currentKey];
                        if ((currentValue == null ||
                                currentValue.toString().trim().isEmpty) &&
                            currentKey != 'birth_date') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Пожалуйста, заполните поле "$currentTitle"'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (_currentStep < _dataFields.length - 1) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          _submitUserData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentStep < _dataFields.length - 1
                            ? 'Следующий вопрос'
                            : 'Завершить профиль',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
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
