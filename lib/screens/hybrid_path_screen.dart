import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'profile_screen.dart';
import 'ai_communication_stage.dart';
import 'ai_recommendations_stage.dart';
import 'personality_test_screen.dart';
import 'ai_matching_screen.dart';   // содержит матчинг реальных людей

class HybridPathScreen extends StatefulWidget {
  final UserProfile userProfile;
  final String pathType;

  const HybridPathScreen({
    super.key,
    required this.userProfile,
    required this.pathType,
  });

  @override
  State<HybridPathScreen> createState() => _HybridPathScreenState();
}

class _HybridPathScreenState extends State<HybridPathScreen> {
  int _currentStage = 0;
  final List<Map<String, dynamic>> _stages = [
    {
      'title': '🎭 Тренировка с ИИ',
      'subtitle': 'Потренируйтесь в общении с ИИ-тренером',
      'icon': Icons.psychology,
      'color': Colors.blue,
    },
    {
      'title': '📊 Анализ и рекомендации',
      'subtitle': 'Получите персональные советы от ИИ',
      'icon': Icons.analytics,
      'color': Colors.green,
    },
    {
      'title': '💞 Реальная пара',
      'subtitle': 'Идеальные кандидаты на основе ваших ответов',
      'icon': Icons.favorite,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Гибридный путь'),
        centerTitle: true,
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
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: _buildStageContent(),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          final String title = stage['title'] as String;
          final IconData icon = stage['icon'] as IconData;
          final Color color = stage['color'] as Color;
          return Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _currentStage >= index ? color : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title.split(' ').first,
                style: TextStyle(
                  fontWeight: _currentStage >= index
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_currentStage) {
      case 0:
        return AICommunicationStage(
          userProfile: widget.userProfile,
          onTrainingComplete: () {
            setState(() {
              _currentStage = 1;
            });
          },
        );
      case 1:
        return AIRecommendationsStage(userProfile: widget.userProfile);
      case 2:
      // Третий этап – реальный матчинг
        return AIMatchingScreen(
          userProfile: widget.userProfile,
          pathType: widget.pathType,
        );
      default:
        return Container();
    }
  }

  Widget _buildNavigationButtons() {
    // Если мы на третьем этапе, кнопка «Продолжить» заменяется на «К подбору»
    final bool isLastStage = _currentStage == _stages.length - 1;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStage--),
                child: const Text('Назад'),
              ),
            ),
          if (_currentStage > 0) const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                // Проверяем, нужно ли переходить на третий этап (реальные люди)
                if (_currentStage == 1 && !isLastStage) {
                  // Перед переходом к реальным людям убеждаемся, что тест пройден
                  final hasTest = widget.userProfile.dominantType != null;
                  if (!hasTest) {
                    final shouldProceed = await _showTestDialog();
                    if (!shouldProceed) return;
                    // Тест пройден – обновляем профиль, после чего продолжаем
                    // После прохождения теста виджет будет перестроен с новыми данными
                  }
                }
                if (_currentStage < _stages.length - 1) {
                  setState(() => _currentStage++);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                isLastStage ? 'Завершить' : 'Продолжить',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showTestDialog() async {
    // Пользователь ещё не проходил тест личности
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Пройдите тест личности'),
        content: const Text(
          'Для точного подбора реальной пары вам нужно пройти короткий тест (10 вопросов). '
              'Это поможет AI найти наиболее совместимых кандидатов.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Закрываем диалог и переходим к тесту
              Navigator.pop(context, true);
              // Открываем экран теста
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalityTestScreen(userProfile: widget.userProfile),
                ),
              );
              // Возвращаем true, так как тест пройден (пользователь вернётся сюда)
            },
            child: const Text('Пройти тест'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}