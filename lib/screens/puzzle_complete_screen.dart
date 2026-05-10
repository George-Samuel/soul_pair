import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart'; // ← ДОБАВЬ ИМПОРТ
import 'path_selection_screen.dart';

class PuzzleCompleteScreen extends StatefulWidget {
  final UserProfile userProfile;
  final String puzzleImageAsset;

  const PuzzleCompleteScreen({
    super.key,
    required this.userProfile,
    required this.puzzleImageAsset,
  });

  @override
  State<PuzzleCompleteScreen> createState() => _PuzzleCompleteScreenState();
}

class _PuzzleCompleteScreenState extends State<PuzzleCompleteScreen> {
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    // ✅ УБЕДИСЬ ЧТО ПРОФИЛЬ В ProfileService
    if (ProfileService.currentProfile == null) {
      ProfileService.updateProfile(widget.userProfile);
      print(
          '✅ Профиль сохранен из PuzzleCompleteScreen: ${widget.userProfile.name}');
    }

    // Показываем кнопку через 500мс
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
      }
    });
  }

  void _goToNextScreen() {
    // ✅ УБЕДИСЬ ЧТО ПРОФИЛЬ ПЕРЕДАЕТСЯ С ProfileService
    final profileToPass = ProfileService.currentProfile ?? widget.userProfile;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PathSelectionScreen(
          userProfile: profileToPass,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. ФОТО ПАЗЛА НА ВЕСЬ ЭКРАН
          Image.asset(
            widget.puzzleImageAsset,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // 2. ТЕМНЫЙ ГРАДИЕНТНЫЙ ОВЕРЛЕЙ ДЛЯ ТЕКСТА
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 3. ОСНОВНОЕ СООБЩЕНИЕ "ПОЗДРАВЛЯЕМ!"
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Заголовок "ПОЗДРАВЛЯЕМ!"
                Text(
                  'ПОЗДРАВЛЯЕМ!',
                  style: TextStyle(
                    fontSize: 48 * textScaleFactor,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 20,
                        offset: const Offset(0, 3),
                      ),
                      Shadow(
                        color: Colors.purple.withOpacity(0.5),
                        blurRadius: 25,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                // Подзаголовок
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Пазл вашей личности собран',
                    style: TextStyle(
                      fontSize: 24 * textScaleFactor,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // 4. КНОПКА "ДАЛЕЕ" ВНИЗУ ЭКРАНА
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _showButton ? 1.0 : 0.0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                offset: _showButton ? Offset.zero : const Offset(0, 1),
                child: Column(
                  children: [
                    // Подсказка для пользователя
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        'Нажмите для продолжения',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // КНОПКА В СТИЛЕ АНКЕТЫ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goToNextScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple[800],
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 30,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Далее',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple[800],
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 24,
                              color: Colors.purple[800],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
