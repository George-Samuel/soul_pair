class ReportService {
  /// Отправить жалобу на сообщение или пользователя
  static Future<void> sendReport({
    required String targetUserId,
    required String messageId,
    required String reason,
    String? additionalInfo,
  }) async {
    // TODO: заменить на реальную отправку на сервер
    print('=== ЖАЛОБА ===');
    print('На пользователя: $targetUserId');
    print('Сообщение ID: $messageId');
    print('Причина: $reason');
    if (additionalInfo != null) print('Доп. информация: $additionalInfo');
    print('===============');

    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 500));
  }
}