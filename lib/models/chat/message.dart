class Message {
  final String text;
  final bool isUser;
  final DateTime time;
  final String? imageUrl;
  final int? id; // добавляем

  Message({
    required this.text,
    required this.isUser,
    required this.time,
    this.imageUrl,
    this.id, // добавляем
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'time': time.toIso8601String(),
    'imageUrl': imageUrl,
    'id': id,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    text: json['text'] as String,
    isUser: json['isUser'] as bool,
    time: DateTime.parse(json['time'] as String),
    imageUrl: json['imageUrl'] as String?,
    id: json['id'] as int?,
  );
}