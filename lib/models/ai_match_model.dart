// lib/models/ai_match_model.dart
import 'package:flutter/material.dart';
import 'character_model.dart';
import 'user_model.dart';

class AIMatch {
  final String id;
  final Character character;
  final UserProfile userProfile;
  final int compatibilityScore; // 0-100
  final String matchType; // 'perfect', 'good', 'average', 'low'
  final DateTime matchedAt;
  final Map<String, int> dimensionScores;
  final List<String> compatibilityReasons;
  final String aiAnalysis;

  AIMatch({
    required this.id,
    required this.character,
    required this.userProfile,
    required this.compatibilityScore,
    required this.matchType,
    required this.matchedAt,
    required this.dimensionScores,
    required this.compatibilityReasons,
    required this.aiAnalysis,
  });

  // Цвет в зависимости от типа совпадения
  Color get matchColor {
    switch (matchType) {
      case 'perfect':
        return Colors.green;
      case 'good':
        return Colors.lightGreen;
      case 'average':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Иконка в зависимости от типа
  IconData get matchIcon {
    switch (matchType) {
      case 'perfect':
        return Icons.favorite;
      case 'good':
        return Icons.star;
      case 'average':
        return Icons.thumb_up;
      case 'low':
        return Icons.psychology;
      default:
        return Icons.person;
    }
  }

  // Текстовое описание
  String get matchDescription {
    switch (matchType) {
      case 'perfect':
        return 'Идеальное совпадение!';
      case 'good':
        return 'Отличная совместимость';
      case 'average':
        return 'Хороший потенциал';
      case 'low':
        return 'Интересное сочетание';
      default:
        return 'Совпадение найдено';
    }
  }

  // Подробное описание
  String get detailedAnalysis {
    return '''
🔍 **AI-Анализ совместимости**

👤 **Пользователь:** ${userProfile.name}
🎯 **Интересы:** ${userProfile.interests ?? 'не указаны'}

🎯 **Персонаж:** ${character.name}
💼 **Профессия:** ${character.profession}
📍 **Локация:** ${character.location}

📊 **Общий балл:** $compatibilityScore/100
🏆 **Тип совпадения:** ${matchType.toUpperCase()}

🤝 **Причины совместимости:**
${compatibilityReasons.map((r) => '✓ $r').join('\n')}

💭 **Заключение AI:**
$aiAnalysis
''';
  }
}

// Упрощённый AI движок (работает с вашими текущими данными)
class SimpleAIMatchingEngine {
  final UserProfile userProfile;

  SimpleAIMatchingEngine({
    required this.userProfile,
  });

  // Основной метод анализа (упрощённый)
  Future<List<AIMatch>> analyzeCompatibility(List<Character> characters) async {
    final matches = <AIMatch>[];

    // Имитация AI-анализа
    await Future.delayed(const Duration(seconds: 2));

    for (final character in characters) {
      // Упрощённая логика совместимости на основе интересов
      final score = _calculateSimpleScore(character);
      final matchType = _determineMatchType(score);

      final match = AIMatch(
        id: '${userProfile.id}_${character.id}_${DateTime.now().millisecondsSinceEpoch}',
        character: character,
        userProfile: userProfile,
        compatibilityScore: score,
        matchType: matchType,
        matchedAt: DateTime.now(),
        dimensionScores: _generateDimensionScores(),
        compatibilityReasons: _generateCompatibilityReasons(character),
        aiAnalysis: _generateAIAnalysis(character, score),
      );

      matches.add(match);
    }

    // Сортировка по совместимости
    matches
        .sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));

    return matches;
  }

  int _calculateSimpleScore(Character character) {
    // Базовый балл
    int score = 60;

    // Бонус за общие интересы
    if (userProfile.interests != null && character.interests.isNotEmpty) {
      final userInterests = userProfile.interests!.toLowerCase();
      for (final interest in character.interests) {
        if (userInterests.contains(interest.toLowerCase())) {
          score += 5;
        }
      }
    }

    // Бонус за возрастную совместимость
    if (userProfile.age != null) {
      final ageDiff = (userProfile.age! - character.age).abs();
      if (ageDiff <= 5) {
        score += 15;
      } else if (ageDiff <= 10)
        score += 10;
      else if (ageDiff <= 15) score += 5;
    }

    // Ограничиваем до 100
    return score.clamp(0, 100);
  }

  String _determineMatchType(int score) {
    if (score >= 85) return 'perfect';
    if (score >= 70) return 'good';
    if (score >= 60) return 'average';
    return 'low';
  }

  Map<String, int> _generateDimensionScores() {
    return {
      'Личности': 60 + DateTime.now().microsecond % 35,
      'Интересы': 60 + DateTime.now().microsecond % 40,
      'Ценности': 60 + DateTime.now().microsecond % 30,
      'Общение': 60 + DateTime.now().microsecond % 25,
    };
  }

  List<String> _generateCompatibilityReasons(Character character) {
    final reasons = [
      'Схожие интересы и увлечения',
      'Дополняющие друг друга черты характера',
      'Потенциал для интересного общения',
      'Возможность узнать что-то новое',
    ];

    // Добавляем персонализированные причины
    if (character.interests.any((interest) =>
        userProfile.interests?.toLowerCase().contains(interest.toLowerCase()) ==
        true)) {
      reasons.add('Общие темы для разговоров');
    }

    return reasons.take(3).toList();
  }

  String _generateAIAnalysis(Character character, int score) {
    if (score >= 85) {
      return 'Вы и ${character.name} имеете высокую совместимость по интересам и ценностям. Это отличная основа для содержательного общения!';
    } else if (score >= 70) {
      return 'Хорошая совместимость. У вас есть общие точки соприкосновения, которые могут развиться в интересную беседу.';
    } else if (score >= 60) {
      return 'Средняя совместимость. Различия могут сделать общение ещё более интересным и познавательным.';
    } else {
      return 'Интересный контраст. Общение с ${character.name} может открыть для вас новые перспективы и взгляды.';
    }
  }
}
