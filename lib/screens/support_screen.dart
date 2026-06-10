import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key}); // ← добавить const
  // ⚠️ ЗАМЕНИТЕ НА ВАШИ РЕКВИЗИТЫ
  final String cardNumber = '4255 1901 9952 9416';
  // номер банковской карты
  final String usdtTrc20Address = 'TUExYdfsDmhMC1hGxyxwMYBeHE2q2J1Tvs';
  // USDT Tron TRC20
  final String usdtBep20Address = '0xaf6a087f030ea8e5a93e724a36030bb5e5c8c074';
  // USDT BNB Smart Chain(BSC) BEP20

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Поддержать Soul Pair'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildCardDonation(context),
          SizedBox(height: 16),
          _buildCryptoDonation(context),
          SizedBox(height: 16),
          _buildThanksCard(),
        ],
      ),
    );
  }

  Widget _buildCardDonation(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💳 Перевод на карту', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(cardNumber, style: TextStyle(fontSize: 16))),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: cardNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Номер карты скопирован'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Как перевести:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '• Откройте приложение вашего банка\n'
                  '• Выберите «Перевод по номеру карты»\n'
                  '• Вставьте номер карты и сумму\n'
                  '• Укажите назначение: «Добровольная поддержка проекта Soul Pair»\n'
                  '• Подтвердите перевод',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoDonation(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₿ Криптовалюта (USDT)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildCryptoRow('Сеть TRC20 (Tron)', usdtTrc20Address, context),
            SizedBox(height: 12),
            _buildCryptoRow('Сеть BEP20 (BNB Smart Chain)', usdtBep20Address, context),
            SizedBox(height: 12),
            Text('❗ Важно:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '• Отправляйте USDT ТОЛЬКО в указанной сети. Перевод через другую сеть приведёт к потере средств.\n'
                  '• Комиссия TRC20: ~1-2 USDT, BEP20: ~0.2-0.5 USDT.\n'
                  '• Номер карты и криптоадреса можно скопировать нажатием на значок копирования.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoRow(String network, String address, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(network, style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(child: Text(address, style: TextStyle(fontSize: 12, fontFamily: 'monospace'))),
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: address));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Адрес $network скопирован'), duration: Duration(seconds: 1)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThanksCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('✨ Спасибо за поддержку!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              'Каждый перевод помогает развивать приложение и делать его лучше. Мы искренне благодарны за вашу добровольную помощь.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}