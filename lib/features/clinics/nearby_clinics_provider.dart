import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'clinic.dart';
import 'clinic_repository.dart';

final clinicRepositoryProvider = Provider<ClinicRepository>(
  (ref) => ClinicRepository(),
);

enum LocationIssue { serviceOff, denied, deniedForever }

class LocationException implements Exception {
  LocationException(this.issue);

  final LocationIssue issue;
}

/// Posisi user saat ini (minta izin kalau belum ada).
final userPositionProvider = FutureProvider.autoDispose<Position>((ref) async {
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

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 15),
    ),
  );
});

/// Klinik di sekitar posisi user (dari OpenStreetMap), terdekat dulu.
final nearbyClinicsProvider =
    FutureProvider.autoDispose<List<Clinic>>((ref) async {
  final pos = await ref.watch(userPositionProvider.future);
  return ref.watch(clinicRepositoryProvider).fetchNearby(
        lat: pos.latitude,
        lng: pos.longitude,

      );
});