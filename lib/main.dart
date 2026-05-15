import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/email_registration_screen.dart';
import 'screens/path_selection_screen.dart';
import 'screens/login_screen.dart';          // <-- импорт
import 'theme.dart';
import 'utils/logger.dart';
import 'models/user_model.dart';
import 'services/profile_service.dart';
import 'services/user_manager.dart';

_MyAppState? appState;

void setAppState(_MyAppState state) {
  appState = state;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    AppLogger.w('Файл .env не найден');
  }

  await UserManager.loadUsers();
  await ProfileService.loadProfileFromFile();

  AppLogger.section('SOUL PAIR');
  AppLogger.team('SYSTEM', 'Запуск приложения');
  AppLogger.i('Инициализация...');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    setAppState(this);
  }

  ThemeMode get themeMode => _themeMode;

  void changeTheme(ThemeMode mode) {
    if (_themeMode == mode) return;
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.i('Создание MaterialApp...');

    // Решаем, какой экран показать первым
    Widget initialScreen;
    if (ProfileService.currentProfile != null) {
      // Если профиль уже есть (пользователь залогинен) → сразу главный экран
      initialScreen = PathSelectionScreen(
        userProfile: ProfileService.currentProfile!,
      );
    } else {
      // Иначе показываем экран входа/регистрации
      initialScreen = const LoginScreen();
    }

    return MaterialApp(
      title: 'Soul Pair',
      theme: SoulTheme.lightTheme,
      darkTheme: SoulTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: initialScreen,
      routes: {
        '/registration': (context) => const EmailRegistrationScreen(),
        '/edit_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

          if (args == null) {
            return const Scaffold(
              body: Center(
                child: Text('Ошибка: не переданы данные профиля'),
              ),
            );
          }

          final profile = args['profile'] as UserProfile;
          final onUpdated = args['onUpdated'] as void Function(UserProfile)?;

          return EditProfileScreen(
            initialProfile: profile,
            onProfileUpdated: onUpdated,
          );
        },
      },
    );
  }
}