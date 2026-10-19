import '../../domain/entities/meal_entity.dart';

class MealModel {
  final String id;
  final String name;
  final String category;
  final String area;
  final String thumbnailUrl;

  const MealModel({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.thumbnailUrl,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
    id: (json['idMeal'] as String?) ?? '',
    name: (json['strMeal'] as String?) ?? '',
    category: (json['strCategory'] as String?) ?? '',
    area: (json['strArea'] as String?) ?? '',
    thumbnailUrl: (json['strMealThumb'] as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'idMeal': id,
    'strMeal': name,
    'strCategory': category,
    'strArea': area,
    'strMealThumb': thumbnailUrl,
  };

  MealEntity toEntity() => MealEntity(
    id: id,
    name: name,
    category: category,
    area: area,
    thumbnailUrl: thumbnailUrl,
  );
}
