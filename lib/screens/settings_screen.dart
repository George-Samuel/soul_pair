import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../main.dart';
import '../utils/theme_colors.dart';
import 'email_registration_screen.dart';
import '../services/profile_service.dart';
import '../services/chat_history_service.dart';
import '../services/user_manager.dart';
import 'user_selector_screen.dart';
import 'test_filter_screen.dart';
import 'admin_panel_screen.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile)? onProfileUpdated;

  const SettingsScreen({
    super.key,
    required this.userProfile,
    this.onProfileUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProfile _editedProfile;
  final _formKey = GlobalKey<FormState>();
  final List<String> _selectedTraits = [];
  late ThemeMode _currentThemeMode;

  @override
  void initState() {
    super.initState();
    _editedProfile = widget.userProfile;
    _selectedTraits.addAll(_editedProfile.personalityTraits);
    _currentThemeMode = appState?.themeMode ?? ThemeMode.system;
    _refreshProfileFromServer();
  }

  Future<void> _refreshProfileFromServer() async {
    try {
      final profileMap = await ApiService.fetchProfile(_editedProfile.id);
      if (profileMap != null) {
        var freshProfile = UserProfile.fromMap(profileMap);
        // Принудительный админ для george (при необходимости)
        if (freshProfile.id == 'george_at_gmail_dot_com') {
          freshProfile = freshProfile.copyWith(isAdmin: true);
        }
        setState(() {
          _editedProfile = freshProfile;
          _selectedTraits.clear();
          _selectedTraits.addAll(freshProfile.personalityTraits);
        });
      }
    } catch (e) {
      print('Ошибка обновления профиля с сервера: $e');
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _editedProfile = _editedProfile.copyWith(personalityTraits: _selectedTraits);
      ProfileService.updateProfile(_editedProfile);
      if (widget.onProfileUpdated != null) widget.onProfileUpdated!(_editedProfile);
      Navigator.pop(context);
    }
  }

  void _handleThemeChange(ThemeMode? mode) {
    if (mode == null) return;
    setState(() => _currentThemeMode = mode);
    appState?.changeTheme(mode);
  }

  void _showTelegramDialog() {
    const channelLink = 'https://t.me/soul_pair_news';
    const channelUsername = '@soul_pair_news';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📢 Наш Telegram-канал'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Подписывайтесь, чтобы быть в курсе новостей и обновлений.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ThemeColors.divider(context)),
              ),
              child: SelectableText(
                channelUsername,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: channelLink));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ссылка скопирована!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Скопировать ссылку'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    const botUsername = '@soul_pair_support_bot';
    const botLink = 'https://t.me/soul_pair_support_bot';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🛟 Поддержка Soul Pair'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Задайте вопрос нашему боту поддержки.'),
            const Text('Он ответит на частые вопросы или передаст сообщение оператору.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ThemeColors.divider(context)),
              ),
              child: SelectableText(
                botUsername,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: botLink));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ссылка на бота скопирована!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Скопировать ссылку'),
          ),
        ],
      ),
    );
  }

  void _showTraitSelectionDialog() {
    final availableTraits = [
      'Активный', 'Энергичный', 'Творческий', 'Чувственный', 'Любознательный',
      'Аналитичный', 'Авантюрный', 'Открытый', 'Вдумчивый', 'Эрудированный',
      'Заботливый', 'Натуральный', 'Коммуникабельный', 'Дружелюбный', 'Искренний',
      'Гостеприимный', 'Спокойный', 'Целеустремленный', 'Ответственный', 'Оптимистичный'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Выберите черты характера'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: availableTraits.map((trait) {
                  return CheckboxListTile(
                    title: Text(trait),
                    value: _selectedTraits.contains(trait),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedTraits.add(trait);
                        } else {
                          _selectedTraits.remove(trait);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  this.setState(() {});
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: const Text(
          'Все ваши данные (профиль, фото, настройки) будут удалены без возможности восстановления.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ProfileService.reset();
              await ChatHistoryService.clearAll();
              appState?.changeTheme(ThemeMode.system);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const EmailRegistrationScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSafeDropdown({
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
        prefixIcon: Icon(icon, color: ThemeColors.accent(context)),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
      hint: const Text('Выберите...'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки профиля'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Оформление
            _buildSection(
              title: '🎨 Оформление',
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Светлая тема'),
                  value: ThemeMode.light,
                  groupValue: _currentThemeMode,
                  onChanged: _handleThemeChange,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Тёмная тема'),
                  value: ThemeMode.dark,
                  groupValue: _currentThemeMode,
                  onChanged: _handleThemeChange,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Системная тема'),
                  value: ThemeMode.system,
                  groupValue: _currentThemeMode,
                  onChanged: _handleThemeChange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Обратная связь
            _buildSection(
              title: '📢 Обратная связь',
              children: [
                ListTile(
                  leading: const Icon(Icons.telegram, color: Colors.blue),
                  title: const Text('Telegram-канал'),
                  subtitle: const Text('Новости, обновления, ответы на вопросы'),
                  onTap: _showTelegramDialog,
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.support_agent, color: Colors.purple),
                  title: const Text('Поддержка'),
                  subtitle: const Text('Задать вопрос боту'),
                  onTap: _showSupportDialog,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Модерация
            _buildSection(
              title: '🛡️ Модерация и безопасность',
              children: [
                ListTile(
                  leading: const Icon(Icons.filter_alt, color: Colors.purple),
                  title: const Text('Проверить текст'),
                  subtitle: const Text('Тест фильтра мата и недопустимых выражений'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TestFilterScreen()),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Основная информация
            _buildSection(
              title: '👤 Основная информация',
              children: [
                TextFormField(
                  initialValue: _editedProfile.name,
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value!.isEmpty ? 'Введите имя' : null,
                  onSaved: (value) => _editedProfile = _editedProfile.copyWith(name: value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _editedProfile.age?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Возраст',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final age = int.tryParse(value);
                      if (age == null || age < 18 || age > 100) return 'Введите возраст от 18 до 100';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      _editedProfile = _editedProfile.copyWith(age: int.tryParse(value));
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSafeDropdown(
                  value: _editedProfile.gender,
                  label: 'Пол',
                  icon: Icons.transgender,
                  items: ['Мужской', 'Женский', 'Не указывать'],
                  onChanged: (value) => setState(() {
                    _editedProfile = _editedProfile.copyWith(gender: value);
                  }),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _editedProfile.birthDate,
                  decoration: const InputDecoration(
                    labelText: 'Дата рождения (ДД.ММ.ГГГГ)',
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  onSaved: (value) => _editedProfile = _editedProfile.copyWith(birthDate: value),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Образование и работа
            _buildSection(
              title: '🎓 Образование и работа',
              children: [
                TextFormField(
                  initialValue: _editedProfile.education,
                  decoration: const InputDecoration(
                    labelText: 'Образование',
                    prefixIcon: Icon(Icons.school),
                  ),
                  onSaved: (value) => _editedProfile = _editedProfile.copyWith(education: value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _editedProfile.profession,
                  decoration: const InputDecoration(
                    labelText: 'Профессия',
                    prefixIcon: Icon(Icons.work),
                  ),
                  onSaved: (value) => _editedProfile = _editedProfile.copyWith(profession: value),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Интересы и хобби
            _buildSection(
              title: '🎯 Интересы и хобби',
              children: [
                TextFormField(
                  initialValue: _editedProfile.interests,
                  decoration: const InputDecoration(
                    labelText: 'Интересы (через запятую)',
                    hintText: 'Спорт, музыка, путешествия...',
                    prefixIcon: Icon(Icons.interests),
                  ),
                  maxLines: 3,
                  onSaved: (value) => _editedProfile = _editedProfile.copyWith(interests: value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _editedProfile.languages,
                  decoration: const InputDecoration(
                    labelText: 'Знание языков',
                    hintText: 'Русский, Английский...',
                    prefixIcon: Icon(Icons.language),
                  ),
                  onSaved: (value) => _editedProfile = _editedProfile.copyWith(languages: value),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Физические параметры
            _buildSection(
              title: '📏 Физические параметры',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _editedProfile.height,
                        decoration: const InputDecoration(
                          labelText: 'Рост (см)',
                          prefixIcon: Icon(Icons.height),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (value) => _editedProfile = _editedProfile.copyWith(height: value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _editedProfile.weight,
                        decoration: const InputDecoration(
                          labelText: 'Вес (кг)',
                          prefixIcon: Icon(Icons.monitor_weight),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (value) => _editedProfile = _editedProfile.copyWith(weight: value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Жизненные ценности
            _buildSection(
              title: '💖 Жизненные ценности',
              children: [
                _buildSafeDropdown(
                  value: _editedProfile.hasChildren,
                  label: 'Есть дети?',
                  icon: Icons.child_care,
                  items: ['Да', 'Нет', 'Не указывать'],
                  onChanged: (value) => setState(() {
                    _editedProfile = _editedProfile.copyWith(hasChildren: value);
                  }),
                ),
                const SizedBox(height: 12),
                _buildSafeDropdown(
                  value: _editedProfile.wantsChildren,
                  label: 'Хотите детей?',
                  icon: Icons.family_restroom,
                  items: ['Да', 'Нет', 'Не определился(ась)', 'Не указывать'],
                  onChanged: (value) => setState(() {
                    _editedProfile = _editedProfile.copyWith(wantsChildren: value);
                  }),
                ),
                const SizedBox(height: 12),
                _buildSafeDropdown(
                  value: _editedProfile.religion,
                  label: 'Религия',
                  icon: Icons.temple_buddhist,
                  items: [
                    'Христианство', 'Православие', 'Ислам', 'Буддизм',
                    'Иудаизм', 'Атеизм', 'Не указывать'
                  ],
                  onChanged: (value) => setState(() {
                    _editedProfile = _editedProfile.copyWith(religion: value);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Отношение к вредным привычкам
            _buildSection(
              title: '🚭 Отношение к вредным привычкам',
              children: [
                _buildSafeDropdown(
                  value: _editedProfile.smoking,
                  label: 'Курение',
                  icon: Icons.smoking_rooms,
                  items: ['Курю', 'Не курю', 'Иногда', 'Не указывать'],
                  onChanged: (value) => setState(() {
                    _editedProfile = _editedProfile.copyWith(smoking: value);
                  }),
                ),
                const SizedBox(height: 12),
                _buildSafeDropdown(
                  value: _editedProfile.alcohol,
                  label: 'Алкоголь',
                  icon: Icons.local_bar,
                  items: ['Пью', 'Не пью', 'Иногда', 'Не указывать'],
                  onChanged: (value) => setState(() {
                    _editedProfile = _editedProfile.copyWith(alcohol: value);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Черты характера
            _buildSection(
              title: '🧠 Черты характера',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTraits.map((trait) {
                    return Chip(
                      label: Text(trait),
                      onDeleted: () {
                        setState(() => _selectedTraits.remove(trait));
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _showTraitSelectionDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить черты характера'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Автоматически сгенерированные черты:',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.textSecondary(context),
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _editedProfile.autoGeneratedTraits.map((trait) {
                    return Chip(
                      label: Text(
                        trait,
                        style: TextStyle(color: ThemeColors.textPrimary(context)),
                      ),
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Отношение к животным
            _buildSection(
              title: '🐕 Отношение к животным',
              children: [
                _buildSafeDropdown(
                  value: _editedProfile.attitudeToAnimals,
                  label: 'Как относитесь к животным?',
                  icon: Icons.pets,
                  items: ['Люблю животных', 'Нейтрально', 'Не люблю', 'Не указывать'],
                  onChanged: (value) => setState(() {
                    _editedProfile = _editedProfile.copyWith(attitudeToAnimals: value);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Статистика
            Card(
              color: isDark ? Colors.grey[850] : Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Статистика профиля',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _editedProfile.profileCompletion,
                      backgroundColor: ThemeColors.divider(context),
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Заполнение: ${(_editedProfile.profileCompletion * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Черты характера: ${_editedProfile.allPersonalityTraits.length}',
                          style: TextStyle(color: ThemeColors.textPrimary(context)),
                        ),
                        Text(
                          'Возраст: ${_editedProfile.age ?? _editedProfile.calculatedAge ?? "Не указан"}',
                          style: TextStyle(color: ThemeColors.textPrimary(context)),
                        ),
                      ],
                    ),
                    if (_editedProfile.zodiacSign.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Знак зодиака: ${_editedProfile.zodiacSign}',
                        style: TextStyle(color: ThemeColors.textPrimary(context)),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // АДМИН-ПАНЕЛЬ (только для администратора)
            if (_editedProfile.id == 'george_at_gmail_dot_com' || _editedProfile.isAdmin) ...[
              const SizedBox(height: 24),
              _buildSection(
                title: '🔧 Администрирование',
                children: [
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                    title: const Text('Панель администратора'),
                    subtitle: const Text('Управление пользователями, жалобы, модерация'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Кнопки действий
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text('Сохранить все изменения'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Сбросить настройки'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text('Экспорт данных профиля'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _confirmDeleteAccount(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Удалить аккаунт'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Сменить пользователя'),
                  onTap: () async {
                    await UserManager.switchToUser(null);
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const UserSelectorScreen()),
                      );
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}