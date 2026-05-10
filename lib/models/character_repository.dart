import 'package:flutter/material.dart';
import 'character_model.dart';

class CharacterRepository {
  // Получить ВСЕХ персонажей (10 существующих + 5 старых мужских + 5 новых мужских + 5 новых женских = 20?)
  // Давайте пересчитаем: 10 существующих женских + 5 старых мужских + 5 новых мужских + 5 новых женских = 25
  static List<Character> getAllCharacters() {
    final List<Map<String, dynamic>> characterData = [
      // ==================== СУЩЕСТВУЮЩИЕ 10 ПЕРСОНАЖЕЙ (женские) ====================
      {
        'name': 'Лиза',
        'profession': 'Студентка-искусствовед из Парижа',
        'description': 'Мечтательная, интеллигентная, немного загадочная',
        'color': Colors.purple,
        'image': 'assets/images/Liza.jpg',
        'personality': 'Любит искусство, философию и долгие прогулки по музеям',
        'gender': 'female',
      },
      {
        'name': 'Аня',
        'profession': 'Студентка-биолог из Санкт-Петербурга',
        'description': 'Спокойная, наблюдательная, любит природу',
        'color': Colors.green,
        'image': 'assets/images/Anna.jpg',
        'personality': 'Увлекается биологией, экологией и научными исследованиями',
        'gender': 'female',
      },
      {
        'name': 'Кира',
        'profession': 'Кибер-агент из 2142 года',
        'description': 'Технологичная, умная, говорит на 7 языках',
        'color': Colors.blue,
        'image': 'assets/images/Kira.jpg',
        'personality': 'Интересуется технологиями, программированием и будущим',
        'gender': 'female',
      },
      {
        'name': 'София',
        'profession': 'Бариста-поэт из Неаполя',
        'description': 'Страстная, щедрая, говорит на метафорах',
        'color': Colors.orange,
        'image': 'assets/images/Sofia.jpg',
        'personality': 'Пишет стихи, варит кофе и мечтает о путешествиях',
        'gender': 'female',
      },
      {
        'name': 'Фрейя',
        'profession': 'Спортсменка-скалолаз из Норвегии',
        'description': 'Энергичная, решительная, любит приключения',
        'color': Colors.red,
        'image': 'assets/images/Freya.jpg',
        'personality': 'Обожает экстрим, горы и новые вызовы',
        'gender': 'female',
      },
      {
        'name': 'Хана',
        'profession': 'Художница-иллюстратор из Токио',
        'description': 'Креативная, внимательная к деталям',
        'color': Colors.pink,
        'image': 'assets/images/Hana.jpg',
        'personality': 'Рисует мангу, любит аниме и японскую культуру',
        'gender': 'female',
      },
      {
        'name': 'Изабелла',
        'profession': 'Архитектор из Барселоны',
        'description': 'Утонченная, практичная, ценит красоту',
        'color': Colors.teal,
        'image': 'assets/images/Isabella.jpg',
        'personality': 'Проектирует здания, любит Гауди и современный дизайн',
        'gender': 'female',
      },
      {
        'name': 'Натали',
        'profession': 'Историк-египтолог из Каира',
        'description': 'Мудрая, загадочная, знает древние языки',
        'color': Colors.amber,
        'image': 'assets/images/Natalie.jpg',
        'personality': 'Изучает пирамиды, иероглифы и историю Древнего Египта',
        'gender': 'female',
      },
      {
        'name': 'Прия',
        'profession': 'Йога-инструктор из Индии',
        'description': 'Духовная, гармоничная, излучает спокойствие',
        'color': Colors.deepOrange,
        'image': 'assets/images/Priya.jpg',
        'personality': 'Практикует медитацию, аюрведу и вегетарианство',
        'gender': 'female',
      },
      {
        'name': 'Сакура',
        'profession': 'Флорист из Киото',
        'description': 'Нежная, терпеливая, чувствует природу',
        'color': Colors.lightGreen,
        'image': 'assets/images/Sakura.jpg',
        'personality': 'Создает икэбану, любит цветущую сакуру и японские сады',
        'gender': 'female',
      },

      // ==================== СТАРЫЕ 5 МУЖСКИХ ПЕРСОНАЖЕЙ ====================
      {
        'name': 'Марк',
        'profession': 'Астрофизик из Калифорнии',
        'description': 'Аналитичный, вдумчивый, мечтатель',
        'color': Colors.indigo,
        'image': 'assets/images/characters/mark_astrophysicist.jpg',
        'personality': 'Изучает чёрные дыры, верит в внеземную жизнь, коллекционирует телескопы',
        'gender': 'male',
      },
      {
        'name': 'Дмитрий',
        'profession': 'Шеф-повар из Москвы',
        'description': 'Страстный, перфекционист, гостеприимный',
        'color': Colors.redAccent,
        'image': 'assets/images/characters/dmitry_chef.jpg',
        'personality': 'Экспериментирует с фьюжн-кухней, собирает редкие специи, ведёт кулинарный блог',
        'gender': 'male',
      },
      {
        'name': 'Люк',
        'profession': 'Пилот вертолёта из Новой Зеландии',
        'description': 'Смелый, свободолюбивый, прагматичный',
        'color': Colors.blueGrey,
        'image': 'assets/images/characters/luke_helicopter_pilot.jpg',
        'personality': 'Спасает людей в горах, увлекается парапланеризмом, фотографирует с высоты',
        'gender': 'male',
      },
      {
        'name': 'Карлос',
        'profession': 'Винодел из Тосканы',
        'description': 'Терпеливый, чувственный, традиционалист',
        'color': Colors.deepPurple,
        'image': 'assets/images/characters/carlos_winemaker.jpg',
        'personality': 'Унаследовал семейную винодельню, разбирается в сортах винограда, ценит медленную жизнь',
        'gender': 'male',
      },
      {
        'name': 'Кай',
        'profession': 'Геймдизайнер из Сеула',
        'description': 'Креативный, техничный, немного интроверт',
        'color': Colors.cyan,
        'image': 'assets/images/characters/kai_game_designer.jpg',
        'personality': 'Создает инди-игры, участвует в геймджемах, коллекционирует ретро-консоли',
        'gender': 'male',
      },

      // ==================== НОВЫЕ 5 МУЖСКИХ ПЕРСОНАЖЕЙ (по вашему списку) ====================
      {
        'name': 'Артём',
        'profession': 'Фотограф-пейзажист',
        'description': 'Вдохновляющий, романтичный, ищет красоту в деталях',
        'color': Colors.amber,
        'image': 'assets/images/characters/artem_photographer.jpg',
        'personality': 'Путешествует, снимает пейзажи, горы и закаты',
        'gender': 'male',
      },
      {
        'name': 'Михаил',
        'profession': 'Архитектор',
        'description': 'Практичный, творческий, ценит гармонию',
        'color': Colors.indigo,
        'image': 'assets/images/characters/mikhail_architect.jpg',
        'personality': 'Проектирует здания, увлекается урбанистикой',
        'gender': 'male',
      },
      {
        'name': 'Николай',
        'profession': 'Психолог',
        'description': 'Эмпатичный, внимательный, хороший слушатель',
        'color': Colors.lightBlue,
        'image': 'assets/images/characters/nikolay_psychologist.jpg',
        'personality': 'Читает книги по психологии, занимается волонтёрством',
        'gender': 'male',
      },
      {
        'name': 'Виктор',
        'profession': 'Фитнес-тренер',
        'description': 'Энергичный, мотивирующий, заботится о здоровье',
        'color': Colors.lime,
        'image': 'assets/images/characters/viktor_fitness.jpg',
        'personality': 'Занимается спортом, йогой, бегом, следит за питанием',
        'gender': 'male',
      },
      {
        'name': 'Евгений',
        'profession': 'AI-программист',
        'description': 'Интеллектуальный, увлечённый технологиями',
        'color': Colors.cyan,
        'image': 'assets/images/characters/evgeny_programmer.jpg',
        'personality': 'Разрабатывает ИИ, интересуется робототехникой',
        'gender': 'male',
      },

      // ==================== НОВЫЕ 5 ЖЕНСКИХ ПЕРСОНАЖЕЙ (уже были) ====================
      {
        'name': 'Элина',
        'profession': 'Психотерапевт из Вены',
        'description': 'Эмпатичная, проницательная, спокойная',
        'color': Colors.lightBlue,
        'image': 'assets/images/characters/elina_psychotherapist.jpg',
        'personality': 'Специализируется на арт-терапии, ведёт подкаст о ментальном здоровье, медитирует',
        'gender': 'female',
      },
      {
        'name': 'Жасмин',
        'profession': 'Журналист-расследователь из Лондона',
        'description': 'Настойчивая, принципиальная, любопытная',
        'color': Colors.brown,
        'image': 'assets/images/characters/jasmine_journalist.jpg',
        'personality': 'Раскрывает корпоративные скандалы, ведёт расследования, пишет документальные книги',
        'gender': 'female',
      },
      {
        'name': 'Алиса',
        'profession': 'Куратор современного искусства из Берлина',
        'description': 'Эксцентричная, авангардная, провокационная',
        'color': Colors.purpleAccent,
        'image': 'assets/images/characters/alisa_art_curator.jpg',
        'personality': 'Организует инсталляции, открыла галерею в бывшем заводе, коллекционирует стрит-арт',
        'gender': 'female',
      },
      {
        'name': 'Роза',
        'profession': 'Капитан парусной яхты из Греции',
        'description': 'Сильная, независимая, мудрая',
        'color': Colors.blue.shade700,
        'image': 'assets/images/characters/roza_yacht_captain.jpg',
        'personality': 'Объездила все Средиземное море, учит навигации, воспитывает дочь-моряка',
        'gender': 'female',
      },
      {
        'name': 'Мия',
        'profession': 'Эко-активистка из Копенгагена',
        'description': 'Идеалистка, энергичная, убедительная',
        'color': Colors.green.shade700,
        'image': 'assets/images/characters/mia_eco_activist.jpg',
        'personality': 'Организует климатические забастовки, ведёт zero-waste образ жизни, выращивает городской сад',
        'gender': 'female',
      },
    ];

    return characterData.map((data) => Character.fromMap(data)).toList();
  }

