import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/theme_colors.dart';

class AIRecommendationsStage extends StatefulWidget {
  final UserProfile userProfile;

  const AIRecommendationsStage({super.key, required this.userProfile});

  @override
  State<AIRecommendationsStage> createState() => _AIRecommendationsStageState();
}

class _AIRecommendationsStageState extends State<AIRecommendationsStage> {
  final Map<String, dynamic> _analysisResults = {
    'strengths': [
      'Вы хорошо задаете вопросы',
      'Дружелюбный тон общения',
      'Интересуетесь собеседником',
    ],
    'improvements': [
      'Можно больше рассказывать о себе',
      'Попробуйте использовать больше открытых вопросов',
      'Обращайте внимание на невербальные сигналы',
    ],
    'compatibilityTips': [
      'Ищите людей со схожими интересами в ${_getRandomInterest()}',
      'Обращайте внимание на чувство юмора',
      'Цените искренность в общении',
    ],
    'confidenceScore': 78,
  };

  static String _getRandomInterest() {
    final interests = ['музыке', 'кино', 'путешествиях', 'спорте', 'книгах'];
    return interests[DateTime.now().millisecond % interests.length];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.analytics,
                    size: 60, color: ThemeColors.accent(context)),
                const SizedBox(height: 10),
                Text(
                  'Анализ вашего общения',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ИИ проанализировал ваш стиль общения',
                  style: TextStyle(
                    color: ThemeColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildConfidenceScore(context),
          const SizedBox(height: 30),
          _buildSection(
            context,
            title: '✅ Ваши сильные стороны',
            items: (_analysisResults['strengths'] as List).cast<String>(),
            accentColor: Colors.green,
          ),
          const SizedBox(height: 25),
          _buildSection(
            context,
            title: '📈 Что можно улучшить',
            items: (_analysisResults['improvements'] as List).cast<String>(),
            accentColor: Colors.orange,
          ),
          const SizedBox(height: 25),
          _buildSection(
            context,
            title: '💞 Советы для поиска пары',
            items: (_analysisResults['compatibilityTips'] as List).cast<String>(),
            accentColor: Colors.purple,
          ),
          const SizedBox(height: 30),
          _buildMeetingPreparation(context),
        ],
      ),
    );
  }

  Widget _buildConfidenceScore(BuildContext context) {
    final int confidenceScore = _analysisResults['confidenceScore'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Column(
        children: [
          Text(
            'Уровень уверенности в общении',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 15),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: confidenceScore / 100,
                  strokeWidth: 15,
                  color: _getScoreColor(confidenceScore),
                  backgroundColor: ThemeColors.divider(context),
                ),
              ),
              Text(
                '$confidenceScore%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _getScoreComment(confidenceScore),
            style: TextStyle(
              color: ThemeColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required List<String> items,
        required Color accentColor,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: accentColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: ThemeColors.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMeetingPreparation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.accent(context).withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Подготовка к реальной встрече',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Советы для первой встречи:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ThemeColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 10),
          _buildTip(context, 'Выберите нейтральное место: кофейня, парк'),
          _buildTip(context, 'Будьте собой, не пытайтесь произвести впечатление'),
          _buildTip(context, 'Задавайте открытые вопросы (Что? Как? Почему?)'),
          _buildTip(context, 'Слушайте внимательно, проявляйте искренний интерес'),
          _buildTip(context, 'Не бойтесь тишины - это нормально'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.people),
            label: const Text('Готов к встрече с реальным человеком'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.accent(context),
              foregroundColor: ThemeColors.onAccent(context),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: ThemeColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreComment(int score) {
    if (score >= 80) return 'Вы отлично готовы к реальным встречам!';
    if (score >= 60) return 'Хороший уровень, есть что улучшить';
    return 'Потренируйтесь еще, чтобы чувствовать себя увереннее';
  }
}