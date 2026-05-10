import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class PersonalityTestScreen extends StatefulWidget {
  final UserProfile userProfile;

  const PersonalityTestScreen({super.key, required this.userProfile});

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  final List<Map<String, String>> _questions = const [
    {
      'text': 'В типичный будний вечер после работы вы скорее:',
      'a': 'Готовлю ужин, смотрю сериал/читаю книгу, занимаюсь домашними делами.',
      'b': 'Иду в спортзал, на пробежку или на тренировку.',
      'c': 'Могу спонтанно уехать в город на концерт/выставку, созвониться с друзьями.',
      'd': 'Узнаю, что делает партнёр/семья, и присоединяюсь к их занятию.',
    },
    {
      'text': 'Ваш идеальный выходной (без обязательств):',
      'a': 'Никуда не выходить, заняться хобби дома или пригласить пару близких в гости.',
      'b': 'Активный отдых: поход, велопрогулка, командная игра, скалодром.',
      'c': 'Что-то новое: однодневная поездка, квест, мастер-класс, фестиваль.',
      'd': 'Мне несложно подстроиться под планы другого человека, главное — быть вместе.',
    },
    {
      'text': 'Как вы обычно планируете отпуск?',
      'a': 'Предпочитаю всё предусмотреть заранее (жильё, билеты, маршрут). Ценю комфорт и спокойствие.',
      'b': 'Требуется физическая активность: походы, сплав, горы или пляж с волейболом.',
      'c': 'Люблю импровизацию: могу улететь без отеля, спонтанно сменить направление. Новые впечатления важнее плана.',
      'd': 'Обычно присоединяюсь к планам друзей или партнёра — мне всё равно будет интересно.',
    },
    {
      'text': 'Что для вас важнее в хобби (если тратить деньги и время)?',
      'a': 'Уют, качество жизни, польза для дома/семьи (кулинария, сад, ремонт, чтение).',
      'b': 'Здоровье, тонус, достижение личных рекордов (спорт, фитнес, бег).',
      'c': 'Новизна, яркие эмоции, риск (путешествия, экстрим, изучение нового).',
      'd': 'Возможность разделить это занятие с близким человеком (не важно какое).',
    },
    {
      'text': 'Как вы относитесь к спонтанным предложениям («Поехали прямо сейчас на природу/в кино»)?',
      'a': 'Чаще отказываюсь, если не готов: мне нужен план и моральная подготовка.',
      'b': 'Если это физическая активность — да, если валяние на траве — нет.',
      'c': 'Почти всегда «да»! Рутина утомляет.',
      'd': 'Зависит от настроения партнёра: если он хочет — я за.',
    },
    {
      'text': 'Выберите, что лучше всего описывает ваше общение:',
      'a': 'Мне комфортно с 1–3 близкими людьми. Большие компании утомляют.',
      'b': 'Люблю тусовки, командные виды, мероприятия с движением и активностью.',
      'c': 'Обожаю новые знакомства, нетворкинг, легко завожу разговор с незнакомцами.',
      'd': 'Я скорее ведомый в общении: чувствую себя хорошо, когда меня вовлекают.',
    },
    {
      'text': 'Как вы восстанавливаете энергию после стресса?',
      'a': 'В тишине, дома, за привычным делом (готовка, сериал, ванна).',
      'b': 'Физически — выплескиваю адреналин (бокс, бег, тяжёлая тренировка).',
      'c': 'Сменой обстановки: ухожу в новое место, новое хобби, поездку.',
      'd': 'В компании заботливого партнёра — поговорить или просто побыть рядом.',
    },
    {
      'text': 'Что вы чаще всего делаете вечером в пятницу?',
      'a': 'Готовлю что-то вкусное, смотрю фильм, играю в настолку дома.',
      'b': 'Иду на спорт, в бар смотреть матч или гуляю по городу в быстром темпе.',
      'c': 'Ищу, куда сходить необычного: концерт местной группы, ночной квест, лекцию.',
      'd': 'Присоединяюсь к планам коллег/друзей/партнёра, мне не принципиально что.',
    },
    {
      'text': 'Если партнёр предлагает новое увлечение (нетипичное для вас), вы:',
      'a': 'Настороженно: мне нужно время подумать, вероятно, откажусь.',
      'b': 'Попробую, если это физически активно и не слишком странно.',
      'c': 'С радостью! Новый опыт — это круто.',
      'd': 'Соглашусь почти на всё, лишь бы мы проводили время вместе.',
    },
    {
      'text': 'Ваша идеальная совместная активность с партнёром для крепких отношений:',
      'a': 'Домашний уют: готовим вместе, смотрим кино, обсуждаем книги.',
      'b': 'Спорт, походы, путешествия с активностями — делать что-то энергичное вдвоём.',
      'c': 'Открывать что-то новое: учиться танцам, лететь в незнакомую страну, менять планы.',
      'd': 'Неважно что, главное — чтобы он/она был рядом и я чувствовал поддержку.',
    },
  ];

  final List<Map<String, String>> _answers = List.generate(10, (_) => {});
  int _currentIndex = 0;
  bool _testCompleted = false;
  Map<String, int> _scores = {'Очаг': 0, 'Активный': 0, 'Авантюрист': 0, 'Проводник': 0};

  void _answer(String type) {
    setState(() {
      _answers[_currentIndex] = {'type': type};
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        _testCompleted = true;
        _calculateScore();
        _saveResults();
      }
    });
  }

  void _calculateScore() {
    _scores = {'Очаг': 0, 'Активный': 0, 'Авантюрист': 0, 'Проводник': 0};
    for (var ans in _answers) {
      final type = ans['type'];
      if (type != null) _scores[type] = (_scores[type] ?? 0) + 1;
    }
  }

  Future<void> _saveResults() async {
    final dominantType = _scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final updatedProfile = widget.userProfile.copyWith(
      typeScores: _scores,
      dominantType: dominantType,
    );
    await ProfileService.updateProfile(updatedProfile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ваш тип: $dominantType. Результат сохранён!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_testCompleted) {
      final dominant = _scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      return Scaffold(
        appBar: AppBar(title: const Text('Результат теста')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.psychology, size: 80, color: Colors.purple),
                const SizedBox(height: 20),
                Text('Ваш доминирующий тип: $dominant',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(
                    'Баллы: Очаг ${_scores['Очаг']}, Активный ${_scores['Активный']}, Авантюрист ${_scores['Авантюрист']}, Проводник ${_scores['Проводник']}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Готово'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Вопрос ${_currentIndex + 1} из ${_questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(q['text']!, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _answerButton('а', q['a']!, 'Очаг'),
                  _answerButton('б', q['b']!, 'Активный'),
                  _answerButton('в', q['c']!, 'Авантюрист'),
                  _answerButton('г', q['d']!, 'Проводник'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerButton(String letter, String text, String type) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text('$letter) $text'),
        onTap: () => _answer(type),
      ),
    );
  }
}