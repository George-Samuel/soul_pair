import 'dart:math';

class UserProfile {
  final String email;
  final String? birthDate;
  final String? gender;
  final String? education;
  final String? profession;
  final String? interests;
  final String? languages;
  final String? height;
  final String? weight;
  final String? hasChildren;
  final String? wantsChildren;
  final String? religion;
  final String? attitudeToAnimals;
  final String? smoking;
  final String? alcohol;
  final String? completedAt;

  final String id;
  final String name;
  final int? age;
  final List<String> personalityTraits;
  final String? selectedAvatar;
  final String? country;
  final String? city;
  final bool isAdmin;
  final Map<String, int>? values; // шкала ценностей (0-10)

  // 🆕 Поля для теста личности
  final Map<String, int>? typeScores;   // {'Очаг':5, 'Активный':2, ...}
  final String? dominantType;           // 'Очаг', 'Активный', 'Авантюрист', 'Проводник'

  UserProfile({
    required this.email,
    this.birthDate,
    this.gender,
    this.education,
    this.profession,
    this.interests,
    this.languages,
    this.height,
    this.weight,
    this.hasChildren,
    this.wantsChildren,
    this.religion,
    this.attitudeToAnimals,
    this.smoking,
    this.alcohol,
    this.completedAt,
    String? id,
    String? name,
    this.age,
    this.personalityTraits = const [],
    this.selectedAvatar,
    this.country,
    this.city,
    this.isAdmin = false,
    this.values,
    this.typeScores,
    this.dominantType,
  })  : id = id ?? UserProfile.generateIdFromEmail(email),
        name = name ?? _extractNameFromEmail(email);

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'birth_date': birthDate,
      'gender': gender,
      'education': education,
      'profession': profession,
      'interests': interests,
      'languages': languages,
      'height': height,
      'weight': weight,
      'has_children': hasChildren,
      'wants_children': wantsChildren,
      'religion': religion,
      'attitude_to_animals': attitudeToAnimals,
      'smoking': smoking,
      'alcohol': alcohol,
      'completed_at': completedAt,
      'id': id,
      'name': name,
      'age': age,
      'personality_traits': personalityTraits.join('|'),
      'selected_avatar': selectedAvatar,
      'country': country,
      'city': city,
      'is_admin': isAdmin,
      'values': values,
      'type_scores': typeScores,
      'dominant_type': dominantType,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    List<String> traits = [];
    if (map['personality_traits'] != null) {
      if (map['personality_traits'] is String) {
        final traitsString = map['personality_traits'] as String;
        traits = traitsString.isNotEmpty ? traitsString.split('|') : [];
      } else if (map['personality_traits'] is List) {
        traits = List<String>.from(map['personality_traits'] as List);
      }
    }

    Map<String, int>? valuesMap;
    if (map['values'] != null) {
      final raw = map['values'] as Map<String, dynamic>;
      valuesMap = raw.map((k, v) => MapEntry(k, v as int));
    }

    Map<String, int>? typeScoresMap;
    if (map['type_scores'] != null) {
      final raw = map['type_scores'] as Map<String, dynamic>;
      typeScoresMap = raw.map((k, v) => MapEntry(k, v as int));
    }

