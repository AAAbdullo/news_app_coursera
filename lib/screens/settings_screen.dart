import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService();
  bool _darkTheme = false;
  String _selectedLanguage = 'Русский';
  String _selectedCountry = 'us';

  final List<String> _languages = ['Русский', 'English', 'O\'zbekcha'];
  final Map<String, String> _countries = {
    'us': '🇺🇸 США',
    'gb': '🇬🇧 Великобритания',
    'ru': '🇷🇺 Россия',
    'de': '🇩🇪 Германия',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dark = await _storage.getDarkTheme();
    if (mounted) setState(() => _darkTheme = dark);
  }

  Future<void> _toggleDarkTheme(bool value) async {
    await _storage.setDarkTheme(value);
    setState(() => _darkTheme = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Тёмная тема включена' : 'Светлая тема включена'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки приложения'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          _buildSectionHeader('Внешний вид'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Тёмная тема', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_darkTheme ? 'Включена' : 'Выключена'),
                  value: _darkTheme,
                  onChanged: _toggleDarkTheme,
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _darkTheme ? Icons.dark_mode : Icons.light_mode,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.language, color: AppTheme.accent),
                  ),
                  title: const Text('Язык интерфейса', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_selectedLanguage),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() => _selectedLanguage = v!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // News section
          _buildSectionHeader('Новости'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.public, color: AppTheme.accent),
                  ),
                  title: const Text('Регион новостей', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_countries[_selectedCountry] ?? _selectedCountry),
                  trailing: DropdownButton<String>(
                    value: _selectedCountry,
                    underline: const SizedBox(),
                    items: _countries.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCountry = v!),
                  ),
                ),
                const Divider(height: 1, indent: 72),
                SwitchListTile(
                  title: const Text('Автообновление', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Обновлять новости каждые 30 минут'),
                  value: true,
                  onChanged: (_) {},
                  secondary: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.refresh, color: AppTheme.accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data section
          _buildSectionHeader('Данные'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text('Очистить кэш', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Удалить временные данные'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Кэш очищен'), behavior: SnackBarBehavior.floating),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
