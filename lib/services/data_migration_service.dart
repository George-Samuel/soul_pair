import 'dart:io';
import 'storage_path.dart';

class DataMigrationService {
  static const String _migrationFlagFile = '.migration_v1_done';

  static Future<bool> get _isMigrationDone async {
    try {
      final baseDir = await StoragePath.getFilesDir();
      final flagFile = File('$baseDir/$_migrationFlagFile');
      return await flagFile.exists();
    } catch (e) {
      print('❌ Ошибка проверки флага миграции: $e');
      return false;
    }
  }

  static Future<void> _setMigrationDone() async {
    try {
      final baseDir = await StoragePath.getFilesDir();
      final flagFile = File('$baseDir/$_migrationFlagFile');
      await flagFile.create(recursive: true);
      print('✅ Флаг миграции установлен: ${flagFile.path}');
    } catch (e) {
      print('❌ Ошибка установки флага миграции: $e');
    }
  }

  static Future<void> runMigration() async {
    if (await _isMigrationDone) {
      print('✅ Миграция уже выполнена ранее');
      return;
    }

    print('🔄 Начинаем миграцию данных из systemTemp в постоянное хранилище...');

    final tempDir = Directory.systemTemp;
    final oldBase = tempDir.path;
    final newBase = await StoragePath.getFilesDir();

    final oldUsersDir = Directory(oldBase);
    if (!await oldUsersDir.exists()) {
      print('ℹ️ Старая папка $oldBase не существует, миграция не нужна');
      await _setMigrationDone();
      return;
    }

    final List<FileSystemEntity> entities = await oldUsersDir.list().toList();
    final List<Directory> oldUserDirs = [];

    for (final entity in entities) {
      if (entity is Directory && entity.path.contains('user_')) {
        oldUserDirs.add(entity);
      }
    }

    if (oldUserDirs.isEmpty) {
      print('ℹ️ Старых папок пользователей не найдено');
      await _setMigrationDone();
      return;
    }

    int migratedCount = 0;

    for (final dir in oldUserDirs) {
      final userId = dir.path.split('user_').last;
      print('📁 Найдены старые данные для user_$userId');

      try {
        final newUserDir = Directory('$newBase/user_$userId');
        await newUserDir.create(recursive: true);

        final List<FileSystemEntity> oldFiles = await dir.list().toList();
        for (final entity in oldFiles) {
          if (entity is File) {
            final fileName = entity.path.split(Platform.pathSeparator).last;
            final newFile = File('${newUserDir.path}/$fileName');
            await entity.copy(newFile.path);
            print('   ✅ Скопирован: $fileName');
          }
        }
        migratedCount++;
      } catch (e) {
        print('❌ Ошибка миграции для user_$userId: $e');
      }
    }

    if (migratedCount > 0) {
      print('✅ Миграция завершена: обработано $migratedCount пользователей');
    } else {
      print('⚠️ Не удалось перенести данные ни для одного пользователя');
    }

    await _setMigrationDone();
  }
}