import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import 'path_selection_screen.dart';
import 'email_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните email и пароль')),
      );
      return;
    }
    final userId = email.replaceAll('@', '_at_').replaceAll('.', '_dot_');
    setState(() => _isLoading = true);
    final success = await ApiService.login(userId, password);
    setState(() => _isLoading = false);
    if (success) {
      final profileData = await ApiService.fetchProfile(userId);
      if (profileData != null) {
        final profile = UserProfile.fromMap(profileData);
        await ProfileService.updateProfile(profile);
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PathSelectionScreen(userProfile: profile),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось загрузить профиль')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный email или пароль')),
      );
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    final success = await ApiService.signInWithGoogle();
    setState(() => _isLoading = false);
    if (success && context.mounted) {
      // ... переход
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Войти'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _googleSignIn,
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Войти через Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmailRegistrationScreen()),
                      );
                    },
                    child: const Text('Нет аккаунта? Зарегистрироваться'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}