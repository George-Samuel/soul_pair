import 'dart:io';
import 'storage_path.dart';
import 'share_service.dart';

class BackupService {
  static Future<String?> exportBackup() async {
    try {
      final sourceDirPath = await StoragePath.getFilesDir();
      final sourceDir = Directory(sourceDirPath);
      if (!await sourceDir.exists()) return null;

      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final textFilePath = '${tempDir.path}/soul_pair_export_$timestamp.txt';

      // Создаём текстовый файл с перечнем файлов
      final buffer = StringBuffer();
      buffer.writeln('Экспорт данных Soul Pair на ${DateTime.now()}');
      buffer.writeln('===');

      await for (var entity in sourceDir.list(recursive: true)) {
        if (entity is File) {
          buffer.writeln('Файл: ${entity.path}');
          buffer.writeln('Размер: ${await entity.length()} байт');
          buffer.writeln('---');
        } else if (entity is Directory) {
          buffer.writeln('Папка: ${entity.path}');
          buffer.writeln('---');
        }
      }

      await File(textFilePath).writeAsString(buffer.toString());
      return textFilePath;
    } catch (e) {
      print('❌ Ошибка экспорта: $e');
      return null;
    }
  }
}