  // Получить только мужских персонажей
  static List<Character> getMaleCharacters() {
    return getAllCharacters().where((c) => c.gender == 'male').toList();
  }

  // Получить только женских персонажей
  static List<Character> getFemaleCharacters() {
    return getAllCharacters().where((c) => c.gender == 'female').toList();
  }

  // Найти персонажа по ID
  static Character? findById(String id) {
    try {
      return getAllCharacters().firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Получить персонажей для определённого пола пользователя
  static List<Character> getCharactersForUser(String? userGender) {
    if (userGender == 'Мужской') {
      return getFemaleCharacters(); // мужчинам показываем женщин
    } else if (userGender == 'Женский') {
      return getMaleCharacters(); // женщинам показываем мужчин
    }
    return getAllCharacters();
  }

  // Поиск персонажей по имени (регистронезависимый)
  static List<Character> searchByName(String query) {
    if (query.isEmpty) return getAllCharacters();

    final lowerQuery = query.toLowerCase();
    return getAllCharacters().where((character) {
      return character.name.toLowerCase().contains(lowerQuery) ||
          character.profession.toLowerCase().contains(lowerQuery) ||
          character.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Получить случайного персонажа
  static Character getRandomCharacter() {
    final characters = getAllCharacters();
    final randomIndex = DateTime.now().microsecond % characters.length;
    return characters[randomIndex];
  }

  // Получить персонажей по возрасту (нужно добавить возраст в данные)
  static List<Character> getCharactersByAgeRange(int minAge, int maxAge) {
    return getAllCharacters().where((c) {
      return c.age >= minAge && c.age <= maxAge;
    }).toList();
  }

  // Получить персонажей по профессии
  static List<Character> getCharactersByProfession(String profession) {
    final lowerProfession = profession.toLowerCase();
    return getAllCharacters().where((c) {
      return c.profession.toLowerCase().contains(lowerProfession);
    }).toList();
  }

  // Статистика по персонажам
  static Map<String, dynamic> getStatistics() {
    final characters = getAllCharacters();
    final maleCount = getMaleCharacters().length;
    final femaleCount = getFemaleCharacters().length;

    final totalAge = characters.fold(0, (sum, c) => sum + c.age);
    final averageAge = characters.isNotEmpty ? totalAge / characters.length : 0;

    final uniqueProfessions =
    characters.map((c) => c.profession).toSet().toList();

    return {
      'total_characters': characters.length,
      'male_characters': maleCount,
      'female_characters': femaleCount,
      'average_age': averageAge.round(),
      'unique_professions': uniqueProfessions.length,
      'youngest': characters.reduce((a, b) => a.age < b.age ? a : b).name,
      'oldest': characters.reduce((a, b) => a.age > b.age ? a : b).name,
    };
  }
}