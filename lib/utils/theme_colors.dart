import 'package:flutter/material.dart';

class ThemeColors {
  // Основной цвет текста (bodyLarge)
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  // Вторичный цвет текста (bodyMedium)
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey[700]!;

  // Цвет подсказок / второстепенного текста (bodySmall)
  static Color textHint(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

  // Акцентный цвет (primary) — например, фиолетовый
  static Color accent(BuildContext context) => Theme.of(context).primaryColor;

  // Цвет для иконок по умолчанию
  static Color iconDefault(BuildContext context) =>
      Theme.of(context).iconTheme.color ?? Colors.grey;

  // Фоновый цвет карточек
  static Color cardBackground(BuildContext context) =>
      Theme.of(context).cardColor;

  // Цвет разделителей
  static Color divider(BuildContext context) =>
      Theme.of(context).dividerColor;

  // 🔹 Белый текст на акцентном фоне (например, для кнопок)
  static Color onAccent(BuildContext context) => Colors.white; // добавляем этот метод
}