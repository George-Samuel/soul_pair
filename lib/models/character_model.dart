import 'package:flutter/material.dart';

class Character {
  final String id;
  final String name;
  final int age;
  final String gender; // 'male' или 'female'
  final String profession;
  final String location;
  final String description;
  final String personality;
  final String imagePath;
  final Color themeColor;
  final List<String> interests;

  Character({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.profession,
    required this.location,
    required this.description,
    required this.personality,
    required this.imagePath,
    required this.themeColor,
    required this.interests,
  });

  factory Character.fromMap(Map<String, dynamic> data) {
    final age = _estimateAgeFromName(data['name'] as String);
    final gender = _detectGender(data['name'] as String);
    final location = _extractLocation(data['profession'] as String);
    final interests = _extractInterests(data['personality'] as String);

    return Character(
      id: (data['name'] as String).toLowerCase().replaceAll(' ', '_'),
      name: data['name'] as String,
      age: age,
      gender: gender,
      profession: data['profession'] as String,
      location: location,
      description: data['description'] as String,
      personality: data['personality'] as String,
      imagePath: data['image'] as String,
      themeColor: data['color'] as Color,
      interests: interests,
    );
  }

  static int _estimateAgeFromName(String name) {
    final ageMap = {
      // Женские персонажи
      'Лиза': 22,
      'Аня': 21,
      'Кира': 25,
      'София': 24,
      'Фрейя': 28,
      'Хана': 23,
      'Изабелла': 29,
      'Натали': 31,
      'Прия': 27,
      'Сакура': 26,
      'Элина': 29,
      'Жасмин': 34,
      'Алиса': 41,
      'Роза': 50,
      'Мия': 23,
      // Мужские персонажи (старые)
      'Марк': 32,
      'Дмитрий': 38,
      'Люк': 28,
      'Карлос': 45,
      'Кай': 25,
      // Новые мужские персонажи
      'Артём': 31,
      'Михаил': 38,
      'Николай': 34,
      'Виктор': 27,
      'Евгений': 29,
    };
    return ageMap[name] ?? 30;
  }

  static String _detectGender(String name) {
    final maleNames = [
      'Марк', 'Дмитрий', 'Люк', 'Карлос', 'Кай',
      'Артём', 'Михаил', 'Николай', 'Виктор', 'Евгений'
    ];
    final femaleNames = [
      'Лиза', 'Аня', 'Кира', 'София', 'Фрейя', 'Хана', 'Изабелла',
      'Натали', 'Прия', 'Сакура', 'Элина', 'Жасмин', 'Алиса', 'Роза', 'Мия'
    ];

    if (maleNames.contains(name)) return 'male';
    if (femaleNames.contains(name)) return 'female';
    return 'unknown';
  }

  static String _extractLocation(String profession) {
    // Женские
    if (profession.contains('Париж')) return 'Париж, Франция';
    if (profession.contains('Санкт-Петербург')) return 'Санкт-Петербург, Россия';
    if (profession.contains('Токио')) return 'Токио, Япония';
    if (profession.contains('Барселона')) return 'Барселона, Испания';
    if (profession.contains('Каир')) return 'Каир, Египет';
    if (profession.contains('Индия')) return 'Мумбаи, Индия';
    if (profession.contains('Киото')) return 'Киото, Япония';
    if (profession.contains('Вена')) return 'Вена, Австрия';
    if (profession.contains('Лондон')) return 'Лондон, Великобритания';
    if (profession.contains('Берлин')) return 'Берлин, Германия';
    if (profession.contains('Греция')) return 'Афины, Греция';
    if (profession.contains('Копенгаген')) return 'Копенгаген, Дания';
    // Мужские
    if (profession.contains('Калифорния')) return 'Калифорния, США';
    if (profession.contains('Москва')) return 'Москва, Россия';
    if (profession.contains('Новая Зеландия')) return 'Окленд, Новая Зеландия';
    if (profession.contains('Тоскана')) return 'Тоскана, Италия';
    if (profession.contains('Сеул')) return 'Сеул, Южная Корея';
    // Новые мужские
    if (profession.contains('Камчатка')) return 'Камчатка, Россия';
    if (profession.contains('Архитектор')) return 'Санкт-Петербург, Россия';
    if (profession.contains('Психолог')) return 'Москва, Россия';
    if (profession.contains('Фитнес')) return 'Краснодар, Россия';
    if (profession.contains('программист')) return 'Новосибирск, Россия';
    return 'Неизвестно';
  }

  static List<String> _extractInterests(String personality) {
    final interests = <String>[];
    // Женские интересы
    if (personality.contains('искусств')) interests.add('Искусство');
    if (personality.contains('философ')) interests.add('Философия');
    if (personality.contains('музе')) interests.add('Музеи');
    if (personality.contains('биолог')) interests.add('Биология');
    if (personality.contains('эколог')) interests.add('Экология');
    if (personality.contains('научн')) interests.add('Наука');
    if (personality.contains('технолог')) interests.add('Технологии');
    if (personality.contains('программир')) interests.add('Программирование');
    if (personality.contains('стих')) interests.add('Поэзия');
    if (personality.contains('путешеств')) interests.add('Путешествия');
    if (personality.contains('экстрим')) interests.add('Экстрим');
    if (personality.contains('гор')) interests.add('Горы');
    if (personality.contains('аниме')) interests.add('Аниме');
    if (personality.contains('японск')) interests.add('Японская культура');
    if (personality.contains('дизайн')) interests.add('Дизайн');
    if (personality.contains('истори')) interests.add('История');
    if (personality.contains('медитац')) interests.add('Медитация');
    if (personality.contains('вегетариан')) interests.add('Здоровое питание');
    if (personality.contains('сады')) interests.add('Садоводство');
    if (personality.contains('кофе')) interests.add('Кофе');
    if (personality.contains('спорт')) interests.add('Спорт');
    if (personality.contains('йог')) interests.add('Йога');
    if (personality.contains('цвет')) interests.add('Флористика');
    // Мужские интересы (для новых)
    if (personality.contains('фотограф')) interests.add('Фотография');
    if (personality.contains('пейзаж')) interests.add('Пейзажи');
    if (personality.contains('черчение')) interests.add('Черчение');
    if (personality.contains('урбанист')) interests.add('Урбанистика');
    if (personality.contains('психолог')) interests.add('Психология');
    if (personality.contains('волонтёр')) interests.add('Волонтёрство');
    if (personality.contains('настольн')) interests.add('Настольные игры');
    if (personality.contains('фитнес')) interests.add('Фитнес');
    if (personality.contains('ЗОЖ')) interests.add('ЗОЖ');
    if (personality.contains('робототехн')) interests.add('Робототехника');
    if (personality.contains('видеоигр')) interests.add('Видеоигры');

    return interests.isNotEmpty ? interests : ['Саморазвитие', 'Психология'];
  }
}
