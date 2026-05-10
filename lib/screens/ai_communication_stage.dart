import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import 'chat_screen.dart'; // ← добавляем импорт

class AICommunicationStage extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback? onTrainingComplete;

  const AICommunicationStage({
    super.key,
    required this.userProfile,
    this.onTrainingComplete,
  });

  @override
  State<AICommunicationStage> createState() => _AICommunicationStageState();
}

class _AICommunicationStageState extends State<AICommunicationStage> {
  final List<Map<String, dynamic>> _trainers = [
    {
      'name': 'Анна',
      'title': 'Психолог-тренер',
      'specialty': 'Знакомства и отношения',
      'photo': 'assets/images/hybrid_path/trainers/trainer_anna.jpg',
      'color': Colors.blue,
    },
    {
      'name': 'Максим',
      'title': 'Коуч по коммуникации',
      'specialty': 'Деловое общение',
      'photo': 'assets/images/hybrid_path/trainers/trainer_maxim.jpg',
      'color': Colors.green,
    },
    {
      'name': 'София',
      'title': 'Эксперт по этикету',
      'specialty': 'Светские беседы',
      'photo': 'assets/images/hybrid_path/trainers/trainer_sofia.jpg',
      'color': Colors.purple,
    },
  ];

  int _selectedTrainerIndex = 0;
  bool _uiVisible = true;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: _buildTrainerSelection(),
    );
  }

  Widget _buildTrainerSelection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Фон – фото выбранного тренера
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset(
                _trainers[_selectedTrainerIndex]['photo'] as String,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Тёмный градиент
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
        // Контент с анимацией
        AnimatedOpacity(
          opacity: _uiVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Заголовок
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'Выберите AI-тренера',
                    style: TextStyle(
                      fontSize: 28,
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
                // Блок с тренерами
                Expanded(
                  child: PageView.builder(
                    itemCount: _trainers.length,
                    onPageChanged: (index) {
                      setState(() => _selectedTrainerIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final trainer = _trainers[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Информация о тренере
                              Transform.translate(
                                offset: const Offset(0, -20),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        trainer['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        trainer['title'] as String,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (trainer['color'] as Color)
                                              .withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          trainer['specialty'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Круглое фото тренера
                              Transform.translate(
                                offset: const Offset(30, 0),
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedTrainerIndex == index
                                          ? (trainer['color'] as Color)
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      trainer['photo'] as String,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Кнопка внизу – открывает ChatScreen
                Padding(
                  padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final trainer = _trainers[_selectedTrainerIndex];
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              characterName: trainer['name'] as String,
                              userProfile: widget.userProfile,
                              pathType: 'hybrid',
                              isTrainer: true,
                              characterImage: trainer['photo'] as String,
                              characterProfession: trainer['title'] as String,
                              characterPersonality: trainer['specialty'] as String,
                            ),
                          ),
                        );
                        // После возврата из чата переходим к следующему этапу
                        widget.onTrainingComplete?.call();
                      },
                      icon: const Icon(Icons.psychology, size: 28),
                      label: const Text(
                        'Начать тренинг с этим тренером',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _trainers[_selectedTrainerIndex]['color'] as Color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Кнопка скрытия интерфейса
        Positioned(
          bottom: 40,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.6),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _uiVisible = !_uiVisible;
                });
              },
              icon: Icon(
                _uiVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}