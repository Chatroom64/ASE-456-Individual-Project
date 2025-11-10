import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyLoggedIn = 'is_logged_in';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Registers a new user (if not already registered)
  Future<bool> signUp(String username, String password) async {
    await init();
    final existingUser = _prefs.getString(_keyUsername);
    if (existingUser != null) {
      // already signed up
      return false;
    }
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyPassword, password);
    await _prefs.setBool(_keyLoggedIn, true);
    return true;
  }

  /// Signs in if username and password match
  Future<bool> signIn(String username, String password) async {
    await init();
    final storedUser = _prefs.getString(_keyUsername);
    final storedPass = _prefs.getString(_keyPassword);

    if (storedUser == username && storedPass == password) {
      await _prefs.setBool(_keyLoggedIn, true);
      return true;
    }
    return false;
  }

  /// Logs out the current user
  Future<void> signOut() async {
    await init();
    await _prefs.setBool(_keyLoggedIn, false);
  }

  /// Checks if user is logged in
  Future<bool> isLoggedIn() async {
    await init();
    return _prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Optionally clear stored credentials (for testing)
  Future<void> clearAll() async {
    await init();
    await _prefs.clear();
  }
}
