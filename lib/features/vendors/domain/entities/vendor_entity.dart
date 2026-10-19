class VendorEntity {
  final String id;
  final String nameKey;
  final String cuisineKey;
  final double rating;
  final double latitude;
  final double longitude;

  const VendorEntity({
    required this.id,
    required this.nameKey,
    required this.cuisineKey,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });
}
