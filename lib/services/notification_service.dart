import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/bill.dart';
import '../models/config.dart';
import 'budget_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Request permissions (especially for iOS)
  static Future<bool> requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return true;
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to bills screen
    // This would require BuildContext or a navigation service
  }

  // Schedule notification for a specific date and time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bills_channel',
          'Bill Reminders',
          channelDescription: 'Notifications for upcoming bills',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Schedule bill reminder notifications
  static Future<void> scheduleBillReminders() async {
    final config = BudgetService.getConfig();
    if (config == null) return;

    final bills = BudgetService.getBills();
    final viewingMonth = config.viewingMonth;

    // Cancel all existing notifications
    await _notifications.cancelAll();

    int notificationId = 1000;

    for (var bill in bills) {
      if (bill.paid) continue; // Skip paid bills

      final dueDate = bill.getDueDate(viewingMonth);
      final now = DateTime.now();

      // Skip if bill is past due
      if (dueDate.isBefore(now)) continue;

      // Schedule notification 3 days before
      final threeDaysBefore = dueDate.subtract(const Duration(days: 3));
      if (threeDaysBefore.isAfter(now)) {
        await scheduleNotification(
          id: notificationId++,
          title: 'Bill Due Soon: ${bill.name}',
          body: 'Due in 3 days - \$${bill.amount.toStringAsFixed(2)}',
          scheduledDate: threeDaysBefore.copyWith(hour: 9, minute: 0),
        );
      }

      // Schedule notification 1 day before
      final oneDayBefore = dueDate.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now)) {
        await scheduleNotification(
          id: notificationId++,
          title: 'Bill Due Tomorrow: ${bill.name}',
          body: 'Due tomorrow - \$${bill.amount.toStringAsFixed(2)}',
          scheduledDate: oneDayBefore.copyWith(hour: 9, minute: 0),
        );
      }

      // Schedule notification on due date
      if (dueDate.isAfter(now)) {
        await scheduleNotification(
          id: notificationId++,
          title: 'Bill Due Today: ${bill.name}',
          body: 'Due today - \$${bill.amount.toStringAsFixed(2)}',
          scheduledDate: dueDate.copyWith(hour: 9, minute: 0),
        );
      }
    }
  }

  // Schedule paycheck reminder
  static Future<void> schedulePaycheckReminder(Config config) async {
    final nextPaycheck = config.getNextPaycheckDate();
    final now = DateTime.now();

    if (nextPaycheck.isAfter(now)) {
      // Notify 1 day before paycheck
      final oneDayBefore = nextPaycheck.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now)) {
        await scheduleNotification(
          id: 9999,
          title: 'Paycheck Tomorrow!',
          body: '\$${config.paycheckAmount.toStringAsFixed(2)} coming soon',
          scheduledDate: oneDayBefore.copyWith(hour: 18, minute: 0),
        );
      }

      // Notify on paycheck day
      await scheduleNotification(
        id: 9998,
        title: 'Paycheck Day! 🎉',
        body: '\$${config.paycheckAmount.toStringAsFixed(2)} should be deposited today',
        scheduledDate: nextPaycheck.copyWith(hour: 9, minute: 0),
      );
    }
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
