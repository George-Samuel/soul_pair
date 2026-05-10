import 'package:flutter/material.dart';
import '../services/user_manager.dart';
import '../services/profile_service.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Загружаем данные параллельно
    final dataFuture = Future.wait([
      UserManager.loadUsers(),
      ProfileService.loadProfileFromFile(),
    ]);

    // Ждём анимацию и загрузку
    Future.delayed(const Duration(milliseconds: 1500), () async {
      await dataFuture;
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            'assets/icon/icon.png',
            width: double.infinity,   // на весь экран по ширине
            height: double.infinity,  // на весь экран по высоте
            fit: BoxFit.cover,        // покрыть весь экран (может обрезать)
          ),
        ),
      ),
    );
  }
}