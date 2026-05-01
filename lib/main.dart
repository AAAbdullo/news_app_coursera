import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const NewsApp());
}

class NewsApp extends StatefulWidget {
  const NewsApp({super.key});

  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  final _storage = StorageService();
  bool _isDarkTheme = false;
  Widget? _home;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final user = await _storage.getCurrentUser();
    final dark = await _storage.getDarkTheme();
    if (mounted) {
      setState(() {
        _isDarkTheme = dark;
        _home = user != null ? const HomeScreen() : const LoginScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_home == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'NewsApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: _home,
    );
  }
}
