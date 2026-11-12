import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'clinic.dart';

/// Mengambil klinik di sekitar posisi user dari OpenStreetMap (Overpass API).

class ClinicRepository {
  ClinicRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const List<String> _endpoints = <String>[
    'https://overpass-api.de/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
  ];

  static const Duration _requestTimeout = Duration(seconds: 60);

  Future<List<Clinic>> fetchNearby({
    required double lat,
    required double lng,
    double radiusKm = 5,
    int limit = 10,
  }) async {
    final radius = (radiusKm * 1000).round();
    final query = '''
[out:json][timeout:50];
(
  nwr["amenity"="clinic"](around:$radius,$lat,$lng);
  nwr["healthcare"="clinic"](around:$radius,$lat,$lng);
);
out center tags 100;
''';

    final body = await _post(query);
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

  Future<Map<String, dynamic>> _post(String query) async {
    final deadline = DateTime.now().add(_requestTimeout);
    Exception? lastError;

    for (final endpoint in _endpoints) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) break;

      try {
        final res = await _client
            .post(
              Uri.parse(endpoint),
              headers: const {'User-Agent': 'berseri-app/1.0'},
              body: {'data': query},
            )
            .timeout(remaining);

        if (res.statusCode != 200) {
          lastError = Exception('Gagal memuat klinik (${res.statusCode})');
          continue;
        }

        return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      } on Exception catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? Exception('Gagal memuat klinik');
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
