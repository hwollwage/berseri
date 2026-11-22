import 'package:berseri/app/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class ReminderSettings {
  const ReminderSettings({this.enabled = true, this.intervalDays = 3});

  final bool enabled;
  final int intervalDays;
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _reminderId = 1001;
  static const int _inactivityId = 1002;
  static const int _testId = 999;
  static const String _channelId = 'scan_reminder';
  static const String _payloadScan = 'scan';
  static const String _kEnabled = 'reminder_enabled';
  static const String _kDays = 'reminder_days';
  static const String _kLastScan = 'last_scan_at';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  static bool get _supported => !kIsWeb;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Pengingat scan wajah',
      channelDescription: 'Mengingatkan kamu untuk scan wajah secara rutin',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<ReminderSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    var enabled = prefs.getBool(_kEnabled) ?? true;
    var days = prefs.getInt(_kDays) ?? 3;

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final row = await Supabase.instance.client
            .from('profiles')
            .select('reminder_enabled, reminder_days')
            .eq('id', user.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 3));
        if (row != null) {
          debugPrint('loadSettings dari DB: $row');
          enabled = row['reminder_enabled'] as bool? ?? enabled;
          days = row['reminder_days'] as int? ?? days;
          await prefs.setBool(_kEnabled, enabled);
          await prefs.setInt(_kDays, days);
        }
      } catch (e) {
        debugPrint('loadSettings gagal, pakai cache: $e');
      }
    }
    return ReminderSettings(enabled: enabled, intervalDays: days);
  }

  Future<void> saveSettings(ReminderSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, s.enabled);
    await prefs.setInt(_kDays, s.intervalDays);

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from('profiles')
            .update({
              'reminder_enabled': s.enabled,
              'reminder_days': s.intervalDays,
            })
            .eq('id', user.id)
            .select();
        debugPrint(
          'Update profiles: ${res.length} baris berubah (user ${user.id})',
        );
      } catch (e) {
        debugPrint('Gagal simpan pengaturan ke Supabase: $e');
      }
    } else {
      debugPrint('saveSettings: user belum login, hanya simpan lokal');
    }
    await scheduleInactivityReminder();
  }

  Future<void> init() async {
    if (!_supported || _ready) return;

    tz_data.initializeTimeZones();
    final localZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localZone.identifier));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _onTap,
    );
    _ready = true;
  }

  Future<bool> requestPermission() async {
    if (!_supported) return false;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  static void _onTap(NotificationResponse response) {
    if (response.payload == _payloadScan) {
      router.push('/camera');
    }
  }

  Future<void> showTest() async {
    if (!_supported) return;

    await _plugin.show(
      id: _testId,
      title: 'Jangan lupa scan wajah',
      body: 'Yuk cek kondisi kulitmu hari ini.',
      notificationDetails: _details,
      payload: _payloadScan,
    );
  }

  Future<void> scheduleInactivityReminder({
    int hour = 19,
    int minute = 0,
  }) async {
    if (!_supported) return;

    await _plugin.cancel(id: _inactivityId);

    final settings = await loadSettings();
    if (!settings.enabled) return;

    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_kLastScan);
    final now = tz.TZDateTime.now(tz.local);
    final base = lastMs == null
        ? now
        : tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, lastMs);

    var when = tz.TZDateTime(
      tz.local,
      base.year,
      base.month,
      base.day + settings.intervalDays,
      hour,
      minute,
    );
    if (!when.isAfter(now)) {
      when = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }

    await _plugin.zonedSchedule(
      id: _inactivityId,
      title: 'Sudah ${settings.intervalDays} hari nih',
      body: 'Jangan lupa scan wajah untuk pantau kondisi kulitmu.',
      scheduledDate: when,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: _payloadScan,
    );
  }

  Future<void> ensureReminderScheduled() async {
    if (!_supported) return;

    await _plugin.cancel(id: _reminderId);

    final pending = await _plugin.pendingNotificationRequests();
    if (!pending.any((n) => n.id == _inactivityId)) {
      await scheduleInactivityReminder();
    }
  }

  Future<void> onScanCompleted() async {
    if (!_supported) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLastScan, DateTime.now().millisecondsSinceEpoch);
      await scheduleInactivityReminder();
      debugPrint('Pengingat dijadwalkan ulang');
    } catch (e) {
      debugPrint('Gagal menjadwalkan ulang pengingat: $e');
    }
  }

  Future<void> cancelReminder() async {
    if (!_supported) return;

    await _plugin.cancel(id: _reminderId);
    await _plugin.cancel(id: _inactivityId);
  }
}