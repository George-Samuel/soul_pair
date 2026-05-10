// lib/screens/test_filter_screen.dart
import 'package:flutter/material.dart';
import '../services/text_moderation.dart';

class TestFilterScreen extends StatefulWidget {
  const TestFilterScreen({super.key});

  @override
  State<TestFilterScreen> createState() => _TestFilterScreenState();
}

class _TestFilterScreenState extends State<TestFilterScreen> {
  final TextEditingController _controller = TextEditingController();
  String _lastCheckedText = '';
  bool _lastResult = false;

  void _checkText() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите текст для проверки')),
      );
      return;
    }

    final containsProfanity = TextModeration.containsProfanity(text);
    setState(() {
      _lastCheckedText = text;
      _lastResult = containsProfanity;
    });

    if (containsProfanity) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
              SizedBox(height: 8),
              Text('Недопустимые'),
              Text('выражения'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Ваше сообщение содержит слова, нарушающие правила культурного общения сообщества.'),
                SizedBox(height: 12),
                Text('Пожалуйста, выражайтесь культурно и уважительно.'),
                Text(
                  'В противном случае ВАШ ПРОФИЛЬ БУДЕТ ЗАБЛОКИРОВАН.',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Текст чист, можно отправлять'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // получаем тему для цветов
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест фильтра мата'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Введите фразу для проверки:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color), // цвет текста
              decoration: InputDecoration(
                hintText: 'Например: "Ты дурак" или "Привет, как дела?"',
                hintStyle: TextStyle(color: theme.hintColor), // цвет подсказки
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.cardColor, // фон поля
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _checkText,
              icon: const Icon(Icons.check_circle),
              label: const Text('Проверить текст'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_lastCheckedText.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Последняя проверка:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Текст: "$_lastCheckedText"'),
                      const SizedBox(height: 8),
                      // ИСПРАВЛЕННЫЙ ROW С ПЕРЕНОСОМ СЛОВА
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _lastResult ? Icons.cancel : Icons.check_circle,
                            color: _lastResult ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _lastResult
                                  ? 'Обнаружены недопустимые\nслова!'
                                  : 'Нарушений не найдено',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _lastResult ? Colors.red : Colors.green,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
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
}