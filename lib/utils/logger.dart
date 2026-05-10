// lib/utils/logger.dart
import 'dart:developer' as dev;

class AppLogger {
  // Константы для цветов (ANSI коды)
  static const String _reset = '\x1B[0m';
  static const String _black = '\x1B[30m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';

  // Trace (самый подробный уровень)
  static void t(dynamic message) {
    _logWithStyle('🔍 TRACE', message, _cyan);
  }

  // Debug (для отладки)
  static void d(dynamic message) {
    _logWithStyle('🐛 DEBUG', message, _blue);
  }

  // Info (информационные сообщения)
  static void i(dynamic message) {
    _logWithStyle('ℹ️ INFO', message, _green);
  }

  // Warning (предупреждения)
  static void w(dynamic message) {
    _logWithStyle('⚠️ WARN', message, _yellow);
  }

  // Error (ошибки)
  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    final time = _getTime();
    const coloredLevel = '$_red❌ ERROR$_reset';
    final mainMessage = '$coloredLevel | $time | $message';

    dev.log(mainMessage, error: error, stackTrace: stackTrace);

    if (error != null) {
      dev.log('$_red     ↳ Error: $error$_reset');
    }
  }

  // Fatal (критические ошибки)
  static void f(dynamic message) {
    _logWithStyle('💀 FATAL', message, _magenta);
  }

  // Вспомогательный метод для стильного логирования
  static void _logWithStyle(String emojiLevel, dynamic message, String color) {
    final time = _getTime();
    final coloredLevel = '$color$emojiLevel$_reset';

    dev.log('$coloredLevel | $time | $message');
  }

  // Получение форматированного времени
  static String _getTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  // Дополнительные полезные методы
  static void start(String operation) {
    _logWithStyle('▶️ START', operation, _blue);
  }

  static void end(String operation, {dynamic result}) {
    final msg = result != null ? '$operation → $result' : operation;
    _logWithStyle('✅ END', msg, _green);
  }

  static void section(String title) {
    final line = '=' * 50;
    dev.log('\n$_cyan$line$_reset');
    dev.log('$_cyan   $title$_reset');
    dev.log('$_cyan$line$_reset\n');
  }

  static void team(String module, String action) {
    final time = _getTime();
    dev.log('$_green👥 TEAM$_reset | $time | [$module] $action');
  }
}
