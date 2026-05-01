import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _storage = StorageService();
  final _notifications = NotificationService();

  bool _notificationsEnabled = false;
  String _notificationTime = '09:00';
  bool _breakingNews = true;
  bool _dailyDigest = true;
  bool _weeklyRecap = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _storage.getNotificationsEnabled();
    final time = await _storage.getNotificationTime();
    if (mounted) setState(() {
      _notificationsEnabled = enabled;
      _notificationTime = time;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    await _storage.setNotificationsEnabled(value);
    setState(() => _notificationsEnabled = value);
    if (!value) await _notifications.cancelAll();
  }

  Future<void> _pickTime() async {
    final parts = _notificationTime.split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await _storage.setNotificationTime(timeStr);
      setState(() => _notificationTime = timeStr);
      if (_notificationsEnabled) {
        await _notifications.scheduleDailyNotification(picked.hour, picked.minute);
      }
    }
  }

  Future<void> _sendTestNotification() async {
    await _notifications.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Тестовое уведомление отправлено!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Master toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SwitchListTile(
                title: const Text('Уведомления', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                subtitle: Text(_notificationsEnabled ? 'Включены' : 'Выключены'),
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                secondary: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: (_notificationsEnabled ? AppTheme.accent : Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                    color: _notificationsEnabled ? AppTheme.accent : Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Notification types
          if (_notificationsEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'ТИП УВЕДОМЛЕНИЙ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2),
              ),
            ),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Срочные новости', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Мгновенные оповещения о важных событиях'),
                    value: _breakingNews,
                    onChanged: (v) => setState(() => _breakingNews = v),
                    secondary: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.flash_on, color: Colors.red),
                    ),
                  ),
                  const Divider(height: 1, indent: 72),
                  SwitchListTile(
                    title: const Text('Ежедневный дайджест', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Каждый день в $_notificationTime'),
                    value: _dailyDigest,
                    onChanged: (v) => setState(() => _dailyDigest = v),
                    secondary: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.today, color: Colors.blue),
                    ),
                  ),
                  const Divider(height: 1, indent: 72),
                  SwitchListTile(
                    title: const Text('Еженедельный обзор', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Лучшие материалы за неделю'),
                    value: _weeklyRecap,
                    onChanged: (v) => setState(() => _weeklyRecap = v),
                    secondary: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.view_week, color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Time settings
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'ВРЕМЯ УВЕДОМЛЕНИЯ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2),
              ),
            ),
            Card(
              child: ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.access_time, color: AppTheme.accent),
                ),
                title: const Text('Время дайджеста', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Ежедневно в $_notificationTime'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickTime,
              ),
            ),
            const SizedBox(height: 24),

            // Test notification button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendTestNotification,
                icon: const Icon(Icons.send),
                label: const Text('Отправить тестовое уведомление', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
