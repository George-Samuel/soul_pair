import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class RealMeetingStage extends StatefulWidget {
  final UserProfile userProfile;
  const RealMeetingStage({super.key, required this.userProfile});

  @override
  State<RealMeetingStage> createState() => _RealMeetingStageState();
}

class _RealMeetingStageState extends State<RealMeetingStage> {
  // Списки кандидатов по полу (расширенные)
  final List<Map<String, dynamic>> _maleCandidates = [
    {
      'name': 'Алексей',
      'age': 28,
      'interests': ['Путешествия', 'Фотография', 'Йога'],
      'compatibility': 87,
      'photo': 'assets/images/hybrid_path/matches/match_alexey.jpg',
      'description': 'Любит активный отдых и творчество',
      'color': Colors.blue,
      'profession': 'Фотограф',
    },
    {
      'name': 'Дмитрий',
      'age': 30,
      'interests': ['Спорт', 'Музыка', 'Технологии'],
      'compatibility': 79,
      'photo': 'assets/images/hybrid_path/matches/match_dmitry.jpg',
      'description': 'Ищет партнёра для совместного развития',
      'color': Colors.green,
      'profession': 'IT-специалист',
    },
    {
      'name': 'Артём',
      'age': 31,
      'interests': ['Пейзажи', 'Горы', 'Закаты'],
      'compatibility': 88,
      'photo': 'assets/images/characters/artem_photographer.jpg',
      'description': 'Вдохновляющий, романтичный, ищет красоту в деталях',
      'color': Colors.amber,
      'profession': 'Фотограф-пейзажист',
    },
    {
      'name': 'Михаил',
      'age': 38,
      'interests': ['Архитектура', 'Черчение', 'Урбанистика'],
      'compatibility': 85,
      'photo': 'assets/images/characters/mikhail_architect.jpg',
      'description': 'Практичный, творческий, ценит гармонию',
      'color': Colors.indigo,
      'profession': 'Архитектор',
    },
    {
      'name': 'Николай',
      'age': 34,
      'interests': ['Психология', 'Книги', 'Настольные игры'],
      'compatibility': 90,
      'photo': 'assets/images/characters/nikolay_psychologist.jpg',
      'description': 'Эмпатичный, внимательный, хороший слушатель',
      'color': Colors.lightBlue,
      'profession': 'Психолог',
    },
    {
      'name': 'Виктор',
      'age': 27,
      'interests': ['Спорт', 'Фитнес', 'ЗОЖ'],
      'compatibility': 83,
      'photo': 'assets/images/characters/viktor_fitness.jpg',
      'description': 'Энергичный, мотивирующий, заботится о здоровье',
      'color': Colors.lime,
      'profession': 'Фитнес-тренер',
    },
    {
      'name': 'Евгений',
      'age': 29,
      'interests': ['AI', 'Робототехника', 'Видеоигры'],
      'compatibility': 86,
      'photo': 'assets/images/characters/evgeny_programmer.jpg',
      'description': 'Интеллектуальный, увлечённый технологиями',
      'color': Colors.cyan,
      'profession': 'AI-программист',
    },
  ];

  final List<Map<String, dynamic>> _femaleCandidates = [
    {
      'name': 'Мария',
      'age': 26,
      'interests': ['Книги', 'Танцы', 'Кулинария'],
      'compatibility': 92,
      'photo': 'assets/images/hybrid_path/matches/match_maria.jpg',
      'description': 'Ценит искренность и чувство юмора',
      'color': Colors.purple,
      'profession': 'Дизайнер',
    },
    {
      'name': 'Элина',
      'age': 29,
      'interests': ['Арт-терапия', 'Медитация', 'Подкасты'],
      'compatibility': 89,
      'photo': 'assets/images/characters/elina_psychotherapist.jpg',
      'description': 'Эмпатичная, проницательная, спокойная',
      'color': Colors.lightBlue,
      'profession': 'Психотерапевт',
    },
    {
      'name': 'Жасмин',
      'age': 34,
      'interests': ['Расследования', 'Журналистика', 'Книги'],
      'compatibility': 82,
      'photo': 'assets/images/characters/jasmine_journalist.jpg',
      'description': 'Настойчивая, принципиальная, любопытная',
      'color': Colors.brown,
      'profession': 'Журналист-расследователь',
    },
    {
      'name': 'Алиса',
      'age': 41,
      'interests': ['Современное искусство', 'Стрит-арт', 'Кураторство'],
      'compatibility': 84,
      'photo': 'assets/images/characters/alisa_art_curator.jpg',
      'description': 'Эксцентричная, авангардная, провокационная',
      'color': Colors.purpleAccent,
      'profession': 'Куратор современного искусства',
    },
    {
      'name': 'Роза',
      'age': 50,
      'interests': ['Навигация', 'Море', 'Путешествия'],
      'compatibility': 88,
      'photo': 'assets/images/characters/roza_yacht_captain.jpg',
      'description': 'Сильная, независимая, мудрая',
      'color': Colors.blue.shade700,
      'profession': 'Капитан парусной яхты',
    },
    {
      'name': 'Мия',
      'age': 23,
      'interests': ['Экология', 'Zero-waste', 'Городской сад'],
      'compatibility': 91,
      'photo': 'assets/images/characters/mia_eco_activist.jpg',
      'description': 'Идеалистка, энергичная, убедительная',
      'color': Colors.green.shade700,
      'profession': 'Эко-активистка',
    },
  ];

