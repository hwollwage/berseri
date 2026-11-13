import 'dart:async';

import 'package:berseri/core/supabase/supabase_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'clinic.dart';
import 'clinic_repository.dart';

final clinicRepositoryProvider = Provider<ClinicRepository>((ref) {
  SupabaseClient? client;
  try {
    client = ref.watch(supabaseClientProvider);
  } catch (_) {
    client = null;
  }
  return ClinicRepository(client: client);
});

enum LocationIssue { serviceOff, denied, deniedForever, timeout }

class LocationException implements Exception {
  LocationException(this.issue);

  final LocationIssue issue;

  @override
  String toString() => 'LocationException($issue)';
}

const Duration _cacheTtl = Duration(minutes: 5);

final userPositionProvider = FutureProvider.autoDispose<Position>((ref) async {
  _keepAliveFor(ref, _cacheTtl);

  if (!await _serviceEnabled()) {
    throw LocationException(LocationIssue.serviceOff);
  }

  final permission = await _ensurePermission();
  if (permission == LocationPermission.deniedForever) {
    throw LocationException(LocationIssue.deniedForever);
  }
  if (permission != LocationPermission.whileInUse &&
      permission != LocationPermission.always) {
    throw LocationException(LocationIssue.denied);
  }

  final last = await _lastKnownPosition();
  if (last != null && DateTime.now().difference(last.timestamp) <= _cacheTtl) {
    return last;
  }

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
  } on TimeoutException {
    throw LocationException(LocationIssue.timeout);
  } on PermissionDeniedException {
    throw LocationException(LocationIssue.deniedForever);
  } on LocationServiceDisabledException {
    throw LocationException(LocationIssue.serviceOff);
  } on PlatformException {
    throw LocationException(LocationIssue.timeout);
  } on UnsupportedError {
    throw LocationException(LocationIssue.deniedForever);
  }
});

final nearbyClinicsProvider =
    FutureProvider.autoDispose<List<Clinic>>((ref) async {
      _keepAliveFor(ref, _cacheTtl);

      final pos = await ref.watch(userPositionProvider.future);
      return ref.watch(clinicRepositoryProvider).fetchNearby(
        lat: pos.latitude,
        lng: pos.longitude,
      );
    });

void retryNearbyClinics(WidgetRef ref, Object error) {
  ref.invalidate(nearbyClinicsProvider);
  if (error is LocationException) ref.invalidate(userPositionProvider);
}

Future<void> openLocationSettingsSafely() async {
  if (kIsWeb) return;
  try {
    await Geolocator.openLocationSettings();
  } on UnsupportedError {
  } on PlatformException {
  }
}

Future<void> openAppSettingsSafely() async {
  if (kIsWeb) return;
  try {
    await Geolocator.openAppSettings();
  } on UnsupportedError {
  } on PlatformException {
  }
}

Future<bool> _serviceEnabled() async {
  try {
    return await Geolocator.isLocationServiceEnabled();
  } on UnsupportedError {
    return true;
  } on PlatformException {
    return true;
  }
}

Future<LocationPermission> _ensurePermission() async {
  var permission = LocationPermission.denied;
  try {
    permission = await Geolocator.checkPermission();
  } on UnsupportedError {
    permission = LocationPermission.unableToDetermine;
  } on PlatformException {
    permission = LocationPermission.unableToDetermine;
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.unableToDetermine) {
    try {
      permission = await Geolocator.requestPermission();
    } on UnsupportedError {
      return LocationPermission.unableToDetermine;
    } on PlatformException {
      return LocationPermission.unableToDetermine;
    }
  }

  return permission;
}

Future<Position?> _lastKnownPosition() async {
  try {
    return await Geolocator.getLastKnownPosition();
  } on UnsupportedError {
    return null;
  } on PlatformException {
    return null;
  }
}

void _keepAliveFor(Ref ref, Duration ttl) {
  final link = ref.keepAlive();
  Timer? timer;

  ref.onCancel(() {
    timer = Timer(ttl, link.close);
  });
  ref.onResume(() {
    timer?.cancel();
    timer = null;
  });
  ref.onDispose(() => timer?.cancel());
}
