import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  // Check if this is the first time the app is launched
  bool get isFirstLaunch {
    return _prefs.getBool(_keyFirstLaunch) ?? true;
  }

  // Mark that the app has been launched
  Future<void> setFirstLaunchCompleted() async {
    await _prefs.setBool(_keyFirstLaunch, false);
  }

  // Check if onboarding has been completed
  bool get isOnboardingCompleted {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  // Mark onboarding as completed
  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
  }

  // Static method to initialize AppPreferences
  static Future<AppPreferences> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(prefs);
  }
}
