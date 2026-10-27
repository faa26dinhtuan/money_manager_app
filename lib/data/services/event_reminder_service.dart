import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:money_manager_app/data/models/planned_event.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';
import 'package:money_manager_app/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class EventReminderService {
  EventReminderService._();

  static final EventReminderService instance = EventReminderService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    try {
      timezone_data.initializeTimeZones();
      try {
        final localTimezone = await FlutterTimezone.getLocalTimezone();
        timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));
      } catch (_) {}
      await _notifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _initialized = true;
    } catch (_) {}
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return true;
    if (!_initialized) await initialize();
    if (!_initialized) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _notifications
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await _notifications
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      default:
        return false;
    }
  }

  Future<void> sync(
    List<PlannedEvent> events, {
    required AppLocalizations localization,
  }) async {
    if (!_initialized || kIsWeb) return;
    try {
      final pending = await _notifications.pendingNotificationRequests();
      for (final request in pending) {
        if (request.payload?.startsWith('event-reminder:') == true) {
          await _notifications.cancel(request.id);
        }
      }
      final now = DateTime.now();
      final occurrences = <({PlannedEvent event, DateTime date})>[];
      for (final event in events) {
        final reminderMinutes = event.reminderMinutes;
        if (reminderMinutes == null) continue;
        var occurrence = DateTime(event.date.year, event.date.month, event.date.day);
        var iterations = 0;
        while (iterations < 400) {
          final reminderDate = DateTime(
            occurrence.year,
            occurrence.month,
            occurrence.day,
            reminderMinutes ~/ 60,
            reminderMinutes % 60,
          );
          final isSkipped = event.skippedDates.any((date) =>
              date.year == occurrence.year &&
              date.month == occurrence.month &&
              date.day == occurrence.day);
          if (!isSkipped && reminderDate.isAfter(now)) {
            occurrences.add((event: event, date: reminderDate));
          }
          if (event.frequency == null ||
              occurrence.isAfter(now.add(const Duration(days: 366)))) {
            break;
          }
          occurrence = _advance(occurrence, event.date, event.frequency!);
          iterations++;
        }
      }
      occurrences.sort((a, b) => a.date.compareTo(b.date));
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'planned_event_reminders',
          localization.eventReminderChannel,
          channelDescription: localization.eventReminderChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      for (final occurrence in occurrences.take(60)) {
        final date = occurrence.date;
        await _notifications.zonedSchedule(
          _notificationId(occurrence.event.id, date),
          localization.eventReminderNotificationTitle,
          occurrence.event.title,
          timezone.TZDateTime(
            timezone.local,
            date.year,
            date.month,
            date.day,
            date.hour,
            date.minute,
          ),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'event-reminder:${occurrence.event.id}',
        );
      }
    } catch (_) {}
  }

  DateTime _advance(DateTime from, DateTime start, Frequency frequency) {
    switch (frequency) {
      case Frequency.daily:
        return DateTime(from.year, from.month, from.day + 1);
      case Frequency.weekly:
        return DateTime(from.year, from.month, from.day + 7);
      case Frequency.monthly:
        return _advanceMonths(from, start, 1);
      case Frequency.yearly:
        return _advanceMonths(from, start, 12);
    }
  }

  DateTime _advanceMonths(DateTime from, DateTime start, int months) {
    final total = from.month - 1 + months;
    final year = from.year + total ~/ 12;
    final month = total % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = start.day < lastDay ? start.day : lastDay;
    return DateTime(year, month, day);
  }

  int _notificationId(String eventId, DateTime date) {
    var hash = 0x811c9dc5;
    final value =
        '${eventId}_${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }
}
