import 'meal_model.dart';

class MealsResponse {
  final List<MealModel>? meals;

  const MealsResponse({this.meals});

  factory MealsResponse.fromJson(Map<String, dynamic> json) => MealsResponse(
    meals: (json['meals'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .map(MealModel.fromJson)
        .toList(),
  );
}
