import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'clinic.dart';

/// Mengambil klinik di sekitar posisi user dari OpenStreetMap (Overpass API).

class ClinicRepository {
  ClinicRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  Future<List<Clinic>> fetchNearby({
    required double lat,
    required double lng,
    double radiusKm = 5,
    int limit = 10,
  }) async {
    final radius = (radiusKm * 1000).round();

    // Hanya klinik (bukan rumah sakit / apotek).
    final query = '''
[out:json][timeout:25];
(
  nwr["amenity"="clinic"](around:$radius,$lat,$lng);
  nwr["healthcare"="clinic"](around:$radius,$lat,$lng);
);
out center tags;
''';

    final res = await _client
        .post(
          Uri.parse(_endpoint),
          headers: {'User-Agent': 'berseri-app/1.0'},
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat klinik (${res.statusCode})');
    }

    final body =
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final elements = (body['elements'] as List).cast<Map<String, dynamic>>();

    final seen = <String>{};
    final clinics = <Clinic>[];

    for (final e in elements) {
      final tags =
          (e['tags'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

      final name = (tags['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;

      final center = e['center'] as Map<String, dynamic>?;
      final cLat = ((e['lat'] ?? center?['lat']) as num?)?.toDouble();
      final cLng = ((e['lon'] ?? center?['lon']) as num?)?.toDouble();
      if (cLat == null || cLng == null) continue;

      final id = '${e['type']}/${e['id']}';
      if (!seen.add(id)) continue;

      final meters = Geolocator.distanceBetween(lat, lng, cLat, cLng);

      clinics.add(
        Clinic(
          id: id,
          name: name,
          address: _address(tags),
          latitude: cLat,
          longitude: cLng,
          distanceKm: meters / 1000,
          phone: (tags['phone'] ?? tags['contact:phone']) as String?,
        ),
      );
    }

    clinics.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return clinics.take(limit).toList();
  }

  String _address(Map<String, dynamic> t) {
    final street = [t['addr:street'], t['addr:housenumber']]
        .whereType<String>()
        .join(' ');
    final parts = [street, t['addr:suburb'], t['addr:city']]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty);
    return parts.isEmpty ? 'Alamat belum tersedia' : parts.join(', ');
  }
}