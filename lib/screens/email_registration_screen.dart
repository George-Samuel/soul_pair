import 'package:flutter/material.dart';
import '../theme.dart';
import 'user_data_collection_screen.dart';

class EmailRegistrationScreen extends StatefulWidget {
  const EmailRegistrationScreen({super.key});

  @override
  State<EmailRegistrationScreen> createState() =>
      _EmailRegistrationScreenState();
}

class _EmailRegistrationScreenState extends State<EmailRegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool get _isValid =>
      _emailController.text.trim().contains('@') &&
          _passwordController.text.length >= 6;

  void _register(BuildContext context) {
    if (!_isValid) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UserDataCollectionScreen(
          userEmail: email,
          userPassword: password,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soul Pair'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  const Icon(Icons.favorite, size: 60, color: Colors.purple),
                  const SizedBox(height: 20),
                  const Text(
                    'Знакомства для серьёзных отношений',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AI подберёт партнёра на основе ваших ценностей и интересов',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль (мин. 6 символов)',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isValid ? () => _register(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Создать профиль',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}