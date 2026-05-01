import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _favoritesKey = 'favorites';
  static const String _themeKey = 'dark_theme';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _notifTimeKey = 'notification_time';

  // ─── AUTH ───────────────────────────────────────────────────────────────────

  Future<bool> register(String username, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    // Check if user already exists
    final existing = prefs.getString('user_$email');
    if (existing != null) return false;

    final userData = json.encode({
      'username': username,
      'email': email,
      'password': password,
    });
    await prefs.setString('user_$email', userData);
    await prefs.setString(_userKey, userData);
    return true;
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_$email');
    if (userJson == null) return null;

    final user = json.decode(userJson) as Map<String, dynamic>;
    if (user['password'] != password) return null;

    await prefs.setString(_userKey, userJson);
    return user;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return json.decode(userJson);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // ─── FAVORITES ──────────────────────────────────────────────────────────────

  Future<List<Article>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favsJson = prefs.getStringList(_favoritesKey) ?? [];
    return favsJson.map((s) => Article.fromJson(json.decode(s))).toList();
  }

  Future<void> addFavorite(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favoritesKey) ?? [];
    final articleJson = json.encode(article.toJson());
    if (!favs.contains(articleJson)) {
      favs.add(articleJson);
      await prefs.setStringList(_favoritesKey, favs);
    }
  }

  Future<void> removeFavorite(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favoritesKey) ?? [];
    favs.removeWhere((s) {
      final decoded = json.decode(s);
      return decoded['url'] == article.url;
    });
    await prefs.setStringList(_favoritesKey, favs);
  }

  Future<bool> isFavorite(Article article) async {
    final favs = await getFavorites();
    return favs.any((a) => a.url == article.url);
  }

  // ─── SETTINGS ───────────────────────────────────────────────────────────────

  Future<bool> getDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> setDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? false;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<String> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_notifTimeKey) ?? '09:00';
  }

  Future<void> setNotificationTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notifTimeKey, time);
  }
}
