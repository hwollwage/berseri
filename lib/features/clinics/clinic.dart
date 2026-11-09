class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.phone,
    this.rating,
    this.isOpen,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String? phone;
  final double? rating;
  final bool? isOpen;

  factory Clinic.fromJson(Map<String, dynamic> json) => Clinic(
        id: json['id'].toString(),
        name: json['name'] as String,
        address: json['address'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        distanceKm: (json['distance_km'] as num).toDouble(),
        phone: json['phone'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        isOpen: json['is_open'] as bool?,
      );

  String get formattedDistance => distanceKm < 1
      ? '${(distanceKm * 1000).round()} m'
      : '${distanceKm.toStringAsFixed(1)} km';
}