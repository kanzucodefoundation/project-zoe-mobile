import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';
import 'package:flutter/material.dart';

// Global instance
final notificationService = NotificationService();

class NotificationService {
  // Notification service implementation
  final notifcationsPlugin = FlutterLocalNotificationsPlugin();
  Timer? _testTimer;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //initialize notification service
  Future<void> initNotification() async {
    if (_isInitialized) return; // Prevent re-initialization

    // Initialize timezone
    tz.initializeTimeZones();

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
      // initialise the plugin with callback to track when notifications are tapped
      final result = await notifcationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      _isInitialized = result ?? false;

      // Request permissions for Android 13+
      if (_isInitialized) {
        await _requestPermissions();
        await _createNotificationChannel();
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

  // Create notification channel explicitly
  Future<void> _createNotificationChannel() async {
    final androidImplementation = notifcationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      const channel = AndroidNotificationChannel(
        'mc_channel_id',
        'MC Report Reminders',
        description: 'Notifications for MC report reminders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFF00FF00),
        showBadge: true,
      );

      await androidImplementation.createNotificationChannel(channel);
      print('✅ Notification channel created: ${channel.id}');
    }
  }

  // Callback when notification is received/tapped
  static void _onNotificationResponse(NotificationResponse response) {
    print('🎯 Notification received: ${response.payload}');
    print('🎯 Notification ID: ${response.id}');
    print('🎯 Action ID: ${response.actionId}');
  }

  // Alternative timer-based approach for testing (more reliable)
  Future<void> scheduleTestWith10SecondTimer() async {
    if (!_isInitialized) {
      print('❌ Notification service not initialized');
      return;
    }

    // Cancel existing timer
    _testTimer?.cancel();

    print('⏰ Starting 10-second countdown timer...');

    _testTimer = Timer(const Duration(seconds: 10), () async {
      print('🚀 Timer fired! Sending notification now...');
      await showNotification(
        id: 999,
        title: '10-Second Timer Test',
        body:
            'This notification was sent using a Timer (not scheduled)! ${DateTime.now().toString().substring(11, 19)}',
      );
      print('✅ Timer-based notification sent');
    });

    print('✅ 10-second timer started successfully');
  }

  // Cancel timer-based test
  Future<void> cancelTimerTest() async {
    _testTimer?.cancel();
    _testTimer = null;
    print('🛑 Timer-based test cancelled');
  }

  // Schedule report reminder in 2 minutes using timer (reliable method)
  Future<void> scheduleReportReminderIn2Minutes() async {
    if (!_isInitialized) {
      print('❌ Notification service not initialized');
      return;
    }

    // Cancel existing timer
    _testTimer?.cancel();

    print('📝 Starting 2-minute report reminder countdown...');

    _testTimer = Timer(const Duration(minutes: 2), () async {
      print('🚀 2-minute timer fired! Sending report reminder...');
      await showNotification(
        id: 200,
        title: '📋 Time to Submit Your Report!',
        body:
            'Your daily report is due. Please submit it now to stay on track.',
      );
      print('✅ Report reminder notification sent');
    });

    print('✅ 2-minute report reminder timer started successfully');
  }

  // Cancel all notifications and timers
  Future<void> cancelAllNotifications() async {
    try {
      // Cancel all scheduled notifications
      await notifcationsPlugin.cancelAll();

      // Cancel timer
      _testTimer?.cancel();
      _testTimer = null;

      print('🛑 All notifications and timers cancelled');
    } catch (e) {
      print('❌ Failed to cancel all notifications: $e');
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
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFF00FF00),
        ledOnMs: 1000,
        ledOffMs: 500,
        showWhen: true,
        when: null,
        usesChronometer: false,
        chronometerCountDown: false,
        channelShowBadge: true,
        onlyAlertOnce: false,
        ongoing: false,
        autoCancel: true,
        silent: false,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
      ),
    );
  }

  //show notification function
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      print('❌ Notification service not initialized');
      return;
    }

    try {
      print('📱 Attempting to show notification: $title');
      final details = notificationDetails();
      await notifcationsPlugin.show(id, title, body, details);
      print('✅ Notification sent successfully: $title');

      // Check if notifications are enabled
      await _checkNotificationStatus();
    } catch (e) {
      print('❌ Failed to show notification: $e');
    }
  }

  // Enhanced notification status check
  Future<void> _checkNotificationStatus() async {
    final androidImplementation = notifcationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      try {
        final enabled = await androidImplementation.areNotificationsEnabled();
        print('🔔 Notifications enabled: $enabled');

        final channelsBlocked = await androidImplementation
            .getNotificationChannels();
        print('📺 Available channels: ${channelsBlocked?.length ?? 0}');
      } catch (e) {
        print('❌ Error checking notification status: $e');
      }
    }
  }

  // Schedule MC report reminder - for testing with minutes
  Future<void> scheduleMcReportReminderTest() async {
    if (!_isInitialized) {
      print('Notification service not initialized');
      return;
    }

    try {
      // Cancel any existing scheduled notifications for MC reports
      await cancelMcReportReminder();

      // Schedule notification to repeat every minute for testing
      await notifcationsPlugin.periodicallyShow(
        100, // Unique ID for MC report reminders
        'MC Report Reminder',
        'Don\'t forget to submit your MC report today!',
        RepeatInterval.everyMinute,
        notificationDetails(),
        androidScheduleMode:
            AndroidScheduleMode.inexactAllowWhileIdle, // Changed to inexact
        payload: 'mc_report_reminder',
      );

      print(
        'MC report reminder scheduled (every minute for testing) - first notification will appear in 1 minute',
      );

      // Check if notification permissions are granted
      await _checkNotificationPermissions();
    } catch (e) {
      print('Failed to schedule MC report reminder: $e');
    }
  }

  // Check notification permissions
  Future<void> _checkNotificationPermissions() async {
    final androidImplementation = notifcationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      print('Notification permissions granted: $granted');

      if (granted == false) {
        print('Requesting notification permissions...');
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  // Schedule MC report reminder for every Wednesday (production)
  Future<void> scheduleMcReportReminderWeekly() async {
    if (!_isInitialized) {
      print('Notification service not initialized');
      return;
    }

    try {
      // Cancel any existing scheduled notifications
      await cancelMcReportReminder();

      // Calculate next Wednesday at 9 AM
      final now = DateTime.now();
      DateTime nextWednesday = _getNextWednesday(now);

      // Convert to TZDateTime
      final tzDateTime = tz.TZDateTime.from(nextWednesday, tz.local);

      await notifcationsPlugin.zonedSchedule(
        101, // Unique ID for weekly MC report reminders
        'Weekly MC Report Reminder',
        'It\'s Wednesday! Time to submit your MC report.',
        tzDateTime,
        notificationDetails(),
        payload: 'weekly_mc_report',
        androidScheduleMode:
            AndroidScheduleMode.inexactAllowWhileIdle, // Changed to inexact
      );

      print('Weekly MC report reminder scheduled for: $nextWednesday');
    } catch (e) {
      print('Failed to schedule weekly MC report reminder: $e');
    }
  }

  // Helper method to calculate next Wednesday at 9 AM
  DateTime _getNextWednesday(DateTime now) {
    // Wednesday is weekday 3 (Monday = 1)
    int daysUntilWednesday = (3 - now.weekday + 7) % 7;
    if (daysUntilWednesday == 0 && now.hour >= 9) {
      // If it's already Wednesday and past 9 AM, schedule for next Wednesday
      daysUntilWednesday = 7;
    }

    return DateTime(
      now.year,
      now.month,
      now.day + daysUntilWednesday,
      9, // 9 AM
      0, // 0 minutes
      0, // 0 seconds
    );
  }

  // Cancel MC report reminder
  Future<void> cancelMcReportReminder() async {
    try {
      await notifcationsPlugin.cancel(100); // Test reminder
      await notifcationsPlugin.cancel(101); // Weekly reminder
      await notifcationsPlugin.cancel(102); // 10-second test
      await notifcationsPlugin.cancel(103); // 30-second test
      await notifcationsPlugin.cancel(104); // 60-second test
      print('All scheduled reminders cancelled');
    } catch (e) {
      print('Failed to cancel MC report reminders: $e');
    }
  }

  // Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await notifcationsPlugin.pendingNotificationRequests();
  }

  // Schedule a single notification after 10 seconds for immediate testing
  Future<void> scheduleTestNotificationIn10Seconds() async {
    if (!_isInitialized) {
      print('❌ Notification service not initialized');
      return;
    }

    try {
      // Cancel any existing 10-second tests
      await notifcationsPlugin.cancel(102);

      final now = DateTime.now();
      final scheduledTime = now.add(const Duration(seconds: 10));

      // Convert to TZDateTime
      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      print('⏰ Current time: ${now.toString()}');
      print('⏰ Scheduled time: ${scheduledTime.toString()}');
      print('⏰ TZ Scheduled time: ${tzDateTime.toString()}');

      await notifcationsPlugin.zonedSchedule(
        102, // Unique ID for 10-second test
        '10 Second Test',
        'This notification was scheduled 10 seconds ago! Time: ${DateTime.now().toString().substring(11, 19)}',
        tzDateTime,
        notificationDetails(),
        payload: 'test_10_seconds',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      print('✅ Test notification scheduled successfully (inexact timing)');

      // Show pending notifications count
      final pending = await getPendingNotifications();
      print('📊 Total pending notifications: ${pending.length}');

      // Also schedule backup notifications at different intervals
      await _scheduleBackupTests();
    } catch (e) {
      print('❌ Failed to schedule 10-second test: $e');
    }
  }

  // Schedule multiple test notifications to see which ones work
  Future<void> _scheduleBackupTests() async {
    try {
      final now = DateTime.now();

      // 30 seconds
      final time30 = tz.TZDateTime.from(
        now.add(const Duration(seconds: 30)),
        tz.local,
      );
      await notifcationsPlugin.zonedSchedule(
        103,
        '30 Second Backup Test',
        'This is the 30-second backup test',
        time30,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'test_30_seconds',
      );

      // 1 minute
      final time60 = tz.TZDateTime.from(
        now.add(const Duration(seconds: 60)),
        tz.local,
      );
      await notifcationsPlugin.zonedSchedule(
        104,
        '1 Minute Backup Test',
        'This is the 1-minute backup test',
        time60,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'test_60_seconds',
      );

      print('✅ Backup test notifications scheduled (30s, 60s)');
    } catch (e) {
      print('❌ Failed to schedule backup tests: $e');
    }
  }
}