    return UserProfile(
      email: map['email'] as String? ?? '',
      birthDate: map['birth_date'] as String?,
      gender: map['gender'] as String?,
      education: map['education'] as String?,
      profession: map['profession'] as String?,
      interests: map['interests'] as String?,
      languages: map['languages'] as String?,
      height: map['height'] as String?,
      weight: map['weight'] as String?,
      hasChildren: map['has_children'] as String?,
      wantsChildren: map['wants_children'] as String?,
      religion: map['religion'] as String?,
      attitudeToAnimals: map['attitude_to_animals'] as String?,
      smoking: map['smoking'] as String?,
      alcohol: map['alcohol'] as String?,
      completedAt: map['completed_at'] as String?,
      id: map['id'] as String?,
      name: map['name'] as String?,
      age: map['age'] != null ? int.tryParse(map['age'].toString()) : null,
      personalityTraits: traits,
      selectedAvatar: map['selected_avatar'] as String?,
      country: map['country'] as String?,
      city: map['city'] as String?,
      isAdmin: map['is_admin'] as bool? ?? false,
      values: valuesMap,
      typeScores: typeScoresMap,
      dominantType: map['dominant_type'] as String?,
    );
  }

  UserProfile copyWith({
    String? email,
    String? birthDate,
    String? gender,
    String? education,
    String? profession,
    String? interests,
    String? languages,
    String? height,
    String? weight,
    String? hasChildren,
    String? wantsChildren,
    String? religion,
    String? attitudeToAnimals,
    String? smoking,
    String? alcohol,
    String? completedAt,
    String? id,
    String? name,
    int? age,
    List<String>? personalityTraits,
    String? selectedAvatar,
    String? country,
    String? city,
    bool? isAdmin,
    Map<String, int>? values,
    Map<String, int>? typeScores,
    String? dominantType,
  }) {
    return UserProfile(
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      education: education ?? this.education,
      profession: profession ?? this.profession,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      hasChildren: hasChildren ?? this.hasChildren,
      wantsChildren: wantsChildren ?? this.wantsChildren,
      religion: religion ?? this.religion,
      attitudeToAnimals: attitudeToAnimals ?? this.attitudeToAnimals,
      smoking: smoking ?? this.smoking,
      alcohol: alcohol ?? this.alcohol,
      completedAt: completedAt ?? this.completedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      country: country ?? this.country,
      city: city ?? this.city,
      isAdmin: isAdmin ?? this.isAdmin,
      values: values ?? this.values,
      typeScores: typeScores ?? this.typeScores,
      dominantType: dominantType ?? this.dominantType,
    );
  }

  static String generateIdFromEmail(String email) {
    return email
        .replaceAll('@', '_at_')
        .replaceAll('.', '_dot_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
  }

  static String _extractNameFromEmail(String email) {
    final namePart = email.split('@').first;
    final cleanName = namePart.replaceAll(RegExp(r'[0-9._+-]'), ' ');
    if (cleanName.isNotEmpty) {
      return cleanName[0].toUpperCase() + cleanName.substring(1);
    }
    return 'Пользователь';
  }

  int? get calculatedAge {
    if (birthDate == null) return null;
    try {
      final parts = birthDate!.split('.');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          final now = DateTime.now();
          final birth = DateTime(year, month, day);
          int age = now.year - birth.year;
          if (now.month < birth.month ||
              (now.month == birth.month && now.day < birth.day)) {
            age--;
          }
          return age >= 0 ? age : null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  List<String> get autoGeneratedTraits {
    final traits = <String>[];
    final userInterests = (interests ?? '').toLowerCase();
    if (userInterests.contains('спорт') ||
        userInterests.contains('фитнес') ||
        userInterests.contains('тренировк')) {
      traits.addAll(['Активный', 'Энергичный']);
    }
    if (userInterests.contains('искусств') ||
        userInterests.contains('творч') ||
        userInterests.contains('рисован') ||
        userInterests.contains('музык')) {
      traits.addAll(['Творческий', 'Чувственный']);
    }
    if (userInterests.contains('наук') ||
        userInterests.contains('технолог') ||
        userInterests.contains('программир') ||
        userInterests.contains('исследован')) {
      traits.addAll(['Любознательный', 'Аналитичный']);
    }
    if (userInterests.contains('путешеств') ||
        userInterests.contains('туризм') ||
        userInterests.contains('приключен')) {
      traits.addAll(['Авантюрный', 'Открытый']);
    }
    if (userInterests.contains('чтение') ||
        userInterests.contains('книг') ||
        userInterests.contains('литератур') ||
        userInterests.contains('философ')) {
      traits.addAll(['Вдумчивый', 'Эрудированный']);
    }
    if (userInterests.contains('природ') ||
        userInterests.contains('животн') ||
        userInterests.contains('экологи')) {
      traits.addAll(['Заботливый', 'Натуральный']);
    }
    if (userInterests.contains('общен') ||
        userInterests.contains('компани') ||
        userInterests.contains('друз')) {
      traits.addAll(['Коммуникабельный', 'Дружелюбный']);
    }
    if (userInterests.contains('кулинар') ||
        userInterests.contains('готовк') ||
        userInterests.contains('еда')) {
      traits.addAll(['Вкусный', 'Гостеприимный']);
    }
    if (traits.isEmpty) {
      traits.addAll(['Открытый', 'Дружелюбный', 'Искренний']);
    }
    return traits;
  }

  List<String> get allPersonalityTraits {
    final allTraits = <String>[];
    allTraits.addAll(personalityTraits);
    for (final trait in autoGeneratedTraits) {
      if (!allTraits.contains(trait)) {
        allTraits.add(trait);
      }
    }
    return allTraits.take(10).toList();
  }

  double get profileCompletion {
    int filledFields = 0;
    if (birthDate?.isNotEmpty == true) filledFields++;
    if (gender?.isNotEmpty == true) filledFields++;
    if (education?.isNotEmpty == true) filledFields++;
    if (interests?.isNotEmpty == true) filledFields++;
    if (languages?.isNotEmpty == true) filledFields++;
    if (height?.isNotEmpty == true) filledFields++;
    if (weight?.isNotEmpty == true) filledFields++;
    if (hasChildren?.isNotEmpty == true) filledFields++;
    if (wantsChildren?.isNotEmpty == true) filledFields++;
    if (religion?.isNotEmpty == true) filledFields++;
    if (attitudeToAnimals?.isNotEmpty == true) filledFields++;
    if (smoking?.isNotEmpty == true) filledFields++;
    if (alcohol?.isNotEmpty == true) filledFields++;
    if (country?.isNotEmpty == true) filledFields++;
    if (city?.isNotEmpty == true) filledFields++;
    if (selectedAvatar?.isNotEmpty == true) filledFields++;
    const int totalFields = 16;
    return filledFields / totalFields;
  }

  Map<String, String> get displayInfo {
    return {
      'Имя': name,
      'Возраст': age?.toString() ?? calculatedAge?.toString() ?? 'Не указан',
      'Пол': gender ?? 'Не указан',
      'Интересы': interests ?? 'Не указаны',
      'Образование': education ?? 'Не указано',
      'Знание языков': languages ?? 'Не указаны',
      'Страна': country ?? 'Не указана',
      'Город': city ?? 'Не указан',
    };
  }

  factory UserProfile.random({String? email}) {
    final random = Random();
    final firstNames = ['Алексей', 'Мария', 'Дмитрий', 'Анна', 'Сергей', 'Екатерина', 'Андрей', 'Ольга'];
    final lastNames = ['Иванов', 'Петрова', 'Сидоров', 'Кузнецова', 'Попов', 'Смирнова'];
    final domains = ['gmail.com', 'yandex.ru', 'mail.ru', 'outlook.com'];
    final firstName = firstNames[random.nextInt(firstNames.length)];
    final lastName = lastNames[random.nextInt(lastNames.length)];
    final domain = domains[random.nextInt(domains.length)];
    final randomEmail = email ?? '${firstName.toLowerCase()}.${lastName.toLowerCase()}@$domain';
    final interestsList = [
      'Спорт, чтение, путешествия',
      'Искусство, музыка, кино',
      'Технологии, программирование, наука',
      'Кулинария, фотография, природа',
      'Танцы, театр, психология',
    ];
    final languagesList = [
      'Русский, Английский',
      'Русский, Немецкий, Французский',
      'Русский, Испанский',
      'Русский, Английский, Китайский',
      'Русский',
    ];
    return UserProfile(
      email: randomEmail,
      birthDate: '${random.nextInt(28) + 1}.${random.nextInt(12) + 1}.${1980 + random.nextInt(30)}',
      gender: random.nextBool() ? 'Мужской' : 'Женский',
      education: ['Среднее', 'Высшее', 'Ученая степень'][random.nextInt(3)],
      interests: interestsList[random.nextInt(interestsList.length)],
      languages: languagesList[random.nextInt(languagesList.length)],
      height: '${160 + random.nextInt(40)}',
      weight: '${50 + random.nextInt(40)}',
      hasChildren: random.nextBool() ? 'Да' : 'Нет',
      wantsChildren: ['Да', 'Нет', 'Не определился(ась)'][random.nextInt(3)],
      religion: ['Христианство', 'Ислам', 'Не указывать'][random.nextInt(3)],
      attitudeToAnimals: ['Люблю животных', 'Нейтрально', 'Не люблю'][random.nextInt(3)],
      smoking: random.nextBool() ? 'Курю' : 'Не курю',
      alcohol: random.nextBool() ? 'Пью' : 'Не пью',
      completedAt: DateTime.now().toIso8601String(),
      name: '$firstName $lastName',
      age: 20 + random.nextInt(30),
      selectedAvatar: random.nextBool() ? 'assets/images/Anna.jpg' : null,
      country: ['Россия', 'Украина', 'Беларусь', 'Казахстан', 'США'][random.nextInt(5)],
      city: ['Москва', 'Киев', 'Минск', 'Алматы', 'Нью-Йорк'][random.nextInt(5)],
      isAdmin: false,
      values: null,
      typeScores: null,
      dominantType: null,
    );
  }

  Map<String, dynamic> get statistics {
    final currentAge = age ?? calculatedAge;
    return {
      'profile_completion': profileCompletion,
      'age': currentAge,
      'age_group': currentAge != null
          ? currentAge < 25
          ? '18-24'
          : currentAge < 35
          ? '25-34'
          : currentAge < 45
          ? '35-44'
          : '45+'
          : null,
      'traits_count': allPersonalityTraits.length,
      'has_photo': selectedAvatar != null,
      'has_country': country != null && country!.isNotEmpty,
      'has_city': city != null && city!.isNotEmpty,
      'is_admin': isAdmin,
      'has_values': values != null && values!.isNotEmpty,
      'has_type_scores': typeScores != null && typeScores!.isNotEmpty,
      'dominant_type': dominantType,
      'last_updated': completedAt,
    };
  }

  String get zodiacSign {
    if (birthDate == null || birthDate!.isEmpty) return '';
    try {
      final parts = birthDate!.split('.');
      if (parts.length != 3) return '';
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (day == null || month == null) return '';
      if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '♈ Овен';
      if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '♉ Телец';
      if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '♊ Близнецы';
      if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '♋ Рак';
      if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '♌ Лев';
      if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '♍ Дева';
      if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '♎ Весы';
      if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '♏ Скорпион';
      if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '♐ Стрелец';
      if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '♑ Козерог';
      if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '♒ Водолей';
      if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return '♓ Рыбы';
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  String toString() {
    return 'UserProfile{name: $name, email: $email, age: $age, selectedAvatar: $selectedAvatar, country: $country, city: $city, isAdmin: $isAdmin, values: $values, dominantType: $dominantType}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserProfile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class UserUtils {
  static List<String> findCommonInterests(UserProfile user1, UserProfile user2) {
    if (user1.interests == null || user2.interests == null) return [];
    final interests1 = user1.interests!
        .toLowerCase()
        .split(RegExp(r'[,;.]'))
        .map((e) => e.trim())
        .toList();
    final interests2 = user2.interests!
        .toLowerCase()
        .split(RegExp(r'[,;.]'))
        .map((e) => e.trim())
        .toList();
    return interests1.where((interest) => interests2.contains(interest)).toList();
  }

  static double calculateCompatibility(UserProfile user1, UserProfile user2) {
    double score = 0.0;
    // 1. Общие интересы (30%)
    final commonInterests = findCommonInterests(user1, user2);
    if (commonInterests.isNotEmpty) {
      score += 0.3 * (commonInterests.length / 5).clamp(0.0, 1.0);
    }
    // 2. Возрастная совместимость (15%)
    final age1 = user1.age ?? user1.calculatedAge;
    final age2 = user2.age ?? user2.calculatedAge;
    if (age1 != null && age2 != null) {
      final ageDiff = (age1 - age2).abs();
      if (ageDiff <= 5) score += 0.15;
      else if (ageDiff <= 10) score += 0.07;
    }
    // 3. Общие черты характера (15%)
    final commonTraits = user1.allPersonalityTraits
        .where((trait) => user2.allPersonalityTraits.contains(trait))
        .toList();
    if (commonTraits.isNotEmpty) {
      score += 0.15 * (commonTraits.length / 5).clamp(0.0, 1.0);
    }
    // 4. Ценности (20%) – если оба заполнили
    if (user1.values != null && user2.values != null && user1.values!.isNotEmpty && user2.values!.isNotEmpty) {
      double valuesScore = 0.0;
      int count = 0;
      for (final key in user1.values!.keys) {
        if (user2.values!.containsKey(key)) {
          final diff = (user1.values![key]! - user2.values![key]!).abs();
          valuesScore += (10 - diff) / 10;
          count++;
        }
      }
      if (count > 0) {
        valuesScore /= count;
        score += 0.2 * valuesScore;
      }
    }
    // 5. Образование и привычки (10%)
    if (user1.education != null && user2.education != null && user1.education == user2.education) score += 0.03;
    if (user1.attitudeToAnimals != null && user2.attitudeToAnimals != null && user1.attitudeToAnimals == user2.attitudeToAnimals) score += 0.02;
    if (user1.smoking != null && user2.smoking != null && user1.smoking == user2.smoking) score += 0.02;
    if (user1.alcohol != null && user2.alcohol != null && user1.alcohol == user2.alcohol) score += 0.03;
    // 6. География (5%)
    if (user1.country != null && user2.country != null && user1.country == user2.country) score += 0.03;
    if (user1.city != null && user2.city != null && user1.city == user2.city) score += 0.02;
    // 7. Совместимость по типам личности (5%) – если оба прошли тест
    if (user1.dominantType != null && user2.dominantType != null) {
      final typeCompatibility = _getTypeCompatibility(user1.dominantType!, user2.dominantType!);
      score += 0.05 * typeCompatibility;
    }
    return score.clamp(0.0, 1.0);
  }

  // Вспомогательная функция для совместимости типов (0..1)
  static double _getTypeCompatibility(String type1, String type2) {
    if (type1 == type2) return 1.0;
    // Идеально комплементарные пары (по описанию)
    if ((type1 == 'Авантюрист' && type2 == 'Проводник') ||
        (type1 == 'Проводник' && type2 == 'Авантюрист')) return 0.9;
    if ((type1 == 'Активный' && type2 == 'Активный')) return 0.8;
    if ((type1 == 'Очаг' && type2 == 'Очаг')) return 0.8;
    // Конфликтные пары
    if ((type1 == 'Активный' && type2 == 'Очаг') ||
        (type1 == 'Очаг' && type2 == 'Активный')) return 0.2;
    if ((type1 == 'Авантюрист' && type2 == 'Авантюрист')) return 0.4;
    // Остальные комбинации – средняя совместимость
    return 0.6;
  }

  static List<String> getSearchTags(UserProfile user) {
    final tags = <String>[];
    if (user.gender != null) tags.add(user.gender!);
    if (user.education != null) tags.add(user.education!);
    if (user.interests != null) {
      tags.addAll(user.interests!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty));
    }
    if (user.languages != null) tags.add(user.languages!);
    if (user.country != null && user.country!.isNotEmpty) tags.add(user.country!);
    if (user.city != null && user.city!.isNotEmpty) tags.add(user.city!);
    return tags;
  }
}