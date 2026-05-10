class ChatSession {
  final String id;
  final String characterName;
  final String? characterImage;
  final String lastMessage;
  final DateTime lastUpdated;
  final String pathType;
  final bool isTrainer;
  final String? characterProfession;
  final String? characterPersonality;

  ChatSession({
    required this.id,
    required this.characterName,
    this.characterImage,
    required this.lastMessage,
    required this.lastUpdated,
    required this.pathType,
    this.isTrainer = false,
    this.characterProfession,
    this.characterPersonality,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'characterName': characterName,
    'characterImage': characterImage,
    'lastMessage': lastMessage,
    'lastUpdated': lastUpdated.toIso8601String(),
    'pathType': pathType,
    'isTrainer': isTrainer,
    'characterProfession': characterProfession,
    'characterPersonality': characterPersonality,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    characterName: json['characterName'] as String,
    characterImage: json['characterImage'] as String?,
    lastMessage: json['lastMessage'] as String,
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    pathType: json['pathType'] as String,
    isTrainer: json['isTrainer'] as bool? ?? false,
    characterProfession: json['characterProfession'] as String?,
    characterPersonality: json['characterPersonality'] as String?,
  );
}