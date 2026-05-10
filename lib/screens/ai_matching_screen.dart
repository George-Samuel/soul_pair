import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../utils/theme_colors.dart';
import 'real_chat_screen.dart';
import 'profile_screen.dart';
import 'personality_test_screen.dart';
import 'dart:io';

class AIMatchingScreen extends StatefulWidget {
  final UserProfile userProfile;
  final String pathType;

  const AIMatchingScreen({
    super.key,
    required this.userProfile,
    required this.pathType,
  });

  @override
  State<AIMatchingScreen> createState() => _AIMatchingScreenState();
}

class _AIMatchingScreenState extends State<AIMatchingScreen> {
  List<UserProfile> _allUsers = [];
  List<UserProfile> _filteredUsers = [];
  bool _isLoading = true;
  int _selectedFilter = 0; // 0‑Все, 1‑Идеальные, 2‑Хорошие, 3‑Средние
  String? _selectedTypeFilter; // null = все типы, иначе 'Очаг', 'Активный', 'Авантюрист', 'Проводник'
  Timer? _updateTimer;

  String get _currentUserId => ProfileService.currentProfile?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdate() {
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadUsers(showLoading: false);
    });
  }

  // Гендерная фильтрация
  List<UserProfile> _filterByGender(List<UserProfile> users) {
    final myGender = widget.userProfile.gender;
    if (myGender == null || myGender == 'Не указано') {
      return users;
    }
    final targetGender = myGender == 'Мужской' ? 'Женский' : 'Мужской';
    return users.where((user) {
      return user.gender == targetGender ||
          user.gender == null ||
          user.gender == 'Не указано';
    }).toList();
  }

  Future<void> _loadUsers({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final profilesMap = await ApiService.fetchOtherProfiles(_currentUserId);
      final List<UserProfile> tempUsers = [];
      profilesMap.forEach((key, value) {
        tempUsers.add(UserProfile.fromMap(value as Map<String, dynamic>));
      });
      final users = _filterByGender(tempUsers);
      users.sort((a, b) {
        final compA = UserUtils.calculateCompatibility(widget.userProfile, a);
        final compB = UserUtils.calculateCompatibility(widget.userProfile, b);
        return compB.compareTo(compA);
      });
      setState(() {
        _allUsers = users;
        _applyFilters();
      });
    } catch (e) {
      print('Ошибка загрузки пользователей: $e');
    } finally {
      if (showLoading) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<UserProfile> filtered = List.from(_allUsers);
    // Фильтр по категории совместимости
    switch (_selectedFilter) {
      case 1:
        filtered = filtered.where((u) => UserUtils.calculateCompatibility(widget.userProfile, u) >= 0.8).toList();
        break;
      case 2:
        filtered = filtered.where((u) {
          final comp = UserUtils.calculateCompatibility(widget.userProfile, u);
          return comp >= 0.6 && comp < 0.8;
        }).toList();
        break;
      case 3:
        filtered = filtered.where((u) {
          final comp = UserUtils.calculateCompatibility(widget.userProfile, u);
          return comp >= 0.4 && comp < 0.6;
        }).toList();
        break;
      default:
        break;
    }
    // Фильтр по типу личности
    if (_selectedTypeFilter != null) {
      filtered = filtered.where((u) => u.dominantType == _selectedTypeFilter).toList();
    }
    setState(() {
      _filteredUsers = filtered;
    });
  }

  double _getCompatibility(UserProfile user) {
    return UserUtils.calculateCompatibility(widget.userProfile, user);
  }

  String _getMatchType(double compatibility) {
    if (compatibility >= 0.8) return 'Идеальные';
    if (compatibility >= 0.6) return 'Хорошие';
    return 'Средние';
  }

  Color _getMatchColor(double compatibility) {
    if (compatibility >= 0.8) return Colors.green;
    if (compatibility >= 0.6) return Colors.orange;
    return Colors.blue;
  }

  IconData _getMatchIcon(String matchType) {
    switch (matchType) {
      case 'Идеальные':
        return Icons.emoji_emotions;
      case 'Хорошие':
        return Icons.thumb_up;
      default:
        return Icons.people;
    }
  }

  Widget _buildFilters() {
    const filters = ['Все', 'Идеальные', 'Хорошие', 'Средние'];
    final typeFilters = ['Все типы', 'Очаг', 'Активный', 'Авантюрист', 'Проводник'];

    return Column(
      children: [
        // Первый ряд: фильтры по совместимости
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16 : 8,
                  right: index == filters.length - 1 ? 16 : 8,
                ),
                child: ChoiceChip(
                  label: Text(filters[index]),
                  selected: _selectedFilter == index,
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: _selectedFilter == index
                        ? Colors.white
                        : ThemeColors.textPrimary(context),
                    fontWeight: FontWeight.w500,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = index;
                      _applyFilters();
                    });
                  },
                ),
              );
            },
          ),
        ),
        // Второй ряд: фильтры по типу личности (если пользователь прошёл тест)
        if (widget.userProfile.dominantType != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: typeFilters.length,
              itemBuilder: (context, index) {
                final value = typeFilters[index];
                final isSelected = (index == 0 && _selectedTypeFilter == null) ||
                    (_selectedTypeFilter == value);
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == typeFilters.length - 1 ? 16 : 8,
                  ),
                  child: ChoiceChip(
                    label: Text(value),
                    selected: isSelected,
                    selectedColor: Colors.purple,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : ThemeColors.textPrimary(context),
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedTypeFilter = (index == 0) ? null : value;
                        _applyFilters();
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  String _getEmptyMessage() {
    if (_selectedTypeFilter != null) {
      return 'Нет пользователей с типом «${_selectedTypeFilter}» в выбранной категории.';
    }
    switch (_selectedFilter) {
      case 1:
        return 'К сожалению, на данный момент идеальной пары для вас не нашлось.';
      case 2:
        return 'Хороших совпадений пока нет.';
      case 3:
        return 'Средних совпадений пока нет.';
      default:
        return 'Нет других пользователей.';
    }
  }

  Widget _buildMatchCard(UserProfile user, int index) {
    final compatibility = _getCompatibility(user);
    final matchType = _getMatchType(compatibility);
    final matchColor = _getMatchColor(compatibility);
    final percent = (compatibility * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: matchColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RealChatScreen(
                targetUserId: user.id,
                targetName: user.name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: matchColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: matchColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Hero(
                tag: 'user_avatar_${user.id}',
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: matchColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: user.selectedAvatar != null
                        ? (user.selectedAvatar!.startsWith('assets/')
                        ? Image.asset(user.selectedAvatar!, fit: BoxFit.cover)
                        : Image.file(File(user.selectedAvatar!), fit: BoxFit.cover))
                        : Icon(Icons.person, size: 40, color: matchColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.textPrimary(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          _getMatchIcon(matchType),
                          color: matchColor,
                          size: 24,
                        ),
                      ],
                    ),
                    Text(
                      user.profession ?? 'Профессия не указана',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeColors.textSecondary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: compatibility,
                                backgroundColor: ThemeColors.divider(context),
                                color: matchColor,
                                borderRadius: BorderRadius.circular(10),
                                minHeight: 10,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$percent%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: matchColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          matchType,
                          style: TextStyle(
                            fontSize: 14,
                            color: matchColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (user.dominantType != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.dominantType!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI-Матчинг'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          if (!_isLoading)
            IconButton(
              onPressed: () => _loadUsers(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Обновить',
            ),
          if (widget.userProfile.dominantType != null)
            IconButton(
              icon: const Icon(Icons.replay),
              tooltip: 'Перепройти тест личности',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Перепройти тест?'),
                    content: const Text('Ваш текущий тип личности будет заменён. Продолжить?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Да')),
                    ],
                  ),
                );
                if (confirm == true) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalityTestScreen(userProfile: widget.userProfile),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _selectedFilter = 0;          // сброс фильтра совместимости на "Все"
                      _selectedTypeFilter = null;   // сброс фильтра по типу
                    });
                    _loadUsers();
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 AI нашёл ваши лучшие совпадения',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_filteredUsers.length} из ${_allUsers.length} пользователей',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          _buildFilters(),
          const SizedBox(height: 10),
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _getEmptyMessage(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: ThemeColors.textSecondary(context),
                  ),
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _filteredUsers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _buildMatchCard(_filteredUsers[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }
}