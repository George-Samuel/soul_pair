import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/character_model.dart';
import '../models/character_repository.dart';
import 'character_detail_screen.dart';
import 'profile_screen.dart';

class CharacterListScreen extends StatelessWidget {
  final UserProfile userProfile;
  final String pathType;

  const CharacterListScreen({
    super.key,
    required this.userProfile,
    required this.pathType,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем персонажей через репозиторий (с учётом пола пользователя)
    final List<Character> characters = CharacterRepository.getCharactersForUser(userProfile.gender);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите AI-проводника'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Описание
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.purple[50],
            child: Column(
              children: [
                Text(
                  '${characters.length} уникальных AI-персонажей',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Выберите персонажа для интересных и познавательных бесед',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Список персонажей
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return _buildCharacterCard(context, character);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(BuildContext context, Character character) {
    // Преобразуем Character в Map для передачи в CharacterDetailScreen (для совместимости)
    final Map<String, dynamic> characterMap = {
      'name': character.name,
      'profession': character.profession,
      'description': character.description,
      'color': character.themeColor,
      'image': character.imagePath,
      'personality': character.personality,
      'gender': character.gender, // добавим пол, если он есть в модели
    };

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterDetailScreen(
                character: characterMap,
                userProfile: userProfile,
                pathType: pathType,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Изображение персонажа
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: character.themeColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: character.themeColor.withOpacity(0.2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.asset(
                    character.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: character.themeColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: character.themeColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.profession,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}