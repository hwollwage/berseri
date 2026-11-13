import 'dart:convert';
import 'dart:typed_data';

import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'clinic.dart';

class ClinicRepository {
  ClinicRepository({this.client, this.geolocator});

  final SupabaseClient? client;

  final GeolocatorPlatform? geolocator;

  static const String _columns = 'id, name, address, phone, rating, location';

  Future<List<Clinic>> fetchNearby({
    required double lat,
    required double lng,
    double radiusKm = 25,
    int limit = 10,
  }) async {
    final db = client;
    if (db == null) return const <Clinic>[];

    final rows = await db
        .from('clinics')
        .select(_columns)
        .eq('is_active', true);

    final clinics = <Clinic>[];
    for (final row in (rows as List).cast<Map<String, dynamic>>()) {
      final point = pointOf(row['location']);
      if (point == null) continue;

      final distance =
          (geolocator?.distanceBetween(lat, lng, point.lat, point.lng) ??
              Geolocator.distanceBetween(lat, lng, point.lat, point.lng)) /
          1000;

      clinics.add(
        Clinic(
          id: row['id'].toString(),
          name: (row['name'] as String?)?.trim() ?? '',
          address: (row['address'] as String?)?.trim() ?? '',
          latitude: point.lat,
          longitude: point.lng,
          distanceKm: distance,
          phone: (row['phone'] as String?)?.trim(),
          rating: (row['rating'] as num?)?.toDouble(),
        ),
      );
    }

    clinics.removeWhere((clinic) => clinic.name.isEmpty);
    clinics.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    final nearby = clinics.where((c) => c.distanceKm <= radiusKm);
    final pool = nearby.isEmpty ? clinics : nearby;

    return pool.take(limit).toList(growable: false);
  }

  static ({double lat, double lng})? _point(Object? raw) {
    final hex = raw?.toString().trim();
    if (hex == null || hex.isEmpty) return null;

    final bytes = _tryHex(hex);
    if (bytes == null || bytes.length < 25) return null;

    final littleEndian = bytes[0] == 1;
    final data = ByteData.sublistView(bytes);
    final x = data.getFloat64(9, littleEndian ? Endian.little : Endian.big);
    final y = data.getFloat64(17, littleEndian ? Endian.little : Endian.big);

    if (x.abs() > 180 || y.abs() > 90) return null;
    return (lat: y, lng: x);
  }

  static Uint8List? _tryHex(String hex) {
    if (hex.length.isOdd) return null;
    try {
      return Uint8List.fromList([
        for (var i = 0; i < hex.length; i += 2)
          int.parse(hex.substring(i, i + 2), radix: 16),
      ]);
    } on FormatException {
      return null;
    }
  }

  static ({double lat, double lng})? _wkt(String raw) {
    final match = RegExp(
      r'POINT\s*\(\s*(-?[\d.]+)\s+(-?[\d.]+)\s*\)',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match == null) return null;
    final lng = double.tryParse(match.group(1)!);
    final lat = double.tryParse(match.group(2)!);
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  static ({double lat, double lng})? _geoJson(Object? raw) {
    if (raw is! Map) return null;
    final coordinates = raw['coordinates'];
    if (coordinates is! List || coordinates.length < 2) return null;
    final lng = (coordinates[0] as num?)?.toDouble();
    final lat = (coordinates[1] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  static ({double lat, double lng})? pointOf(Object? raw) {
    if (raw is Map) return _geoJson(raw);
    final text = raw?.toString().trim();
    if (text == null || text.isEmpty) return null;
    if (text.toUpperCase().startsWith('POINT')) return _wkt(text);
    if (text.startsWith('{')) {
      try {
        return _geoJson(jsonDecode(text));
      } on FormatException {
        return null;
      }
    }
    return _point(text);
  }
}
