import 'package:berseri/app/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Notifikasi lokal: pengingat "jangan lupa scan wajah".
///
/// Ada dua pengingat:
/// 1. Harian jam 19.00. Kalau pengguna sudah scan hari ini, mulai besok.
/// 2. Tidak aktif: sekali jalan, muncul kalau tidak scan selama 3 hari.
///    Dijadwal ulang setiap scan selesai.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _reminderId = 1001;
  static const int _inactivityId = 1002;
  static const int _testId = 999;
  static const int _inactivityDays = 3;
  static const String _channelId = 'scan_reminder';
  static const String _payloadScan = 'scan';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Pengingat scan wajah',
      channelDescription: 'Mengingatkan kamu untuk scan wajah secara rutin',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  /// Panggil sekali saat aplikasi mulai (di main).
  Future<void> init() async {
    if (_ready) return;

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

  /// Android 13+ wajib meminta izin notifikasi.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Saat notifikasi di-tap: buka halaman kamera.
  static void _onTap(NotificationResponse response) {
    if (response.payload == _payloadScan) {
      router.push('/camera');
    }
  }

  /// Notifikasi langsung, hanya untuk mengetes izin dan tampilan.
  Future<void> showTest() {
    return _plugin.show(
      id: _testId,
      title: 'Jangan lupa scan wajah',
      body: 'Yuk cek kondisi kulitmu hari ini.',
      notificationDetails: _details,
      payload: _payloadScan,
    );
  }

  /// Jadwalkan pengingat harian jam [hour]:[minute].
  /// Kalau [scannedToday] true, pengingat pertama jatuh besok.
  Future<void> scheduleReminder({
    required bool scannedToday,
    int hour = 19,
    int minute = 0,
  }) async {
    await _plugin.cancel(id: _reminderId);

    final now = tz.TZDateTime.now(tz.local);
    var first =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scannedToday || !first.isAfter(now)) {
      first = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }

    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'Jangan lupa scan wajah',
      body: 'Yuk cek kondisi kulitmu hari ini.',
      scheduledDate: first,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _payloadScan,
    );
  }

  /// Jadwalkan pengingat "tidak scan [_inactivityDays] hari" jam [hour]:[minute].
  /// Sekali jalan (tidak berulang). Jadwal lama dibatalkan dulu.
  Future<void> scheduleInactivityReminder({
    int hour = 19,
    int minute = 0,
  }) async {
    await _plugin.cancel(id: _inactivityId);

    final now = tz.TZDateTime.now(tz.local);
    final when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + _inactivityDays,
      hour,
      minute,
    );

    await _plugin.zonedSchedule(
      id: _inactivityId,
      title: 'Sudah $_inactivityDays hari nih',
      body: 'Jangan lupa scan wajah untuk pantau kondisi kulitmu.',
      scheduledDate: when,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: _payloadScan,
    );
  }

  /// Panggil saat app dibuka. Jadwal disimpan oleh sistem Android,
  /// jadi cukup cek apakah sudah ada. Kalau belum, jadwalkan.
  Future<void> ensureReminderScheduled() async {
    // Hapus pengingat harian lama yang mungkin masih terpasang di HP.
    await _plugin.cancel(id: _reminderId);

    final pending = await _plugin.pendingNotificationRequests();
    if (!pending.any((n) => n.id == _inactivityId)) {
      await scheduleInactivityReminder();
    }
  }

  /// Panggil setiap kali scan selesai: pengingat harian mulai besok,
  /// dan hitungan 3 hari tidak aktif dimulai ulang.
  Future<void> onScanCompleted() async {
    try {
      await scheduleInactivityReminder();
      debugPrint('Pengingat 3 hari dijadwalkan ulang');
    } catch (e) {
      debugPrint('Gagal menjadwalkan ulang pengingat: $e');
    }
  }

  Future<void> cancelReminder() async {
    await _plugin.cancel(id: _reminderId);
    await _plugin.cancel(id: _inactivityId);
  }
}