import '../../domain/entities/vendor_entity.dart';

class VendorModel extends VendorEntity {
  const VendorModel({
    required super.id,
    required super.nameKey,
    required super.cuisineKey,
    required super.rating,
    required super.latitude,
    required super.longitude,
  });

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      id: map['id'] as String,
      nameKey: map['nameKey'] as String,
      cuisineKey: map['cuisineKey'] as String,
      rating: (map['rating'] as num).toDouble(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameKey': nameKey,
      'cuisineKey': cuisineKey,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
