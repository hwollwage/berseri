import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'clinic.dart';
import 'clinic_repository.dart';

final clinicRepositoryProvider = Provider<ClinicRepository>(
  (ref) => ClinicRepository(),
);

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

  if (!await Geolocator.isLocationServiceEnabled()) {
    throw LocationException(LocationIssue.serviceOff);
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    throw LocationException(LocationIssue.denied);
  }
  if (permission == LocationPermission.deniedForever) {
    throw LocationException(LocationIssue.deniedForever);
  }

  final last = await Geolocator.getLastKnownPosition();
  if (last != null &&
      DateTime.now().difference(last.timestamp) <= _cacheTtl) {
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
  } on LocationServiceDisabledException {
    throw LocationException(LocationIssue.serviceOff);
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