  List<Map<String, dynamic>> _potentialMatches = [];
  int _selectedMatchIndex = 0;
  bool _uiVisible = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadMatches();
  }

  void _loadMatches() {
    final userGender = widget.userProfile.gender;
    if (userGender == 'Мужской') {
      _potentialMatches = _femaleCandidates;
    } else if (userGender == 'Женский') {
      _potentialMatches = _maleCandidates;
    } else {
      _potentialMatches = [];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userGender = widget.userProfile.gender;
    if (userGender == null || userGender.isEmpty || userGender == 'Не указано') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Укажите ваш пол в профиле,\nчтобы мы могли подобрать пару',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit_profile', arguments: {
                  'profile': widget.userProfile,
                });
              },
              child: const Text('Перейти в профиль'),
            ),
          ],
        ),
      );
    }

    if (_potentialMatches.isEmpty) {
      return const Center(
        child: Text('К сожалению, пока нет подходящих кандидатов'),
      );
    }

    if (_selectedMatchIndex >= _potentialMatches.length) {
      _selectedMatchIndex = 0;
    }

    final currentMatch = _potentialMatches[_selectedMatchIndex];
    final String currentName = currentMatch['name'] as String;
    final int currentAge = currentMatch['age'] as int;
    final List<String> currentInterests =
    List<String>.from(currentMatch['interests'] as List);
    final int currentCompatibility = currentMatch['compatibility'] as int;
    final String currentPhoto = currentMatch['photo'] as String;
    final String currentDescription = currentMatch['description'] as String;
    final Color currentColor = currentMatch['color'] as Color;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(currentPhoto, fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(_uiVisible ? 0.7 : 0.0),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(_uiVisible ? 0.7 : 0.0),
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, blurRadius: 10),
                  ],
                ),
                child: IconButton(
                  onPressed: () => setState(() => _uiVisible = !_uiVisible),
                  icon: Icon(
                    _uiVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _uiVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        'Потенциальная пара',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _selectedMatchIndex = index),
                        children: _potentialMatches.map((match) {
                          final index = _potentialMatches.indexOf(match);
                          final String name = match['name'] as String;
                          final int age = match['age'] as int;
                          final List<String> interests =
                          (match['interests'] as List).cast<String>();
                          final int compatibility =
                          match['compatibility'] as int;
                          final String photo = match['photo'] as String;
                          final String description =
                          match['description'] as String;
                          final Color color = match['color'] as Color;

                          return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 30,
                                left: 20,
                                top: 10,
                                bottom: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Transform.translate(
                                    offset: const Offset(20, 0),
                                    child: Container(
                                      width: 130,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedMatchIndex == index
                                              ? color
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                            Colors.black.withOpacity(0.5),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(photo,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$age лет',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color:
                                            Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                            Colors.white.withOpacity(0.2),
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'Совместимость: $compatibility%',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.favorite,
                                                  color: Colors.red, size: 20),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          description,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                            Colors.white.withOpacity(0.9),
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 15),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          alignment: WrapAlignment.end,
                                          children:
                                          interests.map<Widget>((interest) {
                                            return Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.3),
                                                borderRadius:
                                                BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                interest,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 25,
                        left: 20,
                        right: 20,
                        top: 10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: currentColor.withOpacity(0.4),
                                        blurRadius: 15,
                                        spreadRadius: 3,
                                      ),
                                      const BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _openChat(context, currentMatch);
                                    },
                                    icon: const Icon(Icons.chat, size: 20),
                                    label: const Text(
                                      'Чат',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: currentColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _showVideoCallConfirmation(
                                          context, currentName);
                                    },
                                    icon: const Icon(Icons.videocam, size: 20),
                                    label: const Text(
                                      'Видео',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.white, width: 1.5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      backgroundColor:
                                      Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  void _openChat(BuildContext context, Map<String, dynamic> match) {
    final name = match['name'] as String;
    final photo = match['photo'] as String;
    final description = match['description'] as String;
    final profession = match['profession'] as String? ?? 'Партнёр';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          characterName: name,
          userProfile: widget.userProfile,
          pathType: 'real_meeting',
          characterImage: photo,
          characterProfession: profession,
          characterPersonality: description,
        ),
      ),
    );
  }

  void _showVideoCallConfirmation(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Видеозвонок с $name пока не реализован'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}