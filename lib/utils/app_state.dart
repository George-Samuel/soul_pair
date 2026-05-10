// lib/utils/app_state.dart
import '../models/user_model.dart';

class AppState {
  static UserProfile? _currentProfile;

  static UserProfile? get currentProfile => _currentProfile;

  static void setProfile(UserProfile profile) {
    _currentProfile = profile;
    print('💾 Профиль сохранен в AppState: ${profile.name}');
  }

  static void updateProfile(UserProfile newProfile) {
    _currentProfile = newProfile.copyWith(
      completedAt: DateTime.now().toIso8601String(),
    );
    print('🔄 Профиль обновлен в AppState: ${newProfile.name}');
  }

  static void clear() {
    _currentProfile = null;
    print('🗑️ AppState очищен');
  }

  static bool get hasProfile => _currentProfile != null;
}
