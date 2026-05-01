import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings: settings);
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'news_channel',
      'News Notifications',
      channelDescription: 'Daily news updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id: 0,
      title: '📰 NewsApp',
      body: 'Ваши ежедневные новости готовы! Нажмите для просмотра.',
      notificationDetails: details,
    );
  }

  Future<void> scheduleDailyNotification(int hour, int minute) async {
    const androidDetails = AndroidNotificationDetails(
      'news_daily_channel',
      'Daily News',
      channelDescription: 'Daily morning news digest',
      importance: Importance.defaultImportance,
    );
    const details = NotificationDetails(android: androidDetails);

    // Cancel existing before rescheduling
    await _plugin.cancel(id: 1);

    await _plugin.periodicallyShow(
      id: 1,
      title: '📰 Ежедневный дайджест',
      body: 'Новые материалы уже ждут вас!',
      repeatInterval: RepeatInterval.daily,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
