import 'package:flutter/material.dart';

class AvatarGenerator {
  /// Генерирует URL аватара на основе уникального идентификатора (email/id)
  static String generateAvatarUrl(String seed, {double size = 200}) {
    // Выберите стиль: adventurer, pixel-art, identicon, micah, notionists, lorelei
    const style = 'adventurer';
    // Формат: svg или png
    const format = 'svg';

    return 'https://api.dicebear.com/9.x/$style/$format?seed=$seed&size=$size';
  }

  /// Возвращает Widget аватара (можно использовать Image.network)
  static Widget avatarWidget(String seed, {double radius = 50, double size = 200}) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(generateAvatarUrl(seed, size: size)),
      backgroundColor: Colors.grey.shade200,
      child: null,
    );
  }
}