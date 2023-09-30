import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

initialize() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    macOS: initializationSettingsDarwin,
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();
}

send(message) {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Eagler notification', 'Eagler notification',
          channelDescription: 'the alert condition was triggered',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  flutterLocalNotificationsPlugin.show(
      0, 'Eagler Alerting', message, notificationDetails,
      payload: 'item x');
}
