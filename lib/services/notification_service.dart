import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Global instance
final notificationService = NotificationService();

class NotificationService {
  // Notification service implementation
  final notifcationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //initialize notification service
  Future<void> initNotification() async {
    if (_isInitialized) return; // Prevent re-initialization

    // Initialization settings for Android
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // Initialization settings for iOS
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    //init settings for both platforms
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    try {
      // initialise the plugin
      final result = await notifcationsPlugin.initialize(initSettings);
      _isInitialized = result ?? false;

      // Request permissions for Android 13+
      if (_isInitialized) {
        await _requestPermissions();
      }
    } catch (e) {
      print('Failed to initialize notifications: $e');
      _isInitialized = false;
    }
  }

  Future<void> _requestPermissions() async {
    final androidImplementation = notifcationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  //Notification details setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'mc_channel_id',
        'Submit Your Report',
        channelDescription: 'Please submit Todays report',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  //show notification function
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      print('Notification service not initialized');
      return;
    }

    try {
      final details = notificationDetails();
      await notifcationsPlugin.show(id, title, body, details);
      print('Notification sent: $title');
    } catch (e) {
      print('Failed to show notification: $e');
    }
  }
}